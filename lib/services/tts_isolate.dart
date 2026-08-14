import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:path/path.dart' as p;

/// TTS 合成结果（可跨 isolate 传递）
class TtsGeneratedAudio {
  final Float32List samples;
  final int sampleRate;

  const TtsGeneratedAudio({required this.samples, required this.sampleRate});
}

/// 在后台 Isolate 中合成语音，返回音频数据
Future<TtsGeneratedAudio> synthesizeInIsolate({
  required String text,
  required int voiceId,
  required double speed,
  required String modelsDir,
}) async {
  final mainReceivePort = ReceivePort();
  final isolate = await Isolate.spawn(_ttsWorker, mainReceivePort.sendPort);

  final workerPort = await mainReceivePort.first as SendPort;

  final resultPort = ReceivePort();
  workerPort.send({
    'type': 'synthesize',
    'text': text,
    'voiceId': voiceId,
    'speed': speed,
    'modelsDir': modelsDir,
    'replyPort': resultPort.sendPort,
  });

  final completer = Completer<TtsGeneratedAudio>();

  resultPort.listen((msg) {
    switch (msg['type']) {
      case 'result':
        final samples = msg['samples'] as Float32List;
        final sampleRate = msg['sampleRate'] as int;
        if (!completer.isCompleted) {
          completer.complete(
            TtsGeneratedAudio(samples: samples, sampleRate: sampleRate),
          );
        }
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

/// Isolate 入口：加载 TTS 引擎 → 合成 → 回传结果
@pragma('vm:entry-point')
void _ttsWorker(SendPort mainPort) {
  final receivePort = ReceivePort();
  mainPort.send(receivePort.sendPort);

  receivePort.listen((msg) async {
    if (msg['type'] != 'synthesize') return;
    final reply = msg['replyPort'] as SendPort;

    try {
      initBindings();

      final modelsDir = msg['modelsDir'] as String;
      final modelFile = p.join(modelsDir, 'vits-zh-hf-fanchen-C.onnx');
      final tokensFile = p.join(modelsDir, 'tokens.txt');
      final lexiconFile = p.join(modelsDir, 'lexicon.txt');
      final dictDir = p.join(modelsDir, 'dict');
      final ruleFsts = [
        p.join(modelsDir, 'date.fst'),
        p.join(modelsDir, 'number.fst'),
        p.join(modelsDir, 'phone.fst'),
        p.join(modelsDir, 'new_heteronym.fst'),
      ].join(',');

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

      final text = msg['text'] as String;
      final voiceId = msg['voiceId'] as int;
      final speed = msg['speed'] as double;

      final audio = tts.generate(text: text, sid: voiceId, speed: speed);

      if (audio.samples.isEmpty || audio.sampleRate <= 0) {
        tts.free();
        reply.send({'type': 'error', 'message': '合成结果为空'});
        return;
      }

      reply.send({
        'type': 'result',
        'samples': audio.samples,
        'sampleRate': audio.sampleRate,
      });

      tts.free();
    } catch (e) {
      reply.send({'type': 'error', 'message': '$e'});
    }
  });
}
