// ignore_for_file: use_build_context_synchronously

import 'package:byte_voice/ui/toolbar/bottom_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../logger.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../models/note.dart';
import '../models/note_status.dart';
import '../models/segment.dart';
import '../providers/notes_provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_import_service.dart';
import '../services/engine_isolate.dart';
import '../services/audio_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'sidebar/sidebar_panel.dart';
import 'content/content_area.dart';
import 'widgets/sidebar_bottom_bar.dart';
import '../services/model_download_service.dart';
import 'settings/settings_window.dart';

/// 处理文件导入流程：创建笔记、解码 WAV、后台 Isolate 转写、保存结果
Future<void> _doImport(
  WidgetRef ref,
  String filePath,
  String fileName,
  BuildContext context,
) async {
  final notesRepo = ref.read(notesRepositoryProvider);
  final segmentsRepo = ref.read(segmentsRepositoryProvider);
  final noteTitle = p.basenameWithoutExtension(fileName);
  final noteId = Uuid().v4();

  // 1. 立即创建笔记，显示在侧边栏（转写中）
  await notesRepo.create(
    Note(
      id: noteId,
      title: noteTitle,
      source: NoteSource.import,
      status: NoteStatus.transcribing,
    ),
  );
  ref.invalidate(notesProvider);
  ref.read(selectedNoteIdProvider.notifier).set(noteId);

  ShadToaster.of(context).show(ShadToast(description: Text('已创建笔记，后台转写中...')));
  String? permanentWavPath;

  try {
    // 2. 获取沙盒路径
    final appDir = await getApplicationSupportDirectory();

    // 3. 解码为 WAV（使用 ffmpeg，与模型无关）
    final ext = p.extension(filePath).toLowerCase();
    final wavPath = ext == '.wav'
        ? filePath
        : await ref.read(audioImportServiceProvider).decodeToWav(filePath);

    // 4. 先保存 WAV 到沙盒永久目录（优先于模型检查，确保音频文件被保留）
    permanentWavPath = await AudioStorageService.saveImportedAudio(
      noteId: noteId,
      wavFilePath: wavPath,
    );

    // 5. 模型完整性检查
    final mDir = p.join(appDir.path, 'models');
    final vadFile = p.join(mDir, 'vad', 'silero_vad.onnx');
    final svFile = p.join(mDir, 'asr-nonstreaming', 'model.int8.onnx');
    final tokensFile = p.join(mDir, 'asr-nonstreaming', 'tokens.txt');
    final punctFile = p.join(mDir, 'punct', 'model.int8.onnx');
    if (!await File(vadFile).exists() || !await File(svFile).exists()) {
      throw Exception('模型文件缺失，请先在设置中下载');
    }

    // 6. 后台 Isolate 转写
    // ================== 修改 1：初始化转写状态 ==================
    ref.read(processingNotesProvider.notifier).update((state) {
      // 展开旧 state，合并新的 key-value，生成全新 Map
      return {...state, noteId: ProcessingState(message: '正在转写 $noteTitle...')};
    });
    final punctExists = await File(punctFile).exists();
    final segments = await processInIsolate(
      audioPath: wavPath,
      sileroVadModel: vadFile,
      senseVoiceModel: svFile,
      tokensFile: tokensFile,
      punctuationModel: punctExists ? punctFile : null,
      onProgress: (p) =>
          // ================== 修改 2：更新实时进度 ==================
          ref.read(processingNotesProvider.notifier).update((state) {
            return {
              ...state,
              noteId: ProcessingState(
                message: '正在转写 $noteTitle...',
                progress: p,
              ),
            };
          }),
    );

    // 5. 保存片段 + 更新笔记状态
    final durationMs = segments.isEmpty ? 0 : segments.last.endMs;
    final dbSegments = segments
        .asMap()
        .entries
        .map(
          (e) => Segment(
            id: Uuid().v4(),
            noteId: noteId,
            startMs: e.value.startMs,
            endMs: e.value.endMs,
            text: e.value.text,
            sortIndex: e.key,
          ),
        )
        .toList();
    await segmentsRepo.bulkInsert(dbSegments);
    ref.invalidate(selectedNoteSegmentsProvider);
    await notesRepo.update(
      Note(
        id: noteId,
        title: noteTitle,
        durationMs: durationMs,
        audioFilePath: permanentWavPath,
        keepAudio: true,
        source: NoteSource.import,
        status: NoteStatus.completed,
      ),
    );
    ref.invalidate(notesProvider);
    // ================== 修改 3：成功完成时移除进度 ==================
    ref.read(processingNotesProvider.notifier).update((state) {
      final newState = Map<String, ProcessingState>.from(state);
      newState.remove(noteId);
      return newState;
    });

    ShadToaster.of(
      context,
    ).show(ShadToast(description: Text('转写完成: ${segments.length} 个片段')));
  } catch (e) {
    // ================== 修改 4：报错失败时移除进度 ==================
    ref.read(processingNotesProvider.notifier).update((state) {
      final newState = Map<String, ProcessingState>.from(state);
      newState.remove(noteId);
      return newState;
    });
    await notesRepo.update(
      Note(
        id: noteId,
        title: noteTitle,
        audioFilePath: permanentWavPath,
        source: NoteSource.import,
        status: NoteStatus.failed,
      ),
    );
    ref.invalidate(notesProvider);
    ShadToaster.of(
      context,
    ).show(ShadToast.destructive(description: Text('转写出错: $e')));
  }
}

