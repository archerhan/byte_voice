// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 设置仓库提供器

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// 设置仓库提供器

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// 设置仓库提供器
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'5849d89f9468753266ce5aa638352968fc190910';

/// 启动时从 SharedPreferences 读出的初始主题模式（由 main() 注入）

@ProviderFor(savedThemeMode)
final savedThemeModeProvider = SavedThemeModeProvider._();

/// 启动时从 SharedPreferences 读出的初始主题模式（由 main() 注入）

final class SavedThemeModeProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// 启动时从 SharedPreferences 读出的初始主题模式（由 main() 注入）
  SavedThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedThemeModeHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return savedThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$savedThemeModeHash() => r'09afdf64cb8d33bbccd6855f4483c2872e57cc61';

/// 模型下载服务提供器（自动初始化：拉取 Manifest、版本比对、按需更新）

@ProviderFor(modelDownloadService)
final modelDownloadServiceProvider = ModelDownloadServiceProvider._();

/// 模型下载服务提供器（自动初始化：拉取 Manifest、版本比对、按需更新）

final class ModelDownloadServiceProvider
    extends
        $FunctionalProvider<
          ModelDownloadService,
          ModelDownloadService,
          ModelDownloadService
        >
    with $Provider<ModelDownloadService> {
  /// 模型下载服务提供器（自动初始化：拉取 Manifest、版本比对、按需更新）
  ModelDownloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modelDownloadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modelDownloadServiceHash();

  @$internal
  @override
  $ProviderElement<ModelDownloadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ModelDownloadService create(Ref ref) {
    return modelDownloadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModelDownloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModelDownloadService>(value),
    );
  }
}

String _$modelDownloadServiceHash() =>
    r'436dd148d4a6e2e2b4f86b21af09b054e8f6fb54';

/// 主题模式 Notifier — 持久化并响应式共享

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// 主题模式 Notifier — 持久化并响应式共享
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// 主题模式 Notifier — 持久化并响应式共享
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'550912884a192dbe7548e84f038c75696985b3f5';

/// 主题模式 Notifier — 持久化并响应式共享

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 通知服务提供器

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// 通知服务提供器

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// 通知服务提供器
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'cda5ea9d196dce85bee56839a4a0f035021752e3';

/// 音频导入服务提供器

@ProviderFor(audioImportService)
final audioImportServiceProvider = AudioImportServiceProvider._();

/// 音频导入服务提供器

final class AudioImportServiceProvider
    extends
        $FunctionalProvider<
          AudioImportService,
          AudioImportService,
          AudioImportService
        >
    with $Provider<AudioImportService> {
  /// 音频导入服务提供器
  AudioImportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioImportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioImportServiceHash();

  @$internal
  @override
  $ProviderElement<AudioImportService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AudioImportService create(Ref ref) {
    return audioImportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioImportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioImportService>(value),
    );
  }
}

String _$audioImportServiceHash() =>
    r'758dfe00e2ca9a8b3b5549da70d9596bb99a17b2';
