import 'dart:async';
import 'dart:io';
import '../../logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import '../../providers/transcription_provider.dart';
import '../../providers/notes_provider.dart';
import '../widgets/waveform_painter.dart';
import '../../providers/app_mode_provider.dart';
import '../../providers/tts_provider.dart';
import '../../services/transcription_service.dart';
import '../../services/audio_playback_service.dart';

/// 底部工具栏：录音控制 + 引擎状态 + 音频播放器
class BottomToolbar extends ConsumerStatefulWidget {
  const BottomToolbar({super.key});

  @override
  ConsumerState<BottomToolbar> createState() => _BottomToolbarState();
}

class _BottomToolbarState extends ConsumerState<BottomToolbar> {
  @override
  void initState() {
    super.initState();
  }

  String _fmtPos(Duration d) {
    final totalSecs = d.inSeconds;
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedNoteIdProvider);
    final notesAsync = ref.watch(notesProvider);
    final audioCtrl = ref.watch(audioPlaybackControllerProvider);
    final audioState = audioCtrl;
    final hasAudio = audioState.hasAudio;
    final mode = ref.watch(appModeControllerProvider);
    final selectedTtsId = ref.watch(selectedTtsHistoryIdProvider);
    final ttsHistoryAsync = ref.watch(ttsHistoryListProvider);

    // 检查当前选中记录是否真的有可用音频文件
    bool hasActualAudio = false;
    if (mode == AppMode.asr) {
      if (selectedId != null && notesAsync.hasValue) {
        final note = notesAsync.requireValue
            .where((n) => n.id == selectedId)
            .firstOrNull;
        hasActualAudio =
            note?.audioFilePath != null &&
            File(note!.audioFilePath!).existsSync();
      }
    } else {
      if (selectedTtsId != null) {
        final records = ttsHistoryAsync.asData?.value ?? [];
        final record = records.where((r) => r.id == selectedTtsId).firstOrNull;
        hasActualAudio =
            record?.audioFilePath != null &&
            File(record!.audioFilePath!).existsSync();
      }
    }
    final ttsPath = ref.watch(ttsOutputFilePathProvider);

    // 当笔记数据变化且有音频文件可用时，自动加载到播放器
    if (mode == AppMode.asr && selectedId != null && notesAsync.hasValue) {
      final notes = notesAsync.requireValue;
      final note = notes.where((n) => n.id == selectedId).firstOrNull;
      if (note?.audioFilePath != null &&
          audioCtrl.filePath != note!.audioFilePath) {
        Future.microtask(() {
          if (mounted) {
            ref.read(audioPlaybackControllerProvider.notifier).loadFile(note.audioFilePath!);
          }
        });
      }
    }
    // TTS 模式下自动加载合成音频
    if (mode == AppMode.tts &&
        ttsPath != null &&
        audioCtrl.filePath != ttsPath) {
      Future.microtask(() {
        if (mounted) {
          ref.read(audioPlaybackControllerProvider.notifier).loadFile(ttsPath);
        }
      });
    }

