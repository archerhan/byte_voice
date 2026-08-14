import 'package:drift/drift.dart';
import '../../logger.dart';
import '../app_database.dart';
import '../../models/segment.dart';

/// 转写片段数据仓库 — 封装 segments_table 的增删改查操作
class SegmentsRepository {
  /// 数据库引用
  final AppDatabase _db;

  /// 构造仓库，注入数据库实例
  SegmentsRepository(this._db);

  /// 根据笔记 ID 获取所有片段（按 sortIndex 升序）
  Future<List<Segment>> getByNoteId(String noteId) async {
    appLog.d('[Repo] 查询笔记片段: noteId=$noteId');
    final query = _db.segmentsTable.select()
      ..where((t) => t.noteId.equals(noteId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]);
    final rows = await query.get();
    final segments = rows.map(_toModel).toList();
    appLog.d('[Repo] 笔记 $noteId 有 ${segments.length} 个片段');
    return segments;
  }

  /// 批量插入片段（在转写完成后一次写入数据库）
  Future<void> bulkInsert(List<Segment> segments) async {
    appLog.i('[Repo] 批量保存 ${segments.length} 个片段');
    await _db.batch((batch) {
      for (final s in segments) {
        batch.insert(_db.segmentsTable, _toCompanion(s));
      }
    });
  }

  /// 更新单个片段的文本内容（用户编辑时调用）
  Future<void> updateText(String id, String text) async {
    appLog.d('[Repo] 更新片段文本: id=$id');
    await (_db.update(_db.segmentsTable)..where((t) => t.id.equals(id))).write(
      SegmentsTableCompanion(content: Value(text)),
    );
  }

  /// 删除笔记下的所有片段（删除笔记时调用）
  Future<void> deleteByNoteId(String noteId) async {
    appLog.i('[Repo] 删除笔记片段: noteId=$noteId');
    await (_db.delete(
      _db.segmentsTable,
    )..where((t) => t.noteId.equals(noteId))).go();
  }

  /// 将数据库行转换为 Segment 模型
  Segment _toModel(SegmentsTableData row) => Segment(
    id: row.id,
    noteId: row.noteId,
    startMs: row.startMs,
    endMs: row.endMs,
    text: row.content,
    confidence: row.confidence,
    sortIndex: row.sortIndex,
  );

  /// 将 Segment 模型转换为数据库插入对象
  SegmentsTableCompanion _toCompanion(Segment s) => SegmentsTableCompanion(
    id: Value(s.id),
    noteId: Value(s.noteId),
    startMs: Value(s.startMs),
    endMs: Value(s.endMs),
    content: Value(s.text),
    confidence: Value(s.confidence),
    sortIndex: Value(s.sortIndex),
  );
}
