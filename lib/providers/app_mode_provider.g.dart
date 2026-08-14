// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 当前应用模式，默认 ASR

@ProviderFor(AppModeController)
final appModeControllerProvider = AppModeControllerProvider._();

/// 当前应用模式，默认 ASR
final class AppModeControllerProvider
    extends $NotifierProvider<AppModeController, AppMode> {
  /// 当前应用模式，默认 ASR
  AppModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appModeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appModeControllerHash();

  @$internal
  @override
  AppModeController create() => AppModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppMode>(value),
    );
  }
}

String _$appModeControllerHash() => r'fea11698b523eb5890437be993c7aa812c30b4b3';

/// 当前应用模式，默认 ASR

abstract class _$AppModeController extends $Notifier<AppMode> {
  AppMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppMode, AppMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppMode, AppMode>,
              AppMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
