import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import '../../logger.dart';
import '../../providers/tts_provider.dart';
import '../../providers/notes_provider.dart';
import '../../database/repositories/tts_history_repository.dart';
import '../../services/tts_isolate.dart';
import '../../services/audio_storage_service.dart';
import '../../services/audio_playback_service.dart';
import '../settings/settings_window.dart';

/// TTS 文字转语音主界面
class TtsContent extends ConsumerStatefulWidget {
  const TtsContent({super.key});

  @override
  ConsumerState<TtsContent> createState() => _TtsContentState();
}

class _TtsContentState extends ConsumerState<TtsContent> {
  static const int _maxTtsChars = 1500;
  final _textController = TextEditingController();
  bool _initialLoaded = false;
  ShadSelectController<int>? _voiceSelectCtrl;
  final _voicePopoverCtrl = ShadPopoverController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _textController.text;
    if (text.length > _maxTtsChars) {
      _textController.text = text.substring(0, _maxTtsChars);
      _textController.selection = TextSelection.collapsed(offset: _maxTtsChars);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _voiceSelectCtrl?.dispose();
    _voicePopoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ttsOfflineEngineProvider);
    ref.listen<int>(ttsRenameRefreshProvider, (_, _) {
      final selectedId = ref.read(selectedTtsHistoryIdProvider);
      if (selectedId != null) {
        _loadHistoryRecord(selectedId);
      }
    });
    final voiceId = ref.watch(ttsSelectedVoiceIdProvider);
    final speed = ref.watch(ttsSpeedProvider);
    final isSynthesizing = ref.watch(ttsSynthesizingProvider);
    final outputPath = ref.watch(ttsOutputFilePathProvider);
    final engineAsync = ref.watch(ttsOfflineEngineProvider);
    final totalVoices = engineAsync.asData?.value?.numSpeakers ?? 1;
    ref.listen(selectedTtsHistoryIdProvider, (prev, next) {
      if (next != null) {
        _loadHistoryRecord(next);
      } else {
        _textController.clear();
        ref.read(ttsOutputFilePathProvider.notifier).set(null);
        ref.read(ttsSelectedVoiceIdProvider.notifier).set(0);
        ref.read(ttsSpeedProvider.notifier).set(1.0);
      }
    });

