import 'package:drift/drift.dart';
import '../../logger.dart';
import '../app_database.dart';
import '../../models/note.dart';
import '../../models/note_status.dart';

/// 笔记数据仓库 — 封装 notes_table 的增删改查操作
class NotesRepository {
  /// 数据库引用
  final AppDatabase _db;

  /// 构造仓库，注入数据库实例
  NotesRepository(this._db);

  /// 获取所有笔记（按创建时间倒序）
  Future<List<Note>> getAll() async {
    appLog.i('[Repo] 查询所有笔记');
    final query = _db.notesTable.select()
      ..orderBy([(t) => OrderingTerm.desc(t.position)]);
    final rows = await query.get();
    final notes = rows.map(_toModel).toList();
    appLog.d('[Repo] 查询到 ${notes.length} 条笔记');
    return notes;
  }

  /// 根据 ID 获取单条笔记
  Future<Note?> getById(String id) async {
    appLog.d('[Repo] 查询笔记: id=$id');
    final query = _db.notesTable.select()..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    appLog.d('[Repo] 笔记${row != null ? "找到" : "未找到"}: id=$id');
    return row != null ? _toModel(row) : null;
  }

  /// 创建一条笔记记录
  Future<Note> create(Note note) async {
    appLog.i('[Repo] 创建笔记: id=${note.id}, title=${note.title}');
    await _db.into(_db.notesTable).insert(_toCompanion(note));
    return note;
  }

  /// 更新一条笔记记录
  Future<Note> update(Note note) async {
    appLog.i(
      '[Repo] 更新笔记: id=${note.id}, title=${note.title}, status=${note.status.name}',
    );
    await (_db.update(
      _db.notesTable,
    )..where((t) => t.id.equals(note.id))).write(_toCompanion(note));
    return note;
  }

  /// 根据 ID 删除一条笔记
  Future<void> delete(String id) async {
    appLog.i('[Repo] 删除笔记: id=$id');
    await (_db.delete(_db.notesTable)..where((t) => t.id.equals(id))).go();
  }

  /// 批量更新排序位置
  Future<void> updatePositions(List<MapEntry<String, int>> entries) async {
    await _db.batch((batch) {
      for (final e in entries) {
        batch.update(
          _db.notesTable,
          NotesTableCompanion(position: Value(e.value)),
          where: (t) => t.id.equals(e.key),
        );
      }
    });
  }

  /// 将数据库行转换为 Note 模型
  Note _toModel(NotesTableData row) => Note(
    id: row.id,
    title: row.title,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    durationMs: row.durationMs,
    audioFilePath: row.audioFilePath,
    keepAudio: row.keepAudio,
    source: row.source == 'import' ? NoteSource.import : NoteSource.recording,
    status: NoteStatus.values.firstWhere((s) => s.name == row.status),
    currentProgress: row.currentProgress,
    position: row.position,
  );

  /// 将 Note 模型转换为数据库插入/更新对象
  NotesTableCompanion _toCompanion(Note note) => NotesTableCompanion(
    id: Value(note.id),
    title: Value(note.title),
    createdAt: Value(note.createdAt),
    updatedAt: Value(note.updatedAt),
    durationMs: Value(note.durationMs),
    audioFilePath: Value(note.audioFilePath),
    keepAudio: Value(note.keepAudio),
    source: Value(note.source.name),
    status: Value(note.status.name),
    currentProgress: Value(note.currentProgress),
    position: Value(note.position),
  );
}
