import 'dart:async';
import 'dart:math' as math; // 新增这一行
import '../logger.dart';
import 'package:flutter/foundation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';

/// 单个转写片段：包含时间戳和文字
class TranscribedSegment {
  /// 片段开始时间（毫秒）
  final int startMs;

  /// 片段结束时间（毫秒）
  final int endMs;

  /// 识别文本
  final String text;

  final bool isPartial; // ★ 新增：区分是临时上屏还是最终确认

  const TranscribedSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
    this.isPartial = false,
  });

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
    'startMs': startMs,
    'endMs': endMs,
    'text': text,
    'isPartial': isPartial,
  };

  /// 从 JSON 反序列化
  factory TranscribedSegment.fromJson(Map<String, dynamic> j) =>
      TranscribedSegment(
        startMs: j['startMs'] as int,
        endMs: j['endMs'] as int,
        text: j['text'] as String,
        isPartial: j['isPartial'] as bool? ?? false,
      );
}

/// sherpa_onnx 引擎封装：Silero-VAD + SenseVoice + CT-Transformer 标点恢复
class SherpaOnnxEngine {
  /// VAD 语音活动检测器
  final VoiceActivityDetector _vad;

  /// ASR 离线识别器
  final OfflineRecognizer _recognizer;

  /// CT-Transformer 标点恢复（可选）
  final OfflinePunctuation? _punctuator;

  // 在线流式组件 (用于实时麦克风)
  final OnlineRecognizer? _onlineRecognizer;

  OnlineStream? _onlineStream;

  /// Streaming transcription state
  StreamController<TranscribedSegment>? _streamingController;
  bool _isStreaming = false;

  // ==========================================
  // ★ 核心新增：流式绝对时间轴追踪变量 ★
  // ==========================================
  int _totalSamplesFed = 0; // 自录音开始以来，一共喂入引擎的音频样本总数
  int _absoluteBaseTimeMs = 0; // 当前整句话在整段录音中的基准起始毫秒数
  int _sentenceStartMs = 0; // 当前句子的精确开始时间
  bool _isNewSentence = true; // 是否正在开启一句话的识别

  SherpaOnnxEngine._(
    this._vad,
    this._recognizer,
    this._punctuator,
    this._onlineRecognizer,
  );

  /// 尝试创建引擎实例，模型加载失败返回 null
  static SherpaOnnxEngine? create({
    required String sileroVadModel,
    required String senseVoiceModel,
    required String tokensFile,
    String? punctuationModel,
    String? encoder,
    String? decoder,
    String? joiner,
    String? onlineTokens,
    int numThreads = 2,
  }) {
    try {
      appLog.d('[Engine] 初始化原生绑定...');
      initBindings();

      appLog.d('[Engine] 创建 VAD (Silero): $sileroVadModel');
      final vad = VoiceActivityDetector(
        config: VadModelConfig(
          sileroVad: SileroVadModelConfig(
            model: sileroVadModel,
            threshold: 0.25,
            minSilenceDuration: 0.3,
            minSpeechDuration: 0.1,
            maxSpeechDuration: 15.0,
          ),
          debug: false,
          numThreads: numThreads,
        ),
        bufferSizeInSeconds: 30,
      );

      appLog.d('[Engine] 创建 ASR (SenseVoice): $senseVoiceModel');
      final recognizer = OfflineRecognizer(
        OfflineRecognizerConfig(
          feat: const FeatureConfig(),
          model: OfflineModelConfig(
            tokens: tokensFile,
            senseVoice: OfflineSenseVoiceModelConfig(
              model: senseVoiceModel,
              useInverseTextNormalization: true,
            ),
            provider: 'cpu',
            numThreads: numThreads,
            debug: false,
          ),
          decodingMethod: 'greedy_search',
        ),
      );

      OfflinePunctuation? punctuator;
      if (punctuationModel != null) {
        appLog.d('[Engine] 创建标点恢复 (CT-Transformer): $punctuationModel');
        punctuator = OfflinePunctuation(
          config: OfflinePunctuationConfig(
            model: OfflinePunctuationModelConfig(
              ctTransformer: punctuationModel,
              numThreads: numThreads,
              debug: false,
            ),
          ),
        );
        appLog.d('[Engine] 标点模型加载成功');
      } else {
        appLog.d('[Engine] 未配置标点模型，跳过标点恢复');
      }

      // 2. 初始化在线流式组件 (Zipformer)
      OnlineRecognizer? onlineRecognizer;
      if (encoder != null &&
          decoder != null &&
          joiner != null &&
          onlineTokens != null) {
        appLog.d('[Engine] 加载 Zipformer 流式模型...');
        onlineRecognizer = OnlineRecognizer(
          OnlineRecognizerConfig(
            feat: const FeatureConfig(sampleRate: 16000),
            model: OnlineModelConfig(
              tokens: onlineTokens,
              transducer: OnlineTransducerModelConfig(
                encoder: encoder,
                decoder: decoder,
                joiner: joiner,
              ),
              numThreads: 2,
              debug: false,
            ),
            enableEndpoint: true, // 开启端点检测（自动断句）
            rule1MinTrailingSilence: 2.0,
            rule2MinTrailingSilence: 1.0, // 停顿 1.0 秒视为一句话结束
            rule3MinUtteranceLength: 20.0,
          ),
        );
      }

      appLog.d('[Engine] 引擎初始化成功');
      return SherpaOnnxEngine._(vad, recognizer, punctuator, onlineRecognizer);
    } catch (e) {
      appLog.d('[Engine] 引擎初始化失败: $e');
      return null;
    }
  }

