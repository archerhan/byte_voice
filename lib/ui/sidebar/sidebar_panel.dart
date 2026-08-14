import '../../logger.dart';
import '../../providers/transcription_provider.dart';
import '../../services/transcription_service.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_selector/file_selector.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../models/note.dart';
import '../../models/note_status.dart';
import '../../models/segment.dart';
import '../../providers/notes_provider.dart';
import '../../services/audio_import_service.dart';
import '../../services/audio_storage_service.dart';
import '../../services/engine_isolate.dart';
import '../../providers/app_mode_provider.dart';
import 'note_list_item.dart';
import 'tts_sidebar_panel.dart';

/// 侧边栏面板 — 笔记搜索、列表、导入按钮
class SidebarPanel extends ConsumerWidget {
  const SidebarPanel({super.key});

  /// 删除笔记确认对话框
  /// 删除笔记确认对话框
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        backgroundColor: ShadTheme.of(context).colorScheme.background,
        title: Text(
          '删除笔记',
          style: TextStyle(color: ShadTheme.of(context).colorScheme.foreground),
        ),
        description: Text(
          '确认删除「${note.title}」？\n此操作不可恢复。',
          style: TextStyle(
            color: ShadTheme.of(context).colorScheme.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '删除',
              style: TextStyle(
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final notesRepo = ref.read(notesRepositoryProvider);
    final segmentsRepo = ref.read(segmentsRepositoryProvider);
    await segmentsRepo.deleteByNoteId(note.id);
    await notesRepo.delete(note.id);
    await AudioStorageService.deleteAudio(note.id);

    // 删除时不修改 selectedNoteIdProvider，避免触发 segments 重建导致 double build
    // ContentArea 中 note==null 时会自动显示 EmptyState
    ref.invalidate(notesProvider);
  }

  /// 打开文件选择器 → 导入并转写
  Future<void> _pickAndImport(BuildContext context, WidgetRef ref) async {
    appLog.d('[UI] 点击导入按钮');
    String? noteId;
    String? permanentWavPath;
    String? fileTitle;
    try {
      final srcFile = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'Audio',
            extensions: AudioImportService.supportedExtensions,
            uniformTypeIdentifiers: [
              'public.mp3',
              'public.mpeg-4-audio',
              'com.microsoft.waveform-audio',
              'public.aac-audio',
              'org.xiph.ogg',
              'org.xiph.flac',
            ],
          ),
        ],
      ).timeout(Duration(seconds: 30), onTimeout: () => null);
      appLog.d('[UI] 选择结果: ${srcFile?.path ?? "null"}');
      if (srcFile == null) return;

      fileTitle = p.basenameWithoutExtension(srcFile.name);
      final notesRepo = ref.read(notesRepositoryProvider);
      noteId = Uuid().v4();

      // 1. 立即创建笔记（转写中）
      await notesRepo.create(
        Note(
          id: noteId,
          title: fileTitle,
          source: NoteSource.import,
          status: NoteStatus.transcribing,
        ),
      );
      ref.invalidate(notesProvider);
      ref.read(selectedNoteIdProvider.notifier).set(noteId);
      appLog.d('[UI] 笔记已创建: id=$noteId, title=$fileTitle');

      // 2. 转码（非 WAV 格式）并复制到沙盒永久目录
      final ext = p.extension(srcFile.path).toLowerCase();
      final audioSrcPath = srcFile.path;
      String audioForProcessing;
      if (ext == '.wav') {
        audioForProcessing = audioSrcPath;
      } else {
        appLog.d('[UI] 通过 ffmpeg 解码 $ext → WAV...');
        final importService = AudioImportService();
        audioForProcessing = await importService.decodeToWav(audioSrcPath);
      }
      appLog.d('[UI] 保存音频到沙盒: $audioForProcessing');
      final permanentPath = await AudioStorageService.saveImportedAudio(
        noteId: noteId,
        wavFilePath: audioForProcessing,
      );
      permanentWavPath = permanentPath;
      appLog.d('[UI] 音频已保存: $permanentPath');

      // 3. 设置进度显示
      ref.read(processingNotesProvider.notifier).update((state) {
        return {
          ...state,
          noteId!: ProcessingState(message: '正在转写 $fileTitle...'),
        };
      });

      // 4. 检查模型文件
      final appDir = await getApplicationSupportDirectory();
      final modelsDir = p.join(appDir.path, 'models');
      final vadFile = p.join(modelsDir, 'vad', 'silero_vad.onnx');
      final svFile = p.join(modelsDir, 'asr-nonstreaming', 'model.int8.onnx');
      final tokensFile = p.join(modelsDir, 'asr-nonstreaming', 'tokens.txt');
      final punctFile = p.join(modelsDir, 'punct', 'model.int8.onnx');

      if (!File(vadFile).existsSync() || !File(svFile).existsSync()) {
        throw Exception('模型文件缺失，请先在设置中下载');
      }

      // 5. 后台 Isolate 转写
      final segments = await processInIsolate(
        audioPath: permanentPath,
        sileroVadModel: vadFile,
        senseVoiceModel: svFile,
        tokensFile: tokensFile,
        punctuationModel: File(punctFile).existsSync() ? punctFile : null,
        onProgress: (p) {
          ref.read(processingNotesProvider.notifier).update((state) {
            return {
              ...state,
              noteId!: ProcessingState(
                message: '正在转写 $fileTitle...',
                progress: p,
              ),
            };
          });
        },
      );

      // 6. 保存片段到数据库
      final segmentsRepo = ref.read(segmentsRepositoryProvider);
      final dbSegments = segments.asMap().entries.map((e) {
        final seg = e.value;
        return Segment(
          id: Uuid().v4(),
          noteId: noteId!,
          startMs: seg.startMs,
          endMs: seg.endMs,
          text: seg.text,
          sortIndex: e.key,
        );
      }).toList();

      if (dbSegments.isNotEmpty) {
        await segmentsRepo.bulkInsert(dbSegments);
      }

      // 7. 更新笔记状态为已完成
      final durationMs = segments.isEmpty ? 0 : segments.last.endMs;
     await notesRepo.update(
       Note(
          id: noteId,
          title: fileTitle,
          durationMs: durationMs,
          audioFilePath: permanentPath,
          keepAudio: true,
          source: NoteSource.import,
          status: NoteStatus.completed,
        ),
      );

      ref.invalidate(notesProvider);
      ref.invalidate(selectedNoteSegmentsProvider);

      // 清除进度
      ref.read(processingNotesProvider.notifier).update((state) {
        final newState = Map<String, ProcessingState>.from(state);
        newState.remove(noteId!);
        return newState;
      });

      appLog.d('[UI] 导入转写完成: ${segments.length} 个片段');

      if (context.mounted) {
        ShadToaster.of(context).show(
          ShadToast(description: Text('转写完成: ${segments.length} 个片段')),
        );
      }
    } catch (e) {
      if (noteId != null) {
        ref.read(processingNotesProvider.notifier).update((state) {
          final newState = Map<String, ProcessingState>.from(state);
          newState.remove(noteId!);
          return newState;
        });
      }
      // 更新笔记状态为失败，保留已保存的音频路径
      try {
        if (noteId != null) {
          await ref
              .read(notesRepositoryProvider)
              .update(
                Note(
                  id: noteId,
                  title: fileTitle ?? '未命名笔记',
                  audioFilePath: permanentWavPath,
                  source: NoteSource.import,
                  status: NoteStatus.failed,
                ),
              );
          ref.invalidate(notesProvider);
        }
      } catch (_) {}
      appLog.d('[UI] 转写出错: $e');
      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('转写出错: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final selectedId = ref.watch(selectedNoteIdProvider);
    final processingNotes = ref.watch(processingNotesProvider);
    final mode = ref.watch(appModeControllerProvider);
    final cs = ShadTheme.of(context).colorScheme;
    final service = ref.watch(transcriptionServiceProvider);
    final statusAsync = ref.watch(transcriptionStatusProvider);
    final currentStatus = statusAsync.asData?.value ?? TranscriptionStatus.idle;
    final isRecording = currentStatus == TranscriptionStatus.recording;
    final isPaused = currentStatus == TranscriptionStatus.paused;
    final isActive = isRecording || isPaused;

   // 笔记列表加载后如果没有选中项，自动选中第一条
   ref.listen(notesProvider, (_, next) {
     next.whenData((notes) {
       if (notes.isNotEmpty && ref.read(selectedNoteIdProvider) == null) {
         ref.read(selectedNoteIdProvider.notifier).set(notes.first.id);
       }
     });
   });
    // 选中笔记变更时手动失效片段列表（替代被移除的 ref.watch 依赖）
    ref.listen(selectedNoteIdProvider, (_, newId) {
      // 仅在选中非 null 笔记时失效（避免删除时 state→null 触发 segments 重建）
      if (newId != null) {
        ref.invalidate(selectedNoteSegmentsProvider);
      }
    });

    return Column(
      children: [
        _buildModeTabs(context, ref),
        if (mode == AppMode.asr) ...[
          Expanded(
            child: notesAsync.when(
              data: (notes) => notes.isEmpty
                  ? Center(
                      child: Text(
                        '暂无笔记',
                        style: TextStyle(
                          color: ShadTheme.of(
                            context,
                          ).colorScheme.custom['textTertiary']!,
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: notes.length,
                      buildDefaultDragHandles: false,
                      onReorderItem: (oldIndex, newIndex) {
                        final items = List<Note>.from(notes);
                        final moved = items.removeAt(oldIndex);
                        items.insert(newIndex, moved);
                        final entries = items
                            .asMap()
                            .entries
                            .map(
                              (e) => MapEntry(e.value.id, items.length - e.key),
                            )
                            .toList();
                        ref
                            .read(notesRepositoryProvider)
                            .updatePositions(entries);
                        ref.invalidate(notesProvider);
                      },
                      itemBuilder: (_, i) {
                        final note = notes[i];
                        final noteProgress = processingNotes[note.id]?.progress;
                        return ReorderableDragStartListener(
                          index: i,
                          key: ValueKey(note.id),
                          child: _buildNoteItem(
                            context,
                            note,
                            selectedId,
                            progress: noteProgress,
                            onTap: () {
                              appLog.d(
                                '[UI] 选中笔记: id=${note.id}, title=${note.title}',
                              );
                              ref.read(selectedNoteIdProvider.notifier).set(
note.id);
                            },
                            onDelete: () => _confirmDelete(context, ref, note),
                          ),
                        );
                      },
                    ),
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '加载中...',
                      style: TextStyle(
                        fontSize: 12,
                        color: ShadTheme.of(
                          context,
                        ).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error: $e',
                  style: TextStyle(
                    color: ShadTheme.of(context).colorScheme.destructive,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ShadButton(
                    leading: Icon(LucideIcons.plus, size: 14),
                    backgroundColor: cs.primary,
                    hoverBackgroundColor: cs.primary.withValues(alpha: 0.8),
                    child: Text(
                      isRecording ? '导入' : '导入音频',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _pickAndImport(context, ref),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShadButton(
                    leading: Icon(
                      isActive ? LucideIcons.square : LucideIcons.mic,
                      size: 14,
                    ),
                    backgroundColor: isActive
                        ? cs.destructive
                        : cs.custom["accentGreen"]!,
                    hoverBackgroundColor: isActive
                        ? cs.destructive.withValues(alpha: 0.8)
                        : cs.custom["accentGreen"]!.withValues(alpha: 0.8),
                    child: Text(
                      isActive ? '停止' : '录音',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      if (isActive) {
                        service.stopRecording().then((_) {
                          ref.invalidate(notesProvider);
                          ref.invalidate(selectedNoteSegmentsProvider);
                        });
                      } else {
                        service
                            .startRecording()
                            .then((_) {
                              ref.read(selectedNoteIdProvider.notifier).set(
service.currentNoteId);
                            })
                            .catchError((e) {
                              if (context.mounted) {
                                ShadToaster.of(context).show(
                                  ShadToast.destructive(
                                    description: const Text('录音启动失败'),
                                  ),
                                );
                              }
                            });
                      }
                    },
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isActive ? null : 0,
                  child: isActive
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child:
                              ShadButton(
                                    leading: Icon(
                                      isPaused
                                          ? LucideIcons.play
                                          : LucideIcons.pause,
                                      size: 14,
                                    ),
                                    onPressed: isRecording
                                        ? () => service.pauseRecording()
                                        : (isPaused
                                              ? () => service.resumeRecording()
                                              : null),
                                    child: Text(
                                      isPaused ? '继续' : '暂停',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    duration: 300.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slideX(
                                    begin: 0.3,
                                    end: 0,
                                    duration: 300.ms,
                                    curve: Curves.easeOut,
                                  ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ] else
          Expanded(child: TtsSidebarPanel()),
      ],
    );
  }

  /// [ASR] [TTS] 模式切换 — 使用 ShadTabs 和 ShadTheme 颜色
  Widget _buildModeTabs(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeControllerProvider);
    final cs = ShadTheme.of(context).colorScheme;

    return ShadTabs<AppMode>(
      value: mode,
      tabsGap: 4,
      padding: EdgeInsets.all(4),
      decoration: ShadDecoration(
        color: ShadTheme.of(context).colorScheme.custom["sidebarBg"],
        border: ShadBorder(bottom: ShadBorderSide(color: cs.border)),
      ),
      onChanged: (value) {
        ref.read(appModeControllerProvider.notifier).set(value);
      },
      tabs: [
        ShadTab<AppMode>(
          value: AppMode.asr,
          backgroundColor: cs.background,
          selectedBackgroundColor: cs.primary,
          hoverBackgroundColor: cs.background,
          foregroundColor: cs.foreground,
          selectedForegroundColor: cs.primaryForeground,
          child: Text(
            '语音识别',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        ShadTab<AppMode>(
          value: AppMode.tts,
          backgroundColor: cs.background,
          selectedBackgroundColor: cs.custom["accentGreen"],
          foregroundColor: cs.foreground,
          hoverBackgroundColor: cs.background,
          selectedForegroundColor: cs.primaryForeground,
          child: Text(
            '语音合成',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    Note note,
    String? selectedId, {
    required VoidCallback onTap,
    VoidCallback? onDelete,
    double? progress,
  }) {
    final isActive = note.id == selectedId;
    return NoteListItem(
      iconColor: ShadTheme.of(context).colorScheme.primary,
      title: note.title.isEmpty ? '未命名笔记' : note.title,
      subtitle: _fmtDate(note.createdAt),
      isActive: isActive,
      progress: progress,
      badgeText: note.status == NoteStatus.completed
          ? '已完成'
          : (note.status == NoteStatus.failed ? '转写失败' : '转写中'),
      badgeColor: note.status == NoteStatus.completed
          ? ShadTheme.of(context).colorScheme.custom['accentGreen']!
          : (note.status == NoteStatus.failed
                ? ShadTheme.of(context).colorScheme.destructive
                : Color(0xFFFF9F0A)),
      onTap: onTap,
      onDelete: onDelete,
    );
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (sameDay) return '今天 $time';
    return '${dt.month}月${dt.day}日 $time';
  }
}
