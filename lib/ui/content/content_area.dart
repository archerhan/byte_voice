import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../services/engine_isolate.dart';
import '../../models/note.dart';
import '../../models/note_status.dart';
import '../../models/segment.dart';
import '../../providers/notes_provider.dart';
import '../../services/export_service.dart';
import '../../services/transcription_service.dart';
import '../../providers/transcription_provider.dart';
import '../../providers/app_mode_provider.dart';
import '../../services/audio_playback_service.dart';
import 'empty_state.dart';
import 'note_detail.dart';
import 'transcript_stream.dart';
import 'tts_content.dart';

/// 内容区域 — 根据选中笔记显示详情或空状态
class ContentArea extends ConsumerWidget {
  const ContentArea({super.key});

  /// 导出 TXT 文件
  Future<void> _exportTxt(
    BuildContext context,
    WidgetRef ref,
    Note note,
    List<Segment> segments,
  ) async {
    final result = await FileSelectorPlatform.instance.getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: '文本文件', extensions: ['txt']),
      ],
      options: SaveDialogOptions(suggestedName: '${note.title}.txt'),
    );
    final path = result?.path;
    if (path == null) return;

    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.exportToFile(note, segments, ExportFormat.txt, path);
      if (context.mounted) {
        appLog.i('[UI] TXT 导出成功: $path');
        ShadToaster.of(context).show(ShadToast(description: Text('导出成功')));
      }
    } catch (e) {
      if (context.mounted) {
        appLog.e('[UI] TXT 导出失败: $e');
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('导出失败: $e')));
      }
    }
  }

  /// 导出 SRT 字幕文件
  Future<void> _exportSrt(
    BuildContext context,
    WidgetRef ref,
    Note note,
    List<Segment> segments,
  ) async {
    final file = await FileSelectorPlatform.instance.getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: 'SRT 字幕', extensions: ['srt']),
      ],
      options: SaveDialogOptions(suggestedName: '${note.title}.srt'),
    );
    final path = file?.path;
    if (path == null) return;

    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.exportToFile(note, segments, ExportFormat.srt, path);
      if (context.mounted) {
        appLog.i('[UI] SRT 导出成功: $path');
        ShadToaster.of(context).show(ShadToast(description: Text('SRT 导出成功')));
      }
    } catch (e) {
      if (context.mounted) {
        appLog.e('[UI] SRT 导出失败: $e');
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('SRT 导出失败: $e')));
      }
    }
  }

  /// 重新识别 — 清空旧片段后重新用引擎处理音频
  Future<void> _reRecognize(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final audioPath = note.audioFilePath;
    if (audioPath == null) {
      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('没有可识别的音频')));
      }
      return;
    }

    if (!File(audioPath).existsSync()) {
      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('音频文件不存在')));
      }
      return;
    }

    // 删除旧片段
    final segmentsRepo = ref.read(segmentsRepositoryProvider);
    await segmentsRepo.deleteByNoteId(note.id);
    ref.invalidate(selectedNoteSegmentsProvider);

    // 检查模型文件
    final appDir = await getApplicationSupportDirectory();
    final modelsDir = p.join(appDir.path, 'models');
    final vadFile = p.join(modelsDir, 'vad', 'silero_vad.onnx');
    final svFile = p.join(modelsDir, 'asr-nonstreaming', 'model.int8.onnx');
    final tokensFile = p.join(modelsDir, 'asr-nonstreaming', 'tokens.txt');
    final punctFile = p.join(modelsDir, 'punct', 'model.int8.onnx');

    if (!File(vadFile).existsSync() || !File(svFile).existsSync()) {
      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('模型文件缺失，请先在设置中下载')));
      }
      return;
    }

    // 设置进度显示
    ref.read(processingNotesProvider.notifier).update((state) {
      return {
        ...state,
        note.id: ProcessingState(message: '正在转写 ${note.title}...'),
      };
    });

    // 更新笔记状态为转写中
    final notesRepo = ref.read(notesRepositoryProvider);
    await notesRepo.update(note.copyWith(status: NoteStatus.transcribing));
    ref.invalidate(notesProvider);

    try {
      final segments = await processInIsolate(
        audioPath: audioPath,
        sileroVadModel: vadFile,
        senseVoiceModel: svFile,
        tokensFile: tokensFile,
        punctuationModel: File(punctFile).existsSync() ? punctFile : null,
        onProgress: (p) {
          ref.read(processingNotesProvider.notifier).update((state) {
            return {
              ...state,
              note.id: ProcessingState(
                message: '正在转写 ${note.title}...',
                progress: p,
              ),
            };
          });
        },
      );

      // 保存新片段
      final dbSegments = segments.asMap().entries.map((e) {
        final seg = e.value;
        return Segment(
          id: Uuid().v4(),
          noteId: note.id,
          startMs: seg.startMs,
          endMs: seg.endMs,
          text: seg.text,
          sortIndex: e.key,
        );
      }).toList();

      if (dbSegments.isNotEmpty) {
        await segmentsRepo.bulkInsert(dbSegments);
      }

      final durationMs = segments.isEmpty ? 0 : segments.last.endMs;
      await notesRepo.update(
        Note(
          id: note.id,
          title: note.title,
          durationMs: durationMs,
          audioFilePath: audioPath,
          keepAudio: true,
          source: note.source,
          status: NoteStatus.completed,
        ),
      );

      ref.invalidate(notesProvider);
      ref.invalidate(selectedNoteSegmentsProvider);

      ref.read(processingNotesProvider.notifier).update((state) {
        final newState = Map<String, ProcessingState>.from(state);
        newState.remove(note.id);
        return newState;
      });

      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('重新识别完成: ${segments.length} 个片段')));
      }
    } catch (e) {
      await notesRepo.update(note.copyWith(status: NoteStatus.failed));
      ref.invalidate(notesProvider);

      ref.read(processingNotesProvider.notifier).update((state) {
        final newState = Map<String, ProcessingState>.from(state);
        newState.remove(note.id);
        return newState;
      });

      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('识别失败: $e')));
      }
    }
  }

  static const _skeletonTexts = [
    '正在加载转写文本内容，请稍候...',
    '这是一段示例文本内容用于骨架屏展示',
    '加载中...',
    '转写文本片段示例，这里显示具体的文字内容',
    '这里显示具体的文字内容，正在处理中请稍候',
  ];

  Widget _buildTranscriptSkeleton(BuildContext context) {
    final borderColor = ShadTheme.of(context).colorScheme.border;
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          // Title bar
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '笔记标题加载中',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Row(
                  children: [
                    Text('导出 TXT', style: TextStyle(fontSize: 11)),
                    SizedBox(width: 8),
                    Text('重新识别', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          // Header row
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    '开始时间',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    '结束时间',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    '内容',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Segment rows
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: 12,
              itemBuilder: (context, index) {
                return _buildSkeletonSegmentRow(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonSegmentRow(int index) {
    final text = _skeletonTexts[index % _skeletonTexts.length];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '00:00.000',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              '00:00.000',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeControllerProvider);
    if (mode == AppMode.tts) {
      return TtsContent();
    }

    final status = ref.watch(transcriptionStatusProvider);
    final currentStatus = status.asData?.value;
    final isActive =
        currentStatus == TranscriptionStatus.recording ||
        currentStatus == TranscriptionStatus.processing;
    if (isActive) {
      return Stack(
        children: [
          TranscriptStream(),
          if (currentStatus == TranscriptionStatus.processing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
        ],
      );
    }

    final selectedId = ref.watch(selectedNoteIdProvider);
    if (selectedId == null) return EmptyState();

    final processingNotes = ref.watch(processingNotesProvider);
    final segmentsAsync = ref.watch(selectedNoteSegmentsProvider);
    final notesAsync = ref.watch(notesProvider);

    return segmentsAsync.when(
      data: (segments) {
        if (processingNotes.containsKey(selectedId)) {
          return _buildTranscriptSkeleton(context);
        }
        return notesAsync.when(
          data: (notes) {
            final note = notes.where((n) => n.id == selectedId).firstOrNull;
            if (note == null) return EmptyState();
            return NoteDetail(
              note: note,
              segments: segments,
              onExport: () => _exportTxt(context, ref, note, segments),
              onExportSrt: () => _exportSrt(context, ref, note, segments),
              onReRecognize: () => _reRecognize(context, ref, note),
              onSegmentTap: (startMs) {
                ref.read(audioPlaybackControllerProvider.notifier).playFromMs(startMs);
              },
            );
          },
          loading: () => _buildTranscriptSkeleton(context),
          error: (e, _) => Center(
            child: Text(
              '$e',
              style: TextStyle(
                color: ShadTheme.of(context).colorScheme.destructive,
              ),
            ),
          ),
        );
      },
      loading: () => _buildTranscriptSkeleton(context),
      error: (e, _) => Center(
        child: Text(
          '$e',
          style: TextStyle(
            color: ShadTheme.of(context).colorScheme.destructive,
          ),
        ),
      ),
    );
  }
}