    // 初始加载：组件首次挂载时如果已有选中项，回显到右侧
    final currentSelectedId = ref.watch(selectedTtsHistoryIdProvider);
    if (currentSelectedId != null && !_initialLoaded) {
      _initialLoaded = true;
      Future.microtask(() => _loadHistoryRecord(currentSelectedId));
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('输入文本'),
          SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 减去 ShadInput 内部 padding 和边框的垂直空间
                final inputTheme = ShadTheme.of(context).inputTheme;
                final vPad =
                    (inputTheme.padding?.vertical ?? 16.0) +
                    (inputTheme.inputPadding?.vertical ?? 0);
                final h = (constraints.maxHeight - vPad - 2).clamp(
                  40.0,
                  constraints.maxHeight,
                );
                return ShadTextarea(
                  controller: _textController,
                  minHeight: h,
                  maxHeight: h,
                  resizable: false,
                  enabled: !isSynthesizing,
                  placeholder: const Text('输入要合成语音的文本...'),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                  decoration: ShadDecoration(
                    color: ShadTheme.of(context).colorScheme.background,
                  ),
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _textController,
            builder: (context, _) {
              final count = _textController.text.length;
              return Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    '$count / $_maxTtsChars',
                    style: TextStyle(
                      fontSize: 11,
                      color: count >= _maxTtsChars
                          ? ShadTheme.of(context).colorScheme.destructive
                          : ShadTheme.of(
                              context,
                            ).colorScheme.custom['textTertiary']!,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),

          _buildSectionHeader('合成参数'),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ShadTheme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 音色选择行
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over,
                      size: 14,
                      color: ShadTheme.of(
                        context,
                      ).colorScheme.custom['textTertiary']!,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '音色',
                      style: TextStyle(
                        fontSize: 13,
                        color: ShadTheme.of(context).colorScheme.foreground,
                      ),
                    ),
                    SizedBox(width: 8),
                    _buildVoiceSelector(
                      voiceId,
                      totalVoices,
                      enabled: !isSynthesizing,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // 语速滑杆
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 14,
                      color: ShadTheme.of(
                        context,
                      ).colorScheme.custom['textTertiary']!,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${speed.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontSize: 12,
                        color: ShadTheme.of(context).colorScheme.foreground,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: speed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        activeColor: ShadTheme.of(context).colorScheme.primary,
                        inactiveColor: ShadTheme.of(
                          context,
                        ).colorScheme.custom['titleBg']!,
                        onChanged: isSynthesizing
                            ? null
                            : (v) {
                                ref.read(ttsSpeedProvider.notifier).set(v);
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: isSynthesizing ? null : _doSynthesize,
              backgroundColor: ShadTheme.of(
                context,
              ).colorScheme.custom["accentGreen"],
              hoverBackgroundColor: ShadTheme.of(
                context,
              ).colorScheme.custom["accentGreen"]!.withValues(alpha: 0.8),
              leading: isSynthesizing
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(LucideIcons.audioLines, size: 16),
              child: Text(
                isSynthesizing
                    ? '合成中...'
                    : (ref.watch(selectedTtsHistoryIdProvider) != null
                          ? '重新合成'
                          : '合成语音'),
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 音色下拉选择器
  Widget _buildVoiceSelector(
    int currentVoiceId,
    int totalVoices, {
    bool enabled = true,
  }) {
    final theme = ShadTheme.of(context);
    final selectCtrl = ShadSelectController<int>(
      initialValue: {currentVoiceId},
    );
    return SizedBox(
      width: 180,
      child: ShadSelect<int>(
        controller: selectCtrl,
        popoverController: _voicePopoverCtrl,
        enabled: enabled,
        placeholder: const Text('选择音色', style: TextStyle(fontSize: 12)),
        selectedOptionBuilder: (context, value) => Text(
          '音色 #$value',
          style: TextStyle(fontSize: 12, color: theme.colorScheme.foreground),
        ),
        onChanged: (value) {
          if (value != null) {
            ref.read(ttsSelectedVoiceIdProvider.notifier).set(value);
          }
        },
        // onSearchChanged: (_) {},
        // searchPlaceholder: const Text('搜索音色...'),
        options: List.generate(totalVoices, (i) {
          final gender = i < totalVoices ~/ 2 ? '男声' : '女声';
          final isSelected = currentVoiceId == i;
          return GestureDetector(
            onTap: () {
              _voicePopoverCtrl.hide();
              ref.read(ttsSelectedVoiceIdProvider.notifier).set(i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8),
                      width: 6,
                      height: 6,
                      child: isSelected
                          ? Icon(
                              LucideIcons.check,
                              color: theme.colorScheme.primary,
                            )
                          : SizedBox(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      '音色 #$i',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ShadTheme.of(context).colorScheme.custom['textTertiary']!,
        letterSpacing: 0.05,
      ),
    );
  }

  // ---- 操作逻辑 ----
  Future<void> _loadHistoryRecord(String id) async {
    final repo = ref.read(ttsHistoryRepositoryProvider);
    final record = await repo.getById(id);
    if (record == null) return;
    _textController.text = record.text;
    ref.read(ttsSelectedVoiceIdProvider.notifier).set(record.voiceId);
    ref.read(ttsSpeedProvider.notifier).set(record.speed);
    if (record.audioFilePath != null) {
      ref.read(ttsOutputFilePathProvider.notifier).set(record.audioFilePath);
    }
  }

  Future<void> _doSynthesize() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ShadToaster.of(context).show(ShadToast(description: Text('请输入文本')));
      return;
    }

    final voiceId = ref.read(ttsSelectedVoiceIdProvider);
    final speed = ref.read(ttsSpeedProvider);

    ref.read(ttsSynthesizingProvider.notifier).set(true);
    // 停止当前播放再开始新合成
    await ref.read(audioPlaybackControllerProvider.notifier).stop();

    try {
      final appDir = await getApplicationSupportDirectory();
      final modelsDir = p.join(appDir.path, 'models', 'tts');

      // 检查模型文件
      if (!await File(
            p.join(modelsDir, 'vits-zh-hf-fanchen-C.onnx'),
          ).exists() ||
          !await File(p.join(modelsDir, 'tokens.txt')).exists()) {
        if (mounted) {
          _showModelMissingDialog();
        }
        return;
      }

      appLog.i(
        '[TTS] 开始合成（Isolate）: text="$text", voiceId=$voiceId, speed=$speed',
      );

      // 在后台 Isolate 中合成
      final audio = await synthesizeInIsolate(
        text: text,
        voiceId: voiceId,
        speed: speed,
        modelsDir: modelsDir,
      );

      if (audio.samples.isEmpty || audio.sampleRate <= 0) {
        throw Exception('合成结果为空');
      }

      // 生成记录 ID（后续作为文件名和 history 主键）
      final recordId = Uuid().v4();

      // 保存音频文件到 audios/tts_gen/
      final ttsDir = await AudioStorageService.ensureTtsAudioDir();
      final outPath = p.join(ttsDir, 'tts_$recordId.wav');

      writeWave(
        filename: outPath,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
      );

      appLog.i('[TTS] 合成成功，保存到: $outPath');

      // 保存到历史记录
      final repo = ref.read(ttsHistoryRepositoryProvider);
      await repo.create(
        TtsHistoryRecord(
          id: recordId,
          text: text,
          voiceId: voiceId,
          speed: speed,
          audioFilePath: outPath,
          createdAt: DateTime.now(),
        ),
      );

      ref.read(ttsOutputFilePathProvider.notifier).set(outPath);
      ref.read(selectedTtsHistoryIdProvider.notifier).set(recordId);
      ref.invalidate(ttsHistoryListProvider);

      if (mounted) {
        ShadToaster.of(context).show(ShadToast(description: Text('合成完成')));
      }
    } catch (e) {
      appLog.e('[TTS] 合成失败: $e');
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('合成失败: $e')));
      }
    } finally {
      ref.read(ttsSynthesizingProvider.notifier).set(false);
    }
  }

  void _showModelMissingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF2C2C2E),
        title: Text(
          '模型未下载',
          style: TextStyle(color: ShadTheme.of(context).colorScheme.foreground),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TTS 模型尚未下载。',
              style: TextStyle(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '请下载 TTS 模型后使用。',
              style: TextStyle(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              showDialog(context: context, builder: (_) => SettingsWindow());
            },
            child: Text('打开设置'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('取消')),
        ],
      ),
    );
  }

  Future<void> _exportAudio(String filePath) async {
    final textPreview = _textController.text.trim();
    final suggestedName = textPreview.isNotEmpty
        ? '${textPreview.substring(0, textPreview.length.clamp(0, 30))}.wav'
        : 'tts_gen.wav';

    final result = await FileSelectorPlatform.instance.getSaveLocation(
      acceptedTypeGroups: [
        XTypeGroup(label: 'WAV 音频', extensions: ['wav']),
      ],
      options: SaveDialogOptions(suggestedName: suggestedName),
    );

    final dest = result?.path;
    if (dest == null) return;

    try {
      await File(filePath).copy(dest);
      if (mounted) {
        ShadToaster.of(context).show(ShadToast(description: Text('导出成功')));
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('导出失败: $e')));
      }
    }
  }
}