  // ==========================================
  // 流式 API (麦克风专用)
  // ==========================================

  Stream<TranscribedSegment> startStreaming() {
    if (_onlineRecognizer == null) throw Exception("流式模型未加载完毕");
    _isStreaming = true;
    _streamingController = StreamController<TranscribedSegment>.broadcast();
    _onlineStream = _onlineRecognizer.createStream();

    // ★ 每次开始新录音，重置时钟与时间轴状态机
    _totalSamplesFed = 0;
    _absoluteBaseTimeMs = 0;
    _sentenceStartMs = 0;
    _isNewSentence = true;

    return _streamingController!.stream;
  }

  /// Feed an audio chunk for live processing.
  void feedAudioChunk(Float32List samples) {
    if (!_isStreaming || _onlineStream == null) return;

    // 1. 累加喂入的样本数，建立物理时钟 (16000 采样率下，每 16 个样本 = 1 毫秒)
    _totalSamplesFed += samples.length;
    final currentAbsoluteTimeMs = (_totalSamplesFed * 1000) ~/ 16000;

    // 2. 喂入音频解码
    _onlineStream!.acceptWaveform(samples: samples, sampleRate: 16000);

    while (_onlineRecognizer!.isReady(_onlineStream!)) {
      _onlineRecognizer.decode(_onlineStream!);
    }

    // 3. 获取包含时间戳的识别结果
    final result = _onlineRecognizer.getResult(_onlineStream!);
    final text = result.text.trim();

    if (text.isNotEmpty) {
      // 锁定当前句子的绝对起点
      if (_isNewSentence) {
        double firstTokenTimeSec = 0.0;
        try {
          if (result.timestamps.isNotEmpty) {
            firstTokenTimeSec = result.timestamps.first;
          }
        } catch (_) {}
        _sentenceStartMs =
            _absoluteBaseTimeMs + (firstTokenTimeSec * 1000).round();
        _isNewSentence = false;
      }

      // 计算当前句子的绝对末尾时间
      double lastTokenTimeSec = 0.0;
      try {
        if (result.timestamps.isNotEmpty) {
          lastTokenTimeSec = result.timestamps.last;
        }
      } catch (_) {}

      int currentEndMs =
          _absoluteBaseTimeMs + (lastTokenTimeSec * 1000).round();
      if (currentEndMs <= _sentenceStartMs) {
        currentEndMs = currentAbsoluteTimeMs;
      }

      // 推送动态刷新的临时段落 (携带真实时间戳)
      _streamingController?.add(
        TranscribedSegment(
          startMs: _sentenceStartMs,
          endMs: currentEndMs,
          text: text,
          isPartial: true,
        ),
      );
    }

    // 4. 判断是否说话停顿断句
    if (_onlineRecognizer.isEndpoint(_onlineStream!)) {
      if (text.isNotEmpty) {
        double lastTokenTimeSec = 0.0;
        try {
          if (result.timestamps.isNotEmpty) {
            lastTokenTimeSec = result.timestamps.last;
          }
        } catch (_) {}

        int finalEndMs =
            _absoluteBaseTimeMs + (lastTokenTimeSec * 1000).round();
        if (finalEndMs <= _sentenceStartMs) {
          finalEndMs = currentAbsoluteTimeMs;
        }

        // 推送完全敲定、不再改变的最终分段
        _streamingController?.add(
          TranscribedSegment(
            startMs: _sentenceStartMs,
            endMs: finalEndMs,
            text: text,
            isPartial: false,
          ),
        );
      }

      // 重置流解码器，迎接下一句话
      _onlineRecognizer.reset(_onlineStream!);

      // ★ 核心：时间轴向前推进，下一句模型的相对时间戳将重新从 0 算起
      _absoluteBaseTimeMs = currentAbsoluteTimeMs;
      _isNewSentence = true;
    }
  }

