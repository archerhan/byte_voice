import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io';
import '../logger.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'engine_service.dart';
import '../models/note.dart';
import '../models/segment.dart';
import '../models/note_status.dart';
import '../database/repositories/notes_repository.dart';
import '../database/repositories/segments_repository.dart';
import 'audio_storage_service.dart';

/// 录音状态
enum TranscriptionStatus { idle, recording, paused, processing, done }

/// 录音转写服务 — 管理录音生命周期 + 引擎处理 + 数据持久化
class TranscriptionService {
  /// 录音最大时长（毫秒）
  static const int maxRecordingDurationMs = 30 * 60 * 1000;

  final _statusController = StreamController<TranscriptionStatus>.broadcast();
  final _segmentController = StreamController<TranscribedSegment>.broadcast();

  /// 实时片段列表流 — 每次变更发出完整列表，新录音自动重置
  final _liveSegmentsController =
      StreamController<List<TranscribedSegment>>.broadcast();

  /// 声波图振幅缓冲区（RMS 值，最多 200 个采样点）
  final List<double> _waveformBuffer = [];
  final _waveformController = StreamController<List<double>>.broadcast();
  final _durationController = StreamController<int>.broadcast();
  bool _stoppingByLimit = false;

  final AudioRecorder _recorder = AudioRecorder();
  final SherpaOnnxEngine? _engine;
  final NotesRepository? _notesRepo;
  final SegmentsRepository? _segmentsRepo;

  StreamSubscription<Uint8List>? _recordingSubscription;
  StreamSubscription<TranscribedSegment>? _engineSegmentSub;

  TranscriptionStatus _status = TranscriptionStatus.idle;
  String? _currentNoteId;
  String? _currentNoteTitle;

  /// 原始录音 PCM16 缓冲（用于停止时写入 WAV 文件）
  final List<int> _audioBuffer = [];

  /// 录音过程中累积的片段（用于停止时入库）
  final List<TranscribedSegment> _recordedSegments = [];

  TranscriptionService({this._engine, this._notesRepo, this._segmentsRepo});

  TranscriptionStatus get status => _status;
  String? get currentNoteId => _currentNoteId;
  Stream<TranscriptionStatus> get statusStream => _statusController.stream;
  Stream<TranscribedSegment> get segmentStream => _segmentController.stream;

  /// 直播转写片段列表流（每次新增片段时发出完整快照，新录音发出空列表）
  Stream<List<TranscribedSegment>> get liveSegmentsStream =>
      _liveSegmentsController.stream;
  List<TranscribedSegment> get recordedSegments =>
      List.unmodifiable(_recordedSegments);

  /// 开始录音 → 立即创建笔记 → 启动麦克风流 → 实时转写
  Future<void> startRecording() async {
    if (_status == TranscriptionStatus.recording) return;

    if (!await _recorder.hasPermission()) {
      appLog.e('[Transcription] 未获得麦克风权限');
      throw Exception('未获得麦克风权限，请在系统设置中允许应用访问麦克风');
    }

    appLog.d('[Transcription] 开始实时录音');
    _audioBuffer.clear();
    _recordedSegments.clear();
    _waveformBuffer.clear();
    _waveformController.add([]);
    _stoppingByLimit = false;
    _durationController.add(0);
    _liveSegmentsController.add([]); // 通知 UI 清空旧内容

    // 1. 立即创建笔记
    final noteId = const Uuid().v4();
    _currentNoteId = noteId;
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _currentNoteTitle = '录音 $dateStr';
    try {
      await _notesRepo?.create(
        Note(
          id: noteId,
          title: _currentNoteTitle!,
          source: NoteSource.recording,
          status: NoteStatus.transcribing,
        ),
      );
      appLog.d('[Transcription] 笔记已创建: $noteId');
    } catch (e) {
      appLog.d('[Transcription] 创建笔记失败: $e');
    }

    // 2. 启动引擎流式处理
    final engine = _engine;
    if (engine != null) {
      final engineStream = engine.startStreaming();

      _engineSegmentSub = engineStream.listen((segment) {
        // ★ 核心上屏逻辑 ★
        if (_recordedSegments.isNotEmpty && _recordedSegments.last.isPartial) {
          _recordedSegments.last = segment;
        } else {
          _recordedSegments.add(segment);
        }
        _segmentController.add(segment);
        _liveSegmentsController.add(List.from(_recordedSegments));
      });
    }

    // 3. 启动麦克风流（★核心修复：自动采样率探测与异常捕获★）
    Stream<Uint8List>? stream;
    int actualSampleRate = 16000;

    // Windows 常见硬件采样率，优先尝试 48k 和 44.1k 避开硬件限制
    final ratesToTry = Platform.isWindows ? [48000, 44100, 16000] : [16000];

    for (final rate in ratesToTry) {
      try {
        stream = await _recorder.startStream(
          RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: rate,
            numChannels: 1,
          ),
        );
        actualSampleRate = rate;
        appLog.d('[Transcription] 成功以 ${rate}Hz 启动麦克风硬件');
        break; // 成功启动，跳出循环
      } catch (e) {
        appLog.w('[Transcription] 尝试 ${rate}Hz 失败，尝试降级: $e');
      }
    }

