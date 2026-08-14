// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 数据库实例提供器

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// 数据库实例提供器

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// 数据库实例提供器
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'd45cc0b6c7795466b6a12d864805fefa097f39cd';

/// 笔记仓库提供器

@ProviderFor(notesRepository)
final notesRepositoryProvider = NotesRepositoryProvider._();

/// 笔记仓库提供器

final class NotesRepositoryProvider
    extends
        $FunctionalProvider<NotesRepository, NotesRepository, NotesRepository>
    with $Provider<NotesRepository> {
  /// 笔记仓库提供器
  NotesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesRepository create(Ref ref) {
    return notesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesRepository>(value),
    );
  }
}

String _$notesRepositoryHash() => r'5ba05ae589425c2d4f7d3cbca95bc04020de40d8';

/// 当前处理状态

@ProviderFor(ProcessingStateController)
final processingStateControllerProvider = ProcessingStateControllerProvider._();

/// 当前处理状态
final class ProcessingStateControllerProvider
    extends $NotifierProvider<ProcessingStateController, ProcessingState> {
  /// 当前处理状态
  ProcessingStateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'processingStateControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$processingStateControllerHash();

  @$internal
  @override
  ProcessingStateController create() => ProcessingStateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProcessingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProcessingState>(value),
    );
  }
}

String _$processingStateControllerHash() =>
    r'777a894424c2275b004a0fbb47069c6efc6ccc27';

/// 当前处理状态

abstract class _$ProcessingStateController extends $Notifier<ProcessingState> {
  ProcessingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProcessingState, ProcessingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProcessingState, ProcessingState>,
              ProcessingState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 按笔记 ID 追踪处理进度（导入 / 转写中）

@ProviderFor(ProcessingNotes)
final processingNotesProvider = ProcessingNotesProvider._();

/// 按笔记 ID 追踪处理进度（导入 / 转写中）
final class ProcessingNotesProvider
    extends $NotifierProvider<ProcessingNotes, Map<String, ProcessingState>> {
  /// 按笔记 ID 追踪处理进度（导入 / 转写中）
  ProcessingNotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'processingNotesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$processingNotesHash();

  @$internal
  @override
  ProcessingNotes create() => ProcessingNotes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ProcessingState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ProcessingState>>(value),
    );
  }
}

String _$processingNotesHash() => r'26a874c232289502d60f3ebc5b476f3ca8775e6e';

/// 按笔记 ID 追踪处理进度（导入 / 转写中）

abstract class _$ProcessingNotes
    extends $Notifier<Map<String, ProcessingState>> {
  Map<String, ProcessingState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<Map<String, ProcessingState>, Map<String, ProcessingState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, ProcessingState>,
                Map<String, ProcessingState>
              >,
              Map<String, ProcessingState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 当前选中的笔记 ID

@ProviderFor(SelectedNoteId)
final selectedNoteIdProvider = SelectedNoteIdProvider._();

/// 当前选中的笔记 ID
final class SelectedNoteIdProvider
    extends $NotifierProvider<SelectedNoteId, String?> {
  /// 当前选中的笔记 ID
  SelectedNoteIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNoteIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNoteIdHash();

  @$internal
  @override
  SelectedNoteId create() => SelectedNoteId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedNoteIdHash() => r'bd56687d553b0677d2704f955560aff6252331d2';

/// 当前选中的笔记 ID

abstract class _$SelectedNoteId extends $Notifier<String?> {
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

/// 片段仓库提供器

@ProviderFor(segmentsRepository)
final segmentsRepositoryProvider = SegmentsRepositoryProvider._();

/// 片段仓库提供器

final class SegmentsRepositoryProvider
    extends
        $FunctionalProvider<
          SegmentsRepository,
          SegmentsRepository,
          SegmentsRepository
        >
    with $Provider<SegmentsRepository> {
  /// 片段仓库提供器
  SegmentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'segmentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$segmentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SegmentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SegmentsRepository create(Ref ref) {
    return segmentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SegmentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SegmentsRepository>(value),
    );
  }
}

String _$segmentsRepositoryHash() =>
    r'3a95576ba01288aafeecb1ba53731e420b872ef8';

/// 笔记列表提供器（异步 — 每次 invalidate 都会重新查询数据库）

@ProviderFor(notes)
final notesProvider = NotesProvider._();

/// 笔记列表提供器（异步 — 每次 invalidate 都会重新查询数据库）

final class NotesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Note>>,
          List<Note>,
          FutureOr<List<Note>>
        >
    with $FutureModifier<List<Note>>, $FutureProvider<List<Note>> {
  /// 笔记列表提供器（异步 — 每次 invalidate 都会重新查询数据库）
  NotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesHash();

  @$internal
  @override
  $FutureProviderElement<List<Note>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Note>> create(Ref ref) {
    return notes(ref);
  }
}

String _$notesHash() => r'9e719800e3362ca205eb720079746a67907812fb';

/// 当前选中笔记的片段列表提供器

@ProviderFor(selectedNoteSegments)
final selectedNoteSegmentsProvider = SelectedNoteSegmentsProvider._();

/// 当前选中笔记的片段列表提供器

final class SelectedNoteSegmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Segment>>,
          List<Segment>,
          FutureOr<List<Segment>>
        >
    with $FutureModifier<List<Segment>>, $FutureProvider<List<Segment>> {
  /// 当前选中笔记的片段列表提供器
  SelectedNoteSegmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNoteSegmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNoteSegmentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Segment>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Segment>> create(Ref ref) {
    return selectedNoteSegments(ref);
  }
}

String _$selectedNoteSegmentsHash() =>
    r'271a35be97492e6b5f3247ab312ad2cf4b27d062';

/// 导出服务提供器

@ProviderFor(exportService)
final exportServiceProvider = ExportServiceProvider._();

/// 导出服务提供器

final class ExportServiceProvider
    extends $FunctionalProvider<ExportService, ExportService, ExportService>
    with $Provider<ExportService> {
  /// 导出服务提供器
  ExportServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportServiceHash();

  @$internal
  @override
  $ProviderElement<ExportService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportService create(Ref ref) {
    return exportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportService>(value),
    );
  }
}

String _$exportServiceHash() => r'1ad1ab4c9dedadf438237492e14472b491c1cdad';
