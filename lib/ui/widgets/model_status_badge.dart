import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../providers/transcription_provider.dart';

/// 模型状态徽章 — 显示 ASR 引擎与 TTS 引擎的就绪状态
class ModelStatusBadge extends ConsumerStatefulWidget {
  const ModelStatusBadge({super.key});

  @override
  ConsumerState<ModelStatusBadge> createState() => _ModelStatusBadgeState();
}

class _ModelStatusBadgeState extends ConsumerState<ModelStatusBadge> {
  bool _asrReady = false;
  bool _ttsReady = false;
  String? _modelsDir;

  @override
  void initState() {
    super.initState();
    _initAndCheck();
  }

  Future<void> _initAndCheck() async {
    final appDir = await getApplicationSupportDirectory();
    _modelsDir = p.join(appDir.path, 'models');
    _checkModels();
  }

  void _checkModels() {
    final dir = _modelsDir;
    if (dir == null) return;

    // ASR：需要 SenseVoice（非流式）+ Zipformer（流式）模型文件完整
    final asr =
        File(p.join(dir, 'asr-nonstreaming', 'model.int8.onnx')).existsSync() &&
        File(p.join(dir, 'asr-nonstreaming', 'tokens.txt')).existsSync() &&
        File(p.join(dir, 'asr-streaming', 'encoder.int8.onnx')).existsSync() &&
        File(p.join(dir, 'asr-streaming', 'tokens.txt')).existsSync();

    // TTS：需要 VITS 模型文件完整
    final tts =
        File(p.join(dir, 'tts', 'vits-zh-hf-fanchen-C.onnx')).existsSync() &&
        File(p.join(dir, 'tts', 'tokens.txt')).existsSync();

    if (mounted) {
      setState(() {
        _asrReady = asr;
        _ttsReady = tts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 模型文件刷新时重新检测
    ref.watch(modelRefreshProvider);
    ref.listen<int>(modelRefreshProvider, (_, _) => _checkModels());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusDot('ASR 引擎', _asrReady),
        SizedBox(width: 8),
        _statusDot('TTS 引擎', _ttsReady),
      ],
    );
  }

  Widget _statusDot(String label, bool ready) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.custom['titleBg']!,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: ready
                ? ShadTheme.of(context).colorScheme.custom['accentGreen']!
                : ShadTheme.of(context).colorScheme.destructive,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: ready
                  ? ShadTheme.of(context).colorScheme.custom['accentGreen']!
                  : ShadTheme.of(context).colorScheme.destructive,
            ),
          ),
        ],
      ),
    );
  }
}
