import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../logger.dart';
import '../database/repositories/tts_history_repository.dart';
import 'transcription_provider.dart';
import 'notes_provider.dart';

part 'tts_provider.g.dart';

/// 当前选中的 TTS 音色 ID
@riverpod
class TtsSelectedVoiceId extends _$TtsSelectedVoiceId {
  @override
  int build() => 0;

  void set(int id) => state = id;
}

/// 语速倍数（0.5 - 2.0）
@riverpod
class TtsSpeed extends _$TtsSpeed {
  @override
  double build() => 1.0;

  void set(double speed) => state = speed;
}

/// 是否正在合成
@riverpod
class TtsSynthesizing extends _$TtsSynthesizing {
  @override
  bool build() => false;

  void set(bool synthesizing) => state = synthesizing;
}

/// 合成结果的文件路径（由 TTS 服务写入临时文件后供播放器使用）
@riverpod
class TtsOutputFilePath extends _$TtsOutputFilePath {
  @override
  String? build() => null;

  void set(String? path) => state = path;
}

/// TTS 历史仓库提供器
@riverpod
TtsHistoryRepository ttsHistoryRepository(Ref ref) {
  return TtsHistoryRepository(ref.watch(appDatabaseProvider));
}

/// TTS 历史记录列表（异步 — 每次 invalidate 都会重新查询数据库）
@riverpod
Future<List<TtsHistoryRecord>> ttsHistoryList(Ref ref) async {
  appLog.d('[TtsProvider] 刷新历史列表');
  return ref.watch(ttsHistoryRepositoryProvider).getAll();
}

/// 当前选中的 TTS 历史记录 ID
@riverpod
class SelectedTtsHistoryId extends _$SelectedTtsHistoryId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

/// TTS 重命名刷新触发器（递增时右侧重新加载当前记录）
@riverpod
class TtsRenameRefresh extends _$TtsRenameRefresh {
  @override
  int build() => 0;

  void increment() => state++;
}

/// 异步加载 TTS 引擎，模型文件就绪时返回 OfflineTts 实例
@riverpod
Future<OfflineTts?> ttsOfflineEngine(Ref ref) async {
  ref.watch(modelRefreshProvider);
  try {
    final appDir = await getApplicationSupportDirectory();
    final modelsDir = p.join(appDir.path, 'models', 'tts');
    final lexiconFile = p.join(modelsDir, 'lexicon.txt');
    final dictDir = p.join(modelsDir, 'dict');
    final modelFile = p.join(modelsDir, 'vits-zh-hf-fanchen-C.onnx');
    final tokensFile = p.join(modelsDir, 'tokens.txt');
    final ruleFsts = [
      p.join(modelsDir, 'date.fst'),
      p.join(modelsDir, 'number.fst'),
      p.join(modelsDir, 'phone.fst'),
      p.join(modelsDir, 'new_heteronym.fst'),
    ].join(',');

    final modelExists = await File(modelFile).exists();
    final tokensExist = await File(tokensFile).exists();

    if (!modelExists || !tokensExist) {
      appLog.d('[TTS] 模型文件不完整，引擎暂不可用');
      return null;
    }

    initBindings();

    final tts = OfflineTts(
      OfflineTtsConfig(
        ruleFsts: ruleFsts,
        model: OfflineTtsModelConfig(
          vits: OfflineTtsVitsModelConfig(
            model: modelFile,
            tokens: tokensFile,
            lexicon: lexiconFile,
            dictDir: dictDir,
          ),
          numThreads: 2,
          provider: 'coreml',
        ),
      ),
    );

    appLog.i('[TTS] 引擎初始化成功, 内置音色数: ${tts.numSpeakers}');
    return tts;
  } catch (e) {
    appLog.e('[TTS] 引擎初始化失败: $e');
    return null;
  }
}
