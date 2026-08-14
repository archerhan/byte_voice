import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../logger.dart';
import '../database/repositories/notes_repository.dart';
import '../database/app_database.dart';
import '../models/note.dart';
import '../services/export_service.dart';
import '../database/repositories/segments_repository.dart';
import '../models/segment.dart';

part 'notes_provider.g.dart';

/// 数据库实例提供器
@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

/// 笔记仓库提供器
@riverpod
NotesRepository notesRepository(Ref ref) {
  return NotesRepository(ref.watch(appDatabaseProvider));
}

/// 处理状态：导入/转写进行中
class ProcessingState {
  final String message;
  final double? progress; // null=不确定进度
  const ProcessingState({this.message = '', this.progress});
  static const none = ProcessingState();
  bool get isProcessing => message.isNotEmpty;
}

/// 当前处理状态
@riverpod
class ProcessingStateController extends _$ProcessingStateController {
  @override
  ProcessingState build() => ProcessingState.none;

  void set(ProcessingState value) => state = value;
}

/// 按笔记 ID 追踪处理进度（导入 / 转写中）
@riverpod
class ProcessingNotes extends _$ProcessingNotes {
  @override
  Map<String, ProcessingState> build() => {};

  void update(Map<String, ProcessingState> Function(Map<String, ProcessingState>) fn) {
    state = fn(state);
  }
}

/// 当前选中的笔记 ID
@riverpod
class SelectedNoteId extends _$SelectedNoteId {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

/// 片段仓库提供器
@riverpod
SegmentsRepository segmentsRepository(Ref ref) {
  return SegmentsRepository(ref.watch(appDatabaseProvider));
}

/// 笔记列表提供器（异步 — 每次 invalidate 都会重新查询数据库）
@riverpod
Future<List<Note>> notes(Ref ref) async {
  appLog.d('[Provider] 刷新笔记列表');
  final notes = await ref.watch(notesRepositoryProvider).getAll();
  return notes;
}

/// 当前选中笔记的片段列表提供器
@riverpod
Future<List<Segment>> selectedNoteSegments(Ref ref) async {
  // ⚠️ 使用 ref.read 而非 ref.watch，避免重建时订阅重新触发导致 double rebuild
  final noteId = ref.read(selectedNoteIdProvider);
  if (noteId == null) {
    appLog.d('[Provider] 未选中笔记，返回空片段列表');
    return [];
  }
  appLog.d('[Provider] 加载笔记片段: noteId=$noteId');
  return ref.read(segmentsRepositoryProvider).getByNoteId(noteId);
}

/// 导出服务提供器
@riverpod
ExportService exportService(Ref ref) => ExportService();
