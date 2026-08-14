// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_playback_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 音频播放控制器 — 使用 @riverpod Notifier 模式替代 ChangeNotifier

@ProviderFor(AudioPlaybackController)
final audioPlaybackControllerProvider = AudioPlaybackControllerProvider._();

/// 音频播放控制器 — 使用 @riverpod Notifier 模式替代 ChangeNotifier
final class AudioPlaybackControllerProvider
    extends $NotifierProvider<AudioPlaybackController, AudioPlaybackState> {
  /// 音频播放控制器 — 使用 @riverpod Notifier 模式替代 ChangeNotifier
  AudioPlaybackControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlaybackControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlaybackControllerHash();

  @$internal
  @override
  AudioPlaybackController create() => AudioPlaybackController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlaybackState>(value),
    );
  }
}

String _$audioPlaybackControllerHash() =>
    r'400fe1bc1b9aa43c261979c74a4400d13594c03c';

/// 音频播放控制器 — 使用 @riverpod Notifier 模式替代 ChangeNotifier

abstract class _$AudioPlaybackController extends $Notifier<AudioPlaybackState> {
  AudioPlaybackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AudioPlaybackState, AudioPlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioPlaybackState, AudioPlaybackState>,
              AudioPlaybackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