  /// Stop streaming and flush remaining audio.
  void stopStreaming() {
    if (!_isStreaming) return;
    _isStreaming = false;

    if (_onlineStream != null) {
      _onlineStream!.inputFinished();
      while (_onlineRecognizer!.isReady(_onlineStream!)) {
        _onlineRecognizer.decode(_onlineStream!);
      }

      final result = _onlineRecognizer.getResult(_onlineStream!);
      final text = result.text.trim();

      if (text.isNotEmpty) {
        final currentAbsoluteTimeMs = (_totalSamplesFed * 1000) ~/ 16000;
        double lastTokenTimeSec = 0.0;
        try {
          if (result.timestamps.isNotEmpty) {
            lastTokenTimeSec = result.timestamps.last;
          }
        } catch (_) {}

        int finalEndMs =
            _absoluteBaseTimeMs + (lastTokenTimeSec * 1000).round();
        if (finalEndMs <= _sentenceStartMs) {
          finalEndMs = currentAbsoluteTimeMs;
        }

        _streamingController?.add(
          TranscribedSegment(
            startMs: _sentenceStartMs,
            endMs: finalEndMs,
            text: text,
            isPartial: false,
          ),
        );
      }
      _onlineStream!.free();
      _onlineStream = null;
    }
    _streamingController?.close();
  }

  /// 处理 WAV 文件，返回转写片段列表（16kHz 单声道）
  List<TranscribedSegment> processWavFile(String wavPath) {
    appLog.d('[Engine] 读取 WAV: $wavPath');
    final wave = readWave(wavPath);
    if (wave.samples.isEmpty || wave.sampleRate == 0) {
      appLog.d('[Engine] WAV 读取为空或采样率无效');
      return [];
    }
    appLog.d(
      '[Engine] WAV 加载完成: ${wave.samples.length} 采样, ${wave.sampleRate}Hz',
    );
    return _processSamples(wave.samples, wave.sampleRate);
  }

