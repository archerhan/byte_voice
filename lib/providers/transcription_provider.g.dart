// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 模型文件刷新触发器 — 值递增时引擎提供器重新检测文件

@ProviderFor(ModelRefresh)
final modelRefreshProvider = ModelRefreshProvider._();

/// 模型文件刷新触发器 — 值递增时引擎提供器重新检测文件
final class ModelRefreshProvider extends $NotifierProvider<ModelRefresh, int> {
  /// 模型文件刷新触发器 — 值递增时引擎提供器重新检测文件
  ModelRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelRefreshHash();

  @$internal
  @override
  ModelRefresh create() => ModelRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$modelRefreshHash() => r'699791f202bf372bc2e7c3030993a8a0e26a18bf';

/// 模型文件刷新触发器 — 值递增时引擎提供器重新检测文件

abstract class _$ModelRefresh extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 检测磁盘上已下载的模型文件，创建引擎（异步）

@ProviderFor(sherpaOnnxEngine)
final sherpaOnnxEngineProvider = SherpaOnnxEngineProvider._();

/// 检测磁盘上已下载的模型文件，创建引擎（异步）

final class SherpaOnnxEngineProvider
    extends
        $FunctionalProvider<
          AsyncValue<SherpaOnnxEngine?>,
          SherpaOnnxEngine?,
          FutureOr<SherpaOnnxEngine?>
        >
    with
        $FutureModifier<SherpaOnnxEngine?>,
        $FutureProvider<SherpaOnnxEngine?> {
  /// 检测磁盘上已下载的模型文件，创建引擎（异步）
  SherpaOnnxEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sherpaOnnxEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sherpaOnnxEngineHash();

  @$internal
  @override
  $FutureProviderElement<SherpaOnnxEngine?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SherpaOnnxEngine?> create(Ref ref) {
    return sherpaOnnxEngine(ref);
  }
}

String _$sherpaOnnxEngineHash() => r'4bb72becb4baf2e438a5a88f56ffb5b57ab31027';

/// 录音转写服务（注入引擎）

@ProviderFor(transcriptionService)
final transcriptionServiceProvider = TranscriptionServiceProvider._();

/// 录音转写服务（注入引擎）

final class TranscriptionServiceProvider
    extends
        $FunctionalProvider<
          TranscriptionService,
          TranscriptionService,
          TranscriptionService
        >
    with $Provider<TranscriptionService> {
  /// 录音转写服务（注入引擎）
  TranscriptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transcriptionServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transcriptionServiceHash();

  @$internal
  @override
  $ProviderElement<TranscriptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TranscriptionService create(Ref ref) {
    return transcriptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TranscriptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TranscriptionService>(value),
    );
  }
}

String _$transcriptionServiceHash() =>
    r'769df3d6035f4c2ef50fc87d298a7dccfbc1ee78';

/// 直播转写结果（录音中累积的片段列表）

@ProviderFor(liveTranscript)
final liveTranscriptProvider = LiveTranscriptProvider._();

/// 直播转写结果（录音中累积的片段列表）

final class LiveTranscriptProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TranscribedSegment>>,
          List<TranscribedSegment>,
          Stream<List<TranscribedSegment>>
        >
    with
        $FutureModifier<List<TranscribedSegment>>,
        $StreamProvider<List<TranscribedSegment>> {
  /// 直播转写结果（录音中累积的片段列表）
  LiveTranscriptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveTranscriptProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveTranscriptHash();

  @$internal
  @override
  $StreamProviderElement<List<TranscribedSegment>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TranscribedSegment>> create(Ref ref) {
    return liveTranscript(ref);
  }
}

String _$liveTranscriptHash() => r'16726949ee0b2b57e3cc3702fc93eb148ded1014';

/// 录音状态流

@ProviderFor(transcriptionStatus)
final transcriptionStatusProvider = TranscriptionStatusProvider._();

/// 录音状态流

final class TranscriptionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<TranscriptionStatus>,
          TranscriptionStatus,
          Stream<TranscriptionStatus>
        >
    with
        $FutureModifier<TranscriptionStatus>,
        $StreamProvider<TranscriptionStatus> {
  /// 录音状态流
  TranscriptionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transcriptionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transcriptionStatusHash();

  @$internal
  @override
  $StreamProviderElement<TranscriptionStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<TranscriptionStatus> create(Ref ref) {
    return transcriptionStatus(ref);
  }
}

String _$transcriptionStatusHash() =>
    r'9d9fa6d27651ae5679971292c6a6e05785ca41f8';

/// 声波图振幅数据流（录音中实时更新振幅快照）
/// 录音时长流（毫秒）

@ProviderFor(recordingDuration)
final recordingDurationProvider = RecordingDurationProvider._();

/// 声波图振幅数据流（录音中实时更新振幅快照）
/// 录音时长流（毫秒）

final class RecordingDurationProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// 声波图振幅数据流（录音中实时更新振幅快照）
  /// 录音时长流（毫秒）
  RecordingDurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordingDurationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordingDurationHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return recordingDuration(ref);
  }
}

String _$recordingDurationHash() => r'304448f6c1e9d7a428acaa3da6f44fde992b01e6';

@ProviderFor(waveform)
final waveformProvider = WaveformProvider._();

final class WaveformProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<double>>,
          List<double>,
          Stream<List<double>>
        >
    with $FutureModifier<List<double>>, $StreamProvider<List<double>> {
  WaveformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'waveformProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$waveformHash();

  @$internal
  @override
  $StreamProviderElement<List<double>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<double>> create(Ref ref) {
    return waveform(ref);
  }
}

String _$waveformHash() => r'a56ec7d740c197a9ee9a39a8c350360e199a6474';
