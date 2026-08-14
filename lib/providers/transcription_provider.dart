/// 转录相关 Riverpod 状态管理
library;

import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../logger.dart';
import '../services/transcription_service.dart';
import '../services/engine_service.dart';
import 'notes_provider.dart';

part 'transcription_provider.g.dart';

/// 模型文件刷新触发器 — 值递增时引擎提供器重新检测文件
@riverpod
class ModelRefresh extends _$ModelRefresh {
  @override
  int build() => 0;

  void increment() => state++;
}

/// 检测磁盘上已下载的模型文件，创建引擎（异步）
@riverpod
Future<SherpaOnnxEngine?> sherpaOnnxEngine(Ref ref) async {
  ref.watch(modelRefreshProvider); // 模型文件变动时自动重新检查
  try {
    final appDir = await getApplicationSupportDirectory();
    final modelsDir = p.join(appDir.path, 'models');

    final vadFile = p.join(modelsDir, 'vad', 'silero_vad.onnx');
    final svDir = p.join(modelsDir, 'asr-nonstreaming');
    final svModelFile = p.join(svDir, 'model.int8.onnx');
    final tokensFile = p.join(svDir, 'tokens.txt');

    // 2. 流式模型路径 (Zipformer)
    // 提示：不同压缩包解压后的 .onnx 文件名可能有微小区别（比如有没有 .int8），请根据实际解压目录确认
    final zipDir = p.join(modelsDir, 'asr-streaming');
    final encoderFile = p.join(zipDir, 'encoder.int8.onnx');
    final decoderFile = p.join(zipDir, 'decoder.onnx');
    final joinerFile = p.join(zipDir, 'joiner.int8.onnx');
    final onlineTokens = p.join(zipDir, 'tokens.txt');

    appLog.d('[Provider] 异步检查模型文件...');

    final vadExists = await File(vadFile).exists();
    final svModelExists = await File(svModelFile).exists();
    final tokensExist = await File(tokensFile).exists();
    final encoderExists = await File(encoderFile).exists();
    final decoderExists = await File(decoderFile).exists();
    final joinerExists = await File(joinerFile).exists();
    final onlineTokensExist = await File(onlineTokens).exists();

    final punctDir = p.join(modelsDir, 'punct');
    final punctFile = p.join(punctDir, 'model.int8.onnx');
    final punctExists = await File(punctFile).exists();

    appLog.d('[Provider]   VAD: $vadFile (存在: $vadExists)');
    appLog.d('[Provider]   ASR: $svModelFile (存在: $svModelExists)');
    appLog.d('[Provider]   Zip-encoder: $encoderFile (存在: $encoderExists)');
    appLog.d('[Provider]   Zip-decoder: $decoderFile (存在: $decoderExists)');
    appLog.d('[Provider]   Zip-joiner: $joinerFile (存在: $joinerExists)');
    appLog.d('[Provider]   Zip-tokens: $onlineTokens (存在: $onlineTokensExist)');
    appLog.d('[Provider]   tokens: $tokensFile (存在: $tokensExist)');
    appLog.d('[Provider]   标点: $punctFile (存在: $punctExists)');

    if (!vadExists || !svModelExists || !tokensExist) {
      appLog.d('[Provider] 模型文件不完整，引擎暂不可用');
      return null;
    }

    final hasOnlineModel = encoderExists && onlineTokensExist;

    appLog.d('[Provider] 模型文件完整，初始化引擎...');
    return SherpaOnnxEngine.create(
      sileroVadModel: vadFile,
      senseVoiceModel: svModelFile,
      tokensFile: tokensFile,
      punctuationModel: punctExists ? punctFile : null,

      // 流式参数
      encoder: hasOnlineModel ? encoderFile : null,
      decoder: hasOnlineModel ? decoderFile : null,
      joiner: hasOnlineModel ? joinerFile : null,
      onlineTokens: hasOnlineModel ? onlineTokens : null,
    );
  } catch (e) {
    appLog.d('[Provider] 引擎创建失败: $e');
    return null;
  }
}

/// 录音转写服务（注入引擎）
@riverpod
TranscriptionService transcriptionService(Ref ref) {
  final engineAsync = ref.watch(sherpaOnnxEngineProvider);
  final engine = engineAsync.asData?.value;
  final notesRepo = ref.watch(notesRepositoryProvider);
  final segmentsRepo = ref.watch(segmentsRepositoryProvider);
  final service = TranscriptionService(
    engine: engine,
    notesRepo: notesRepo,
    segmentsRepo: segmentsRepo,
  );
  ref.onDispose(() => service.dispose());
  return service;
}

/// 直播转写结果（录音中累积的片段列表）
@riverpod
Stream<List<TranscribedSegment>> liveTranscript(Ref ref) {
  final service = ref.watch(transcriptionServiceProvider);
  return service.liveSegmentsStream;
}

/// 录音状态流
@riverpod
Stream<TranscriptionStatus> transcriptionStatus(Ref ref) {
  return ref.watch(transcriptionServiceProvider).statusStream;
}

/// 声波图振幅数据流（录音中实时更新振幅快照）
/// 录音时长流（毫秒）
@riverpod
Stream<int> recordingDuration(Ref ref) {
  return ref.watch(transcriptionServiceProvider).recordingDurationStream;
}

@riverpod
Stream<List<double>> waveform(Ref ref) {
  return ref.watch(transcriptionServiceProvider).waveformStream;
}