  /// 异步版本：处理 WAV 文件，定期让出事件循环以保持 UI 响应
  /// 异步版本：处理 WAV 文件，定期让出事件循环以保持 UI 响应
  Future<List<TranscribedSegment>> processWavFileAsync(
    String wavPath, {
    void Function(double)? onProgress,
  }) async {
    appLog.d('[Engine] 异步处理: $wavPath');
    final wave = readWave(wavPath);
    if (wave.samples.isEmpty || wave.sampleRate == 0) return [];

    // 1. 获取原始的 16k 采样数据
    final rawSamples16k = (wave.sampleRate == 16000)
        ? wave.samples
        : _resampleTo16k(wave.samples, wave.sampleRate);

    // ==========================================
    // 核心修复：全局前置静音铺垫，解决文件开头吞字
    // ==========================================
    const int globalPreRollMs = 1500; // 在文件最开头强制加 1.5 秒静音
    const int globalPreRollSamples = (globalPreRollMs * 16000) ~/ 1000;

    // 创建一个前面塞满 0 的新数组（Float32List 默认就是全 0，刚好代表纯静音）
    final samples16k = Float32List(globalPreRollSamples + rawSamples16k.length);
    // 把原始音频接在 1.5 秒静音的后面
    samples16k.setAll(globalPreRollSamples, rawSamples16k);

    _vad.reset();
    // 因为现在音频自带真实的静音前奏了，所以我们不再需要虚拟预热 (warmupSamples) 了

    // 分批喂入 VAD（每批 2s）
    const int chunkSize = 32000;
    for (int i = 0; i < samples16k.length; i += chunkSize) {
      final end = (i + chunkSize > samples16k.length)
          ? samples16k.length
          : i + chunkSize;
      _vad.acceptWaveform(samples16k.sublist(i, end));
      await Future.delayed(Duration.zero);
    }
    _vad.flush();
    await Future.delayed(Duration.zero);

    final result = <TranscribedSegment>[];
    var segCount = 0;
    final totalSamples = samples16k.length;

    // 记录上一个片段的结束点，防止重叠引发“复读机”问题
    int lastSegmentEndIdx = 0;

    while (!_vad.isEmpty()) {
      final segment = _vad.front();
      _vad.pop();

      if (segment.samples.length < 1600) continue;

      // 直接使用 segment.start，不再减去 warmupSamples
      final adjustedStart = segment.start;

      // 提取音频时，往前拿 0.5 秒，给引擎充足的上下文
      const int padStart = 8000;
      const int padEnd = 3200;

      // 核心防御：往前拿静音时，绝不能越过上一句话的结束点，杜绝重复识别！
      final startIdx = math.max(lastSegmentEndIdx, adjustedStart - padStart);
      final endIdx = math.min(
        samples16k.length,
        adjustedStart + segment.samples.length + padEnd,
      );
      lastSegmentEndIdx = endIdx;

      final speechSamples = samples16k.sublist(startIdx, endIdx);

      final stream = _recognizer.createStream();
      stream.acceptWaveform(samples: speechSamples, sampleRate: 16000);
      _recognizer.decode(stream);
      final asrResult = _recognizer.getResult(stream);
      stream.free();

      final text = _punctuator != null
          ? _applyPunctuation(asrResult.text.trim())
          : asrResult.text.trim();
      if (text.isEmpty) continue;

      // 【重点】计算时间时，一定要把我们人工加在前面的 globalPreRollMs 减掉，还原真实时间！
      final baseStartMs = (startIdx * 1000 / 16000).round() - globalPreRollMs;
      final segmentEndMs = (endIdx * 1000 / 16000).round() - globalPreRollMs;

      final splitSegs = _splitByTimestamps(
        punctuatedText: text,
        asrResult: asrResult,
        baseStartMs: math.max(0, baseStartMs), // 兜底防负数
        segmentEndMs: math.max(0, segmentEndMs),
      );

      segCount += splitSegs.length;
      result.addAll(splitSegs);

      // 报告进度
      if (samples16k.isNotEmpty) {
        final progress =
            (segment.start + segment.samples.length) / totalSamples;
        onProgress?.call(progress.clamp(0.0, 1.0));
      }
      if (segCount % 3 == 0) await Future.delayed(Duration.zero);
    }
    appLog.d('[Engine] 异步完成: $segCount 个片段');
    return result;
  }

