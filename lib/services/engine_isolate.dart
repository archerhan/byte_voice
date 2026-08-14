import 'dart:async';
import 'dart:isolate';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'engine_service.dart';

/// 在后台 Isolate 中处理音频，返回转写片段
Future<List<TranscribedSegment>> processInIsolate({
  required String audioPath,
  required String sileroVadModel,
  required String senseVoiceModel,
  required String tokensFile,
  String? punctuationModel,
  void Function(double)? onProgress,
}) async {
  final mainReceivePort = ReceivePort();
  final isolate = await Isolate.spawn(_engineWorker, mainReceivePort.sendPort);

  // 第一个消息 = worker 的 SendPort
  final workerPort = await mainReceivePort.first as SendPort;

  // 建立结果接收通道
  final resultPort = ReceivePort();
  workerPort.send({
    'type': 'process',
    'audioPath': audioPath,
    'sileroVadModel': sileroVadModel,
    'senseVoiceModel': senseVoiceModel,
    'tokensFile': tokensFile,
    'punctuationModel': punctuationModel,
    'replyPort': resultPort.sendPort,
  });

  final completer = Completer<List<TranscribedSegment>>();

  resultPort.listen((msg) {
    switch (msg['type']) {
      case 'progress':
        onProgress?.call((msg['progress'] as num).toDouble());
        break;
      case 'result':
        final segments = (msg['segments'] as List)
            .map((s) => TranscribedSegment.fromJson(s as Map<String, dynamic>))
            .toList();
        if (!completer.isCompleted) completer.complete(segments);
        break;
      case 'error':
        if (!completer.isCompleted) {
          completer.completeError(Exception(msg['message']));
        }
        break;
    }
  });

  final result = await completer.future;
  isolate.kill();
  return result;
}

/// Isolate 入口：加载引擎 → 处理音频 → 回传结果
@pragma('vm:entry-point')
/// Isolate 入口：加载引擎 → 处理音频 → 回传结果
@pragma('vm:entry-point')
void _engineWorker(SendPort mainPort) {
  final receivePort = ReceivePort();
  mainPort.send(receivePort.sendPort);

  receivePort.listen((msg) async {
    if (msg['type'] != 'process') return;
    final reply = msg['replyPort'] as SendPort;

    try {
      initBindings();
      final engine = SherpaOnnxEngine.create(
        sileroVadModel: msg['sileroVadModel'],
        senseVoiceModel: msg['senseVoiceModel'],
        tokensFile: msg['tokensFile'],
        punctuationModel: msg['punctuationModel'] as String?,
      );
      if (engine == null) {
        reply.send({'type': 'error', 'message': '引擎创建失败'});
        return;
      }

      final segments = await engine.processWavFileAsync(
        msg['audioPath'],
        onProgress: (p) => reply.send({'type': 'progress', 'progress': p}),
      );
      engine.free();

      reply.send({
        'type': 'result',
        'segments': segments.map((s) => s.toJson()).toList(),
      });
    } catch (e) {
      reply.send({'type': 'error', 'message': '$e'});
    }
  });
}