/// 主窗口 — 应用顶层布局容器
class MainWindow extends ConsumerStatefulWidget {
  const MainWindow({super.key});

  @override
  ConsumerState<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends ConsumerState<MainWindow> {
  bool _startupChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkModelsOnStartup());
  }

  /// 启动时检查模型完整性，不完整则弹出引导对话框
  Future<void> _checkModelsOnStartup() async {
    if (_startupChecked) return;
    _startupChecked = true;

    final svc = ref.read(modelDownloadServiceProvider);
    // 等待 Manifest 加载
    for (int i = 0; i < 30; i++) {
      if (svc.isManifestLoaded &&
          svc.models.isNotEmpty &&
          svc.models.every((m) => svc.states.containsKey(m.key))) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;

    final allReady = svc.models.isNotEmpty &&
        svc.states.isNotEmpty &&
        svc.models.length == svc.states.length &&
        svc.models.every(
          (m) => svc.states[m.key] == ModelDownloadState.downloaded,
        );
    if (allReady) return;

    // 对话框 1：下载模型
    if (!mounted) return;
    final download = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('下载模型'),
        description: const Text(
          '本应用需要搭配本地语音大模型一起使用，预计需要下载 500M 的模型数据。',
        ),
        actions: [
          ShadButton.destructive(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('下载'),
          ),
        ],
      ),
    );

    if (download == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const SettingsWindow(initialTab: 1, autoDownload: true),
      );
      return;
    }

    // 对话框 2：温馨提示
    if (!mounted) return;
    final downloadAnyway = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ShadDialog.alert(
        title: const Text('温馨提示'),
        description: const Text(
          '如果不下载语音模型，应用将无法正常使用！',
        ),
        actions: [
          ShadButton.destructive(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('稍后下载'),
          ),
          ShadButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('现在下载'),
          ),
        ],
      ),
    );

    if (downloadAnyway == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const SettingsWindow(initialTab: 1, autoDownload: true),
      );
    }
  }

  /// 打开设置窗口
  void _showSettings(BuildContext context) {
    appLog.d('[UI] 打开设置窗口');
    showDialog(context: context, builder: (_) => const SettingsWindow());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DropTarget(
        onDragDone: (detail) {
          appLog.i('[UI] 拖入 ${detail.files.length} 个文件');
          for (final file in detail.files) {
            final ext = p.extension(file.path).toLowerCase().substring(1);
            if (!AudioImportService.supportedExtensions.contains(ext)) {
              appLog.w('[UI] 不支持的拖入格式: .$ext');
              ShadToaster.of(
                context,
              ).show(ShadToast(description: Text('不支持 .$ext 格式')));
              continue;
            }
            _doImport(ref, file.path, file.name, context);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: ShadResizablePanelGroup(
                axis: Axis.horizontal,
                showHandle: false,
                dividerSize: 1,
                handlePadding: .zero,
                handleSize: 0,
                dividerThickness: 1,
                children: [
                  ShadResizablePanel(
                    id: 'sidebar',
                    defaultSize: 0.35,
                    minSize: 0.35,
                    maxSize: 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 28,
                          child: Container(
                            color: ShadTheme.of(context).colorScheme.background,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: ShadTheme.of(context).colorScheme.background,
                            child: SidebarPanel(),
                          ),
                        ),
                        ShadSeparator.horizontal(thickness: 1, margin: .zero),
                        GestureDetector(
                          onTap: () => _showSettings(context),
                          child: const SidebarBottomBar(),
                        ),
                      ],
                    ),
                  ),
                  ShadResizablePanel(
                    id: 'content',
                    defaultSize: 0.65,
                    minSize: 0.5,
                    maxSize: 0.65,
                    child: Container(
                      color: ShadTheme.of(context).colorScheme.card,
                      child: Column(
                        children: [
                          Expanded(child: ContentArea()),
                          BottomToolbar(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