  /// 使用引擎原生的字级时间戳（Token Timestamps）进行毫秒级精准切割
  List<TranscribedSegment> _splitByTimestamps({
    required String punctuatedText,
    required OfflineRecognizerResult asrResult,
    required int baseStartMs,
    required int segmentEndMs,
  }) {
    // 1. 依然使用之前的智能逻辑断开句子（兼顾排版与行数）
    final sentences = _extractSentences(punctuatedText);
    if (sentences.isEmpty) return [];

    // 降级保护：如果引擎异常没有返回时间戳，退回比例分配
    if (asrResult.tokens.isEmpty || asrResult.timestamps.isEmpty) {
      return _splitByLengthRatio(sentences, baseStartMs, segmentEndMs);
    }

    // 2. 构建 Token 与 时间的精准映射表
    final tokenTimes = <_TokenTime>[];
    for (int i = 0; i < asrResult.tokens.length; i++) {
      // asrResult.timestamps 是相对于当前音频片段的秒数
      final timeMs = baseStartMs + (asrResult.timestamps[i] * 1000).round();
      // 过滤掉模型可能输出的特殊空格 (SenseVoice 的特殊块或标准空格)
      final cleanText = asrResult.tokens[i].replaceAll(
        RegExp(r'[\s ▂▃▄▅▆▇█]'),
        '',
      );
      if (cleanText.isNotEmpty) {
        tokenTimes.add(_TokenTime(cleanText, timeMs));
      }
    }

    final result = <TranscribedSegment>[];
    int currentTokenIdx = 0;
    int lastEndMs = baseStartMs;

    // 3. 将句子与底层 Token 进行缝合对齐
    for (int i = 0; i < sentences.length; i++) {
      final s = sentences[i];

      // 当前句子的绝对精确开始时间：即当前指针所指 Token 的时间
      int startMs = currentTokenIdx < tokenTimes.length
          ? tokenTimes[currentTokenIdx].timeMs
          : lastEndMs;

      // 计算当前句子包含的"有效发音字符"数量（剔除加上的标点和空格）
      final cleanSentence = s.replaceAll(
        RegExp(r'[。！？\n.!?，,；;、：:\s ▂▃▄▅▆▇█]'),
        '',
      );
      int targetChars = cleanSentence.length;

      // 消费对应的 Token，直到字符数对齐
      int consumedChars = 0;
      while (currentTokenIdx < tokenTimes.length &&
          consumedChars < targetChars) {
        consumedChars += tokenTimes[currentTokenIdx].text.length;
        currentTokenIdx++;
      }

      // 获取结束时间：也就是下一句话首个 Token 的发音时间
      int endMs = currentTokenIdx < tokenTimes.length
          ? tokenTimes[currentTokenIdx].timeMs
          : segmentEndMs;

      // 最后一句话兜底，直接延伸到 VAD 片段结尾
      if (i == sentences.length - 1) {
        endMs = segmentEndMs;
      }

      // 保护逻辑：防止时间轴倒挂
      if (endMs <= startMs) {
        endMs = startMs + 100;
      }

      // ==========================================
      // 核心修复 1：卸磨杀驴，剥离标点符号
      // 利用带有标点的 s 完成了时间戳对齐后，输出纯净的文本，方便导出 SRT 和 UI 显示
      // ==========================================
      final finalDisplayText = s
          .replaceAll(RegExp(r'[。！？\n.!?，,；;、：:\s ▂▃▄▅▆▇█]'), '')
          .trim();

      if (finalDisplayText.isNotEmpty) {
        result.add(
          TranscribedSegment(
            startMs: startMs,
            endMs: endMs,
            text: finalDisplayText, // 放入最终剥离标点的纯文本
          ),
        );
      }
      lastEndMs = endMs;
    }

    return result;
  }

  /// 直接处理 Float32List 音频数据
  List<TranscribedSegment> processSamples(Float32List samples, int sampleRate) {
    if (samples.isEmpty) return [];
    return _processSamples(samples, sampleRate);
  }

