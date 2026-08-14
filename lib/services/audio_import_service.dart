import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../logger.dart';
import 'engine_service.dart';

/// 音频文件导入服务 — 支持 WAV / mp3 / m4a / ogg / flac / aac
/// 非 WAV 格式通过系统 ffmpeg 解码后处理
/// 音频文件导入服务 — 支持 WAV / mp3 / m4a / ogg / flac / aac
class AudioImportService {
  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  final SherpaOnnxEngine? _engine;
  bool _isImporting = false;

  AudioImportService({this._engine});

  bool get isImporting => _isImporting;

  /// 支持的音频格式
  static const supportedExtensions = [
    'wav',
    'mp3',
    'm4a',
    'ogg',
    'flac',
    'aac',
  ];

  /// 处理音频文件，通过引擎转写后返回片段列表
  Future<List<TranscribedSegment>> importFile(
    String filePath, {
    void Function(double)? onProgress,
  }) async {
    _isImporting = true;
    _progressController.add(0.0);
    appLog.d('[Import] 开始导入: $filePath');

    try {
      final engine = _engine;
      if (engine == null) {
        throw Exception('引擎未初始化 — 模型文件可能缺失');
      }

      final ext = p.extension(filePath).toLowerCase();
      String wavPath;

      if (ext == '.wav') {
        wavPath = filePath;
      } else if (supportedExtensions.map((e) => '.$e').contains(ext)) {
        appLog.d('[Import] 通过 ffmpeg 解码 $ext → WAV...');
        wavPath = await decodeToWav(filePath);
        _progressController.add(0.3);
      } else {
        throw Exception('不支持 $ext 格式，支持: ${supportedExtensions.join(", ")}');
      }

      appLog.d('[Import] 喂入引擎处理');
      final segments = await engine.processWavFileAsync(
        wavPath,
        onProgress: onProgress,
      );
      _progressController.add(1.0);
      appLog.d('[Import] 完成: ${segments.length} 个片段');
      return segments;
    } finally {
      _isImporting = false;
    }
  }

  void cancel() {
    appLog.d('[Import] 取消导入');
    _isImporting = false;
  }

  void dispose() {
    _progressController.close();
  }

  /// 用系统 ffmpeg 将任意音频解码为 16kHz 单声道 WAV
  Future<String> decodeToWav(String filePath) async {
    final dir = await Directory.systemTemp.createTemp('byte_voice_');
    final inputName = p.basename(filePath);
    final inputCopy = p.join(dir.path, inputName);
    await File(filePath).copy(inputCopy);

    final wavPath = p.join(dir.path, 'decoded.wav');
    final result = await Process.run('ffmpeg', [
      '-i',
      inputCopy,
      '-ac',
      '1',
      '-ar',
      '16000',
      '-sample_fmt',
      's16',
      '-y',
      wavPath,
    ]);

    if (result.exitCode != 0) {
      throw Exception('ffmpeg 解码失败:\n${result.stderr}');
    }
    return wavPath;
  }
}