    if (stream == null) {
      _status = TranscriptionStatus.idle;
      _statusController.add(_status);
      throw Exception('无法启动麦克风，设备可能被独占或不支持所请求的格式');
    }

    // 4. 监听音频流数据
    _recordingSubscription = stream.listen(
      (data) {
        try {
          Float32List float32Samples = _pcm16ToFloat32(data);

          // 硬件给的不是 16k 时，进行软件降采样
          if (actualSampleRate != 16000) {
            float32Samples = _resample(float32Samples, actualSampleRate, 16000);
          }

          // 存入 WAV 缓冲并喂给引擎
          _audioBuffer.addAll(_float32ToPcm16(float32Samples));
          engine?.feedAudioChunk(float32Samples);

          // 计算 RMS 振幅并更新声波图
          final rms = math.sqrt(
            float32Samples.fold<double>(0.0, (sum, s) => sum + s * s) /
                (float32Samples.isNotEmpty ? float32Samples.length : 1),
          );
          _waveformBuffer.add(rms);
          if (_waveformBuffer.length > 200) {
            _waveformBuffer.removeAt(0);
          }
          _waveformController.add(List.from(_waveformBuffer));

          // 更新录音时长并检查上限
          final durationMs = _audioBuffer.length ~/ 32;
          _durationController.add(durationMs);
          if (durationMs >= maxRecordingDurationMs && !_stoppingByLimit) {
            _stoppingByLimit = true;
            Future.microtask(() => stopRecording());
          }
        } catch (e) {
          appLog.e('[Transcription] 处理音频块时发生内部错误: $e');
        }
      },
      onError: (err) {
        appLog.e('[Transcription] 麦克风音频流抛出异常: $err');
      },
      onDone: () {
        appLog.w('[Transcription] 麦克风音频流意外中断结束');
      },
    );