  /// 核心处理：VAD 分段 → 每段送 ASR 识别 (同步版本)
  List<TranscribedSegment> _processSamples(
    Float32List samples,
    int sampleRate,
  ) {
    final rawSamples16k = (sampleRate == 16000)
        ? samples
        : _resampleTo16k(samples, sampleRate);

    appLog.d('[Engine] VAD 开始处理: ${rawSamples16k.length} 采样, 16000Hz');

    // ==========================================
    // 保持与异步版本一致：添加前置静音铺垫
    // ==========================================
    const int globalPreRollMs = 1500;
    const int globalPreRollSamples = (globalPreRollMs * 16000) ~/ 1000;

    final samples16k = Float32List(globalPreRollSamples + rawSamples16k.length);
    samples16k.setAll(globalPreRollSamples, rawSamples16k);

    _vad.reset();

    // 分批喂入 VAD（每批 2s），避免单次大块导致内部状态异常
    const int chunkSize = 32000;
    final result = <TranscribedSegment>[];

    for (int i = 0; i < samples16k.length; i += chunkSize) {
      final end = (i + chunkSize > samples16k.length)
          ? samples16k.length
          : i + chunkSize;
      _vad.acceptWaveform(samples16k.sublist(i, end));
    }
    _vad.flush();

    appLog.d('[Engine] VAD 清空后 isEmpty: ${_vad.isEmpty()}');

    var segmentCount = 0;
    int lastSegmentEndIdx = 0; // 记录上一个结束点，防止复读

    while (!_vad.isEmpty()) {
      final segment = _vad.front();
      _vad.pop();

      if (segment.samples.length < 1600) {
        continue;
      }

      final adjustedStart = segment.start;

      // 提取音频时，往前拿 0.5 秒，往后拿 0.2 秒
      const int padStart = 8000;
      const int padEnd = 3200;

      final startIdx = math.max(lastSegmentEndIdx, adjustedStart - padStart);
      final endIdx = math.min(
        samples16k.length,
        adjustedStart + segment.samples.length + padEnd,
      );
      lastSegmentEndIdx = endIdx;

      final speechSamples = samples16k.sublist(startIdx, endIdx);
      final stream = _recognizer.createStream();
      stream.acceptWaveform(samples: speechSamples, sampleRate: 16000);
      _recognizer.decode(stream);
      final asrResult = _recognizer.getResult(stream);
      stream.free();

      final text = _punctuator != null
          ? _applyPunctuation(asrResult.text.trim())
          : asrResult.text.trim();
      if (text.isEmpty) continue;

      // 计算真实时间，减去人工增加的 globalPreRollMs
      final baseStartMs = (startIdx * 1000 / 16000).round() - globalPreRollMs;
      final segmentEndMs = (endIdx * 1000 / 16000).round() - globalPreRollMs;

      // 调用最新的字级时间戳切割方法
      final splitSegs = _splitByTimestamps(
        punctuatedText: text,
        asrResult: asrResult,
        baseStartMs: math.max(0, baseStartMs),
        segmentEndMs: math.max(0, segmentEndMs),
      );

      segmentCount += splitSegs.length;
      result.addAll(splitSegs);
    }

    appLog.d('[Engine] 处理完成: 共 $segmentCount 个语音片段');
    return result;
  }

