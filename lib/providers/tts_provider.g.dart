// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 当前选中的 TTS 音色 ID

@ProviderFor(TtsSelectedVoiceId)
final ttsSelectedVoiceIdProvider = TtsSelectedVoiceIdProvider._();

/// 当前选中的 TTS 音色 ID
final class TtsSelectedVoiceIdProvider
    extends $NotifierProvider<TtsSelectedVoiceId, int> {
  /// 当前选中的 TTS 音色 ID
  TtsSelectedVoiceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSelectedVoiceIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSelectedVoiceIdHash();

  @$internal
  @override
  TtsSelectedVoiceId create() => TtsSelectedVoiceId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$ttsSelectedVoiceIdHash() =>
    r'ffc9b50845370e4d4cd430dbae84a67859cb731d';

/// 当前选中的 TTS 音色 ID

abstract class _$TtsSelectedVoiceId extends $Notifier<int> {
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

/// 语速倍数（0.5 - 2.0）

@ProviderFor(TtsSpeed)
final ttsSpeedProvider = TtsSpeedProvider._();

/// 语速倍数（0.5 - 2.0）
final class TtsSpeedProvider extends $NotifierProvider<TtsSpeed, double> {
  /// 语速倍数（0.5 - 2.0）
  TtsSpeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSpeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSpeedHash();

  @$internal
  @override
  TtsSpeed create() => TtsSpeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$ttsSpeedHash() => r'0a6d7310aed5e97217d00d6123970fcfa0a577f0';

/// 语速倍数（0.5 - 2.0）

abstract class _$TtsSpeed extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 是否正在合成

@ProviderFor(TtsSynthesizing)
final ttsSynthesizingProvider = TtsSynthesizingProvider._();

/// 是否正在合成
final class TtsSynthesizingProvider
    extends $NotifierProvider<TtsSynthesizing, bool> {
  /// 是否正在合成
  TtsSynthesizingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsSynthesizingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsSynthesizingHash();

  @$internal
  @override
  TtsSynthesizing create() => TtsSynthesizing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ttsSynthesizingHash() => r'86ed02851f75829904298125f45bec4056935fc3';

/// 是否正在合成

abstract class _$TtsSynthesizing extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 合成结果的文件路径（由 TTS 服务写入临时文件后供播放器使用）

@ProviderFor(TtsOutputFilePath)
final ttsOutputFilePathProvider = TtsOutputFilePathProvider._();

/// 合成结果的文件路径（由 TTS 服务写入临时文件后供播放器使用）
final class TtsOutputFilePathProvider
    extends $NotifierProvider<TtsOutputFilePath, String?> {
  /// 合成结果的文件路径（由 TTS 服务写入临时文件后供播放器使用）
  TtsOutputFilePathProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsOutputFilePathProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsOutputFilePathHash();

  @$internal
  @override
  TtsOutputFilePath create() => TtsOutputFilePath();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$ttsOutputFilePathHash() => r'b5605f22a0a17e1095513ecab73c99b3145593bf';

/// 合成结果的文件路径（由 TTS 服务写入临时文件后供播放器使用）

abstract class _$TtsOutputFilePath extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// TTS 历史仓库提供器

@ProviderFor(ttsHistoryRepository)
final ttsHistoryRepositoryProvider = TtsHistoryRepositoryProvider._();

/// TTS 历史仓库提供器

final class TtsHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          TtsHistoryRepository,
          TtsHistoryRepository,
          TtsHistoryRepository
        >
    with $Provider<TtsHistoryRepository> {
  /// TTS 历史仓库提供器
  TtsHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsHistoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<TtsHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TtsHistoryRepository create(Ref ref) {
    return ttsHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsHistoryRepository>(value),
    );
  }
}

String _$ttsHistoryRepositoryHash() =>
    r'cd373877b4ea52f298bced9d8a1ed883bed14efb';

/// TTS 历史记录列表（异步 — 每次 invalidate 都会重新查询数据库）

@ProviderFor(ttsHistoryList)
final ttsHistoryListProvider = TtsHistoryListProvider._();

/// TTS 历史记录列表（异步 — 每次 invalidate 都会重新查询数据库）

final class TtsHistoryListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TtsHistoryRecord>>,
          List<TtsHistoryRecord>,
          FutureOr<List<TtsHistoryRecord>>
        >
    with
        $FutureModifier<List<TtsHistoryRecord>>,
        $FutureProvider<List<TtsHistoryRecord>> {
  /// TTS 历史记录列表（异步 — 每次 invalidate 都会重新查询数据库）
  TtsHistoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsHistoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsHistoryListHash();

  @$internal
  @override
  $FutureProviderElement<List<TtsHistoryRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TtsHistoryRecord>> create(Ref ref) {
    return ttsHistoryList(ref);
  }
}

String _$ttsHistoryListHash() => r'3d3bd801624b7cca846a60c35852b91e39a6c292';

/// 当前选中的 TTS 历史记录 ID

@ProviderFor(SelectedTtsHistoryId)
final selectedTtsHistoryIdProvider = SelectedTtsHistoryIdProvider._();

/// 当前选中的 TTS 历史记录 ID
final class SelectedTtsHistoryIdProvider
    extends $NotifierProvider<SelectedTtsHistoryId, String?> {
  /// 当前选中的 TTS 历史记录 ID
  SelectedTtsHistoryIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTtsHistoryIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTtsHistoryIdHash();

  @$internal
  @override
  SelectedTtsHistoryId create() => SelectedTtsHistoryId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedTtsHistoryIdHash() =>
    r'c3ddf99a4a9c7ad646629c1248d6aa5cc6a25841';

/// 当前选中的 TTS 历史记录 ID

abstract class _$SelectedTtsHistoryId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// TTS 重命名刷新触发器（递增时右侧重新加载当前记录）

@ProviderFor(TtsRenameRefresh)
final ttsRenameRefreshProvider = TtsRenameRefreshProvider._();

/// TTS 重命名刷新触发器（递增时右侧重新加载当前记录）
final class TtsRenameRefreshProvider
    extends $NotifierProvider<TtsRenameRefresh, int> {
  /// TTS 重命名刷新触发器（递增时右侧重新加载当前记录）
  TtsRenameRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsRenameRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsRenameRefreshHash();

  @$internal
  @override
  TtsRenameRefresh create() => TtsRenameRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$ttsRenameRefreshHash() => r'f2dd31180f8458e3b2505e8e7a0eb50b4c790084';

/// TTS 重命名刷新触发器（递增时右侧重新加载当前记录）

abstract class _$TtsRenameRefresh extends $Notifier<int> {
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

/// 异步加载 TTS 引擎，模型文件就绪时返回 OfflineTts 实例

@ProviderFor(ttsOfflineEngine)
final ttsOfflineEngineProvider = TtsOfflineEngineProvider._();

/// 异步加载 TTS 引擎，模型文件就绪时返回 OfflineTts 实例

final class TtsOfflineEngineProvider
    extends
        $FunctionalProvider<
          AsyncValue<OfflineTts?>,
          OfflineTts?,
          FutureOr<OfflineTts?>
        >
    with $FutureModifier<OfflineTts?>, $FutureProvider<OfflineTts?> {
  /// 异步加载 TTS 引擎，模型文件就绪时返回 OfflineTts 实例
  TtsOfflineEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsOfflineEngineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsOfflineEngineHash();

  @$internal
  @override
  $FutureProviderElement<OfflineTts?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OfflineTts?> create(Ref ref) {
    return ttsOfflineEngine(ref);
  }
}

String _$ttsOfflineEngineHash() => r'3d9453aa37c36629949f90f5df1be3259e40dd8d';