    _status = TranscriptionStatus.recording;
    _statusController.add(_status);
  }

  /// 暂停录音
  Future<void> pauseRecording() async {
    appLog.d('[Transcription] 暂停录音');
    _recordingSubscription?.pause();
    _status = TranscriptionStatus.paused;
    _statusController.add(_status);
  }

  /// 恢复录音
  Future<void> resumeRecording() async {
    if (_status != TranscriptionStatus.paused) return;
    appLog.d('[Transcription] 恢复录音');
    _recordingSubscription?.resume();
    _status = TranscriptionStatus.recording;
    _statusController.add(_status);
  }

  /// 停止录音 → 写出 WAV 文件 + 片段入库 + 更新笔记状态
  Future<String> stopRecording() async {
    appLog.d('[Transcription] 停止录音');
    await _recordingSubscription?.cancel();
    _recordingSubscription = null;
    await _recorder.stop();

    _engine?.stopStreaming();
    _engineSegmentSub?.cancel();
    _engineSegmentSub = null;

    _status = TranscriptionStatus.processing;
    _statusController.add(_status);

    await _saveRecording();

    _status = TranscriptionStatus.done;
    _statusController.add(_status);
    return _currentNoteId ?? '';
  }

  /// 核心保存逻辑：WAV 写入 + 片段入库 + 笔记状态更新
  Future<void> _saveRecording() async {
    final noteId = _currentNoteId;
    final title = _currentNoteTitle ?? '录音';
    if (noteId == null) return;

    // 1. 保存 WAV 音频文件
    String? audioPath;
    try {
      audioPath = await _writeWavFile(noteId);
      appLog.d('[Transcription] 音频已保存: $audioPath');
    } catch (e) {
      appLog.d('[Transcription] WAV 写入失败: $e');
    }

    // 2. 片段入库
    if (_segmentsRepo != null && _recordedSegments.isNotEmpty) {
      try {
        final dbSegments = _recordedSegments.asMap().entries.map((e) {
          final seg = e.value;
          return Segment(
            id: const Uuid().v4(),
            noteId: noteId,
            startMs: seg.startMs,
            endMs: seg.endMs,
            text: seg.text,
            sortIndex: e.key,
          );
        }).toList();
        await _segmentsRepo.bulkInsert(dbSegments);
        appLog.d('[Transcription] ${dbSegments.length} 个片段已入库');
      } catch (e) {
        appLog.d('[Transcription] 保存片段失败: $e');
      }
    }

    // 3. 更新笔记状态（保留原始标题）
    if (_notesRepo != null) {
      try {
        final durationMs = _recordedSegments.isEmpty
            ? 0
            : _recordedSegments.last.endMs;
        await _notesRepo.update(
          Note(
            id: noteId,
            title: title,
            durationMs: durationMs,
            audioFilePath: audioPath,
            keepAudio: audioPath != null,
            source: NoteSource.recording,
            status: NoteStatus.completed,
          ),
        );
        appLog.d('[Transcription] 笔记已更新: $noteId');
      } catch (e) {
        appLog.d('[Transcription] 更新笔记失败: $e');
      }
    }
  }

  /// 将缓冲的 PCM16 数据写出为 WAV 文件
  Future<String> _writeWavFile(String noteId) async {
    final audioDir = await AudioStorageService.ensureAudioDir();
    final filePath = p.join(audioDir, 'asr_$noteId.wav');
    final pcmData = Uint8List.fromList(_audioBuffer);
    if (pcmData.isEmpty) throw Exception('无音频数据');

    final sink = File(filePath).openWrite();

    final totalDataLen = pcmData.length;
    final fileSize = 36 + totalDataLen;

    // 构建 44 字节标准 WAV 头
    final header = Uint8List(44);
    final bd = ByteData.view(header.buffer);
    // RIFF
    bd.setUint8(0, 0x52);
    bd.setUint8(1, 0x49);
    bd.setUint8(2, 0x46);
    bd.setUint8(3, 0x46);
    bd.setUint32(4, fileSize, Endian.little);
    bd.setUint8(8, 0x57);
    bd.setUint8(9, 0x41);
    bd.setUint8(10, 0x56);
    bd.setUint8(11, 0x45);
    // fmt
    bd.setUint8(12, 0x66);
    bd.setUint8(13, 0x6D);
    bd.setUint8(14, 0x74);
    bd.setUint8(15, 0x20);
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, 16000, Endian.little);
    bd.setUint32(28, 32000, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    // data
    bd.setUint8(36, 0x64);
    bd.setUint8(37, 0x61);
    bd.setUint8(38, 0x74);
    bd.setUint8(39, 0x61);
    bd.setUint32(40, totalDataLen, Endian.little);

    sink.add(header);
    sink.add(pcmData);
    await sink.close();

    appLog.d('[Transcription] WAV 已保存: $filePath ($totalDataLen bytes)');
    return filePath;
  }

  /// PCM16 字节 → Float32 采样（引擎输入格式）
  Float32List _pcm16ToFloat32(Uint8List pcm16) {
    final result = Float32List(pcm16.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      final sample = (pcm16[i * 2] | (pcm16[i * 2 + 1] << 8)).toSigned(16);
      result[i] = sample / 32768.0;
    }
    return result;
  }

  void dispose() {
    _recordingSubscription?.cancel();
    _engineSegmentSub?.cancel();
    _waveformController.close();
    _durationController.close();
    _liveSegmentsController.close();
    _statusController.close();
    _segmentController.close();
  }

  /// 纯 Dart 软件重采样 (线性插值算法)
  Float32List _resample(Float32List input, int inRate, int outRate) {
    if (inRate == outRate) return input;
    final ratio = inRate / outRate;
    final outLen = (input.length / ratio).round();
    final output = Float32List(outLen);
    for (int i = 0; i < outLen; i++) {
      final srcIdx = i * ratio;
      final left = srcIdx.floor();
      final right = (left + 1).clamp(0, input.length - 1);
      final frac = srcIdx - left;
      output[i] = input[left] * (1 - frac) + input[right] * frac;
    }
    return output;
  }

  /// 将 Float32 还原为 PCM16 字节流 (用于保存正常的 WAV 文件)
  Uint8List _float32ToPcm16(Float32List float32) {
    final result = Uint8List(float32.length * 2);
    for (int i = 0; i < float32.length; i++) {
      int sample = (float32[i] * 32768.0).round().clamp(-32768, 32767);
      if (sample < 0) sample += 65536; // 处理 16 位二进制补码
      result[i * 2] = sample & 0xFF;
      result[i * 2 + 1] = (sample >> 8) & 0xFF;
    }
    return result;
  }

  /// 声波图振幅数据流（每次新增采样点发出完整缓冲区快照）
  Stream<List<double>> get waveformStream => _waveformController.stream;

  /// 当前录音时长（毫秒）
  Stream<int> get recordingDurationStream => _durationController.stream;
  int get recordingDurationMs => _audioBuffer.length ~/ 32;
}