    final statusAsync = ref.watch(transcriptionStatusProvider);
    final currentStatus = statusAsync.asData?.value ?? TranscriptionStatus.idle;
    final isRecording = currentStatus == TranscriptionStatus.recording;
    final isPaused = currentStatus == TranscriptionStatus.paused;
    final isActive = isRecording || isPaused;
    final wfAsync = ref.watch(waveformProvider);
    final waveformAmplitudes = wfAsync.asData?.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.custom['toolbarBg']!,
        border: Border(
          top: BorderSide(color: ShadTheme.of(context).colorScheme.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Recording controls + status
          SizedBox(
            height: 44,
            child: Row(
              children: [
                if (isActive)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: CustomPaint(
                          painter: WaveformPainter(
                            amplitudes: waveformAmplitudes,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isActive && hasActualAudio)
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          SizedBox(width: 16),
                          SizedBox(
                            width: 60,
                            child: Text(
                              hasAudio ? _fmtPos(audioState.position) : '00:00',
                              textAlign: .center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                                color: hasAudio
                                    ? ShadTheme.of(
                                        context,
                                      ).colorScheme.mutedForeground
                                    : ShadTheme.of(
                                        context,
                                      ).colorScheme.custom['textTertiary']!,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: RoundSliderOverlayShape(
                                  overlayRadius: 12,
                                ),
                                activeTrackColor: ShadTheme.of(
                                  context,
                                ).colorScheme.primary,
                                inactiveTrackColor: Color(0xFF2C2C2E),
                                thumbColor: ShadTheme.of(
                                  context,
                                ).colorScheme.primary,
                                overlayColor: ShadTheme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.12),
                              ),
                              child: Slider(
                                value:
                                    hasAudio &&
                                        audioState.duration.inMilliseconds > 0
                                    ? audioState.position.inMilliseconds
                                          .toDouble()
                                          .clamp(
                                            0.0,
                                            audioState.duration.inMilliseconds
                                                .toDouble(),
                                          )
                                    : 0.0,
                                min: 0.0,
                                max:
                                    hasAudio &&
                                        audioState.duration.inMilliseconds > 0
                                    ? audioState.duration.inMilliseconds
                                          .toDouble()
                                    : 1.0,
                                activeColor: ShadTheme.of(
                                  context,
                                ).colorScheme.primary,
                                inactiveColor: ShadTheme.of(
                                  context,
                                ).colorScheme.custom['titleBg']!,
                                onChanged: (value) {},
                                onChangeEnd: (value) {
                                  if (hasAudio) {
                                    appLog.d('[UI] 拖动播放进度: ${value.toInt()}ms');
                                    ref.read(audioPlaybackControllerProvider.notifier).seek(
                                      Duration(milliseconds: value.toInt()),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              hasAudio ? _fmtPos(audioState.duration) : '00:00',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'monospace',
                                color: hasAudio
                                    ? ShadTheme.of(
                                        context,
                                      ).colorScheme.mutedForeground
                                    : ShadTheme.of(
                                        context,
                                      ).colorScheme.custom['textTertiary']!,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: ShadButton.ghost(
                              padding: EdgeInsets.zero,
                              leading: Icon(
                                hasAudio
                                    ? (audioState.isPlaying
                                          ? LucideIcons.pause
                                          : LucideIcons.play)
                                    : LucideIcons.play,
                                size: 22,
                                color: hasAudio
                                    ? ShadTheme.of(
                                        context,
                                      ).colorScheme.foreground
                                    : ShadTheme.of(
                                        context,
                                      ).colorScheme.custom['textTertiary']!,
                              ),
                              onPressed: hasAudio
                                  ? () {
                                      appLog.d(
                                        '[UI] ${audioState.isPlaying ? "暂停" : "播放"}',
                                      );
                                      ref.read(audioPlaybackControllerProvider.notifier).togglePlayPause();
                                    }
                                  : null,
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                if (hasActualAudio)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      leading: Icon(
                        LucideIcons.arrowBigDownDash,
                        size: 22,
                        color: ShadTheme.of(context).colorScheme.foreground,
                      ),
                      onPressed: _downloadAudio,
                    ),
                  ),
                SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAudio() async {
    final audioCtrl = ref.read(audioPlaybackControllerProvider);
    final filePath = audioCtrl.filePath;
    if (filePath == null || filePath.isEmpty) return;

    // 根据当前模式从 sidebar 选中项获取标题作为默认文件名
    final mode = ref.read(appModeControllerProvider);
    String suggestedName;
    if (mode == AppMode.asr) {
      final selectedId = ref.read(selectedNoteIdProvider);
      if (selectedId != null) {
        final notes = ref.read(notesProvider).asData?.value ?? [];
        final note = notes.where((n) => n.id == selectedId).firstOrNull;
        suggestedName = '${note?.title ?? '音频'}.wav';
      } else {
        suggestedName = '音频.wav';
      }
    } else {
      final selectedTtsId = ref.read(selectedTtsHistoryIdProvider);
      if (selectedTtsId != null) {
        final records = ref.read(ttsHistoryListProvider).asData?.value ?? [];
        final record = records.where((r) => r.id == selectedTtsId).firstOrNull;
        final title = record?.text;
        if (title != null && title.isNotEmpty) {
          final clean = title.replaceAll(RegExp(r'[/\\:*?"<>|]'), ' ').trim();
          suggestedName =
              '${clean.substring(0, clean.length.clamp(0, 50))}.wav';
        } else {
          suggestedName = 'TTS 输出.wav';
        }
      } else {
        suggestedName = 'TTS 输出.wav';
      }
    }

    final result = await FileSelectorPlatform.instance.getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: 'WAV 音频', extensions: ['wav']),
      ],
      options: SaveDialogOptions(suggestedName: suggestedName),
    );
    final path = result?.path;
    if (path == null) return;

    try {
      await File(filePath).copy(path);
      if (context.mounted) {
        ShadToaster.of(context).show(ShadToast(description: Text('音频下载成功')));
      }
    } catch (e) {
      if (context.mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('下载失败: $e')));
      }
    }
  }
}