  /// 将句子列表按字数比例分配时间
  List<TranscribedSegment> _splitByLengthRatio(
    List<String> chunks,
    int startMs,
    int endMs,
  ) {
    if (chunks.isEmpty) return [];
    if (chunks.length == 1) {
      return [
        TranscribedSegment(
          startMs: startMs,
          endMs: endMs,
          text: chunks.first.trim(),
        ),
      ];
    }

    final duration = endMs - startMs;
    // 计算总字符数
    final totalChars = chunks.fold(
      0,
      (sum, chunk) => sum + chunk.trim().length,
    );

    final result = <TranscribedSegment>[];
    int currentStart = startMs;

    for (var i = 0; i < chunks.length; i++) {
      final s = chunks[i].trim();
      if (s.isEmpty) continue;

      // 根据当前句子字数占总字数的比例，分配这段音频的时间长度
      final ratio = totalChars > 0
          ? s.length / totalChars
          : 1.0 / chunks.length;
      final segDur = (duration * ratio).round();

      // 最后一个片段直接使用 endMs 兜底，避免时间由于精度四舍五入产生空隙
      final chunkEnd = (i == chunks.length - 1) ? endMs : currentStart + segDur;

      result.add(
        TranscribedSegment(startMs: currentStart, endMs: chunkEnd, text: s),
      );
      currentStart = chunkEnd;
    }
    return result;
  }

  /// 智能断句：兼顾句号、逗号停顿，以及最大字数限制
  List<String> _extractSentences(String text) {
    text = text.trim();
    if (text.isEmpty) return [];

    final sentences = <String>[];
    final buf = StringBuffer();
    const sentenceEnd = '。！？\n.!?';
    const clauseBreak = '，,；;、'; // 包含逗号、顿号、分号等短停顿

    for (int i = 0; i < text.length; i++) {
      buf.write(text[i]);
      final ch = text[i];

      // 1. 遇到句末标点：直接断句
      if (sentenceEnd.contains(ch)) {
        // 吞掉后续连续出现的标点（如“。。。”或“！？”）
        while (i + 1 < text.length && sentenceEnd.contains(text[i + 1])) {
          i++;
          buf.write(text[i]);
        }
        sentences.add(buf.toString().trim());
        buf.clear();
      }
      // 2. 遇到逗号/分号：如果前面已经累计了至少 8 个字，就断开作为一行，避免切得太碎
      else if (clauseBreak.contains(ch) && buf.toString().trim().length >= 8) {
        while (i + 1 < text.length && clauseBreak.contains(text[i + 1])) {
          i++;
          buf.write(text[i]);
        }
        sentences.add(buf.toString().trim());
        buf.clear();
      }
      // 3. 兜底策略：如果说话人语速很快一直没有标点，满 20 个字强制换行，保证排版是一句话一行
      else if (buf.toString().trim().length >= 20) {
        sentences.add(buf.toString().trim());
        buf.clear();
      }
    }

    // 将剩余的文本加入
    final remaining = buf.toString().trim();
    if (remaining.isNotEmpty) {
      sentences.add(remaining);
    }

    return sentences;
  }

  /// 调用标点模型为 ASR 输出加标点，去重保护
  String _applyPunctuation(String text) {
    if (_punctuator == null) return text;
    try {
      final result = _punctuator.addPunct(text);
      // 防止标点模型异常返回过长结果
      if (result.length > text.length * 3) {
        appLog.d('[Engine] 标点输出异常（长度膨胀 ${result.length}/${text.length}），回退原文');
        return text;
      }
      return result;
    } catch (e) {
      appLog.d('[Engine] 标点恢复失败: $e，回退原文');
      return text;
    }
  }

  Float32List _resampleTo16k(Float32List input, int inRate) {
    if (inRate <= 0) return input;
    final ratio = 16000.0 / inRate;
    final outLen = (input.length * ratio).round();
    final output = Float32List(outLen);
    for (int i = 0; i < outLen; i++) {
      final srcIdx = i / ratio;
      final left = srcIdx.floor();
      final right = (left + 1).clamp(0, input.length - 1);
      final frac = srcIdx - left;
      output[i] = input[left] * (1 - frac) + input[right] * frac;
    }
    return output;
  }

  void free() {
    appLog.d('[Engine] 释放资源');
    _vad.free();
    _recognizer.free();
    _punctuator?.free();
    _onlineRecognizer?.free();
  }
}

class _TokenTime {
  final String text;
  final int timeMs;
  _TokenTime(this.text, this.timeMs);
}
