import 'package:drift/drift.dart';
import '../../logger.dart';
import '../app_database.dart';

/// TTS 合成历史记录的数据模型
class TtsHistoryRecord {
  final String id;
  final String text;
  final int voiceId;
  final double speed;
  final String? audioFilePath;
  final DateTime createdAt;
  final int position;

  const TtsHistoryRecord({
    required this.id,
    required this.text,
    required this.voiceId,
    required this.speed,
    this.audioFilePath,
    required this.createdAt,
    this.position = 0,
  });

  TtsHistoryRecord copyWith({
    String? id,
    String? text,
    int? voiceId,
    double? speed,
    String? audioFilePath,
    DateTime? createdAt,
    int? position,
  }) {
    return TtsHistoryRecord(
      id: id ?? this.id,
      text: text ?? this.text,
      voiceId: voiceId ?? this.voiceId,
      speed: speed ?? this.speed,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      createdAt: createdAt ?? this.createdAt,
      position: position ?? this.position,
    );
  }
}

/// TTS 合成历史仓库 — 封装 tts_history_table 的增删改查
class TtsHistoryRepository {
  final AppDatabase _db;

  TtsHistoryRepository(this._db);

  /// 获取所有历史记录（按创建时间倒序）
  Future<List<TtsHistoryRecord>> getAll() async {
    appLog.d('[TtsHistoryRepo] 查询所有记录');
    final query = _db.ttsHistoryTable.select()
      ..orderBy([(t) => OrderingTerm.desc(t.position)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  /// 根据 ID 获取单条记录
  Future<TtsHistoryRecord?> getById(String id) async {
    appLog.d('[TtsHistoryRepo] 查询记录: id=$id');
    final query = _db.ttsHistoryTable.select()..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toModel(row) : null;
  }

  /// 插入一条新记录
  Future<TtsHistoryRecord> create(TtsHistoryRecord record) async {
    appLog.i('[TtsHistoryRepo] 创建记录: id=${record.id}');
    await _db.into(_db.ttsHistoryTable).insert(_toCompanion(record));
    return record;
  }

  /// 更新记录的音频路径（合成完成后写入）
  Future<TtsHistoryRecord> updateAudioPath({
    required String id,
    required String audioFilePath,
  }) async {
    appLog.d('[TtsHistoryRepo] 更新音频路径: id=$id');
    await (_db.update(_db.ttsHistoryTable)..where((t) => t.id.equals(id)))
        .write(TtsHistoryTableCompanion(audioFilePath: Value(audioFilePath)));
    return (await getById(id))!;
  }

  /// 根据 ID 删除一条记录
  /// 更新文本内容（重命名）
  Future<void> updateText(String id, String newText) async {
    await (_db.update(_db.ttsHistoryTable)..where((t) => t.id.equals(id)))
        .write(TtsHistoryTableCompanion(content: Value(newText)));
  }

  /// 批量更新排序位置
  Future<void> updatePositions(List<MapEntry<String, int>> entries) async {
    await _db.batch((batch) {
      for (final e in entries) {
        batch.update(
          _db.ttsHistoryTable,
          TtsHistoryTableCompanion(position: Value(e.value)),
          where: (t) => t.id.equals(e.key),
        );
      }
    });
  }

  Future<void> delete(String id) async {
    appLog.i('[TtsHistoryRepo] 删除记录: id=$id');
    await (_db.delete(_db.ttsHistoryTable)..where((t) => t.id.equals(id))).go();
  }

  /// 删除所有记录
  Future<void> deleteAll() async {
    appLog.i('[TtsHistoryRepo] 清空所有记录');
    await _db.delete(_db.ttsHistoryTable).go();
  }

  TtsHistoryRecord _toModel(TtsHistoryTableData row) => TtsHistoryRecord(
    id: row.id,
    text: row.content,
    voiceId: row.voiceId,
    speed: row.speed,
    audioFilePath: row.audioFilePath,
    createdAt: row.createdAt,
    position: row.position,
  );

  TtsHistoryTableCompanion _toCompanion(TtsHistoryRecord r) =>
      TtsHistoryTableCompanion(
        id: Value(r.id),
        content: Value(r.text),
        voiceId: Value(r.voiceId),
        speed: Value(r.speed),
        audioFilePath: Value(r.audioFilePath),
        createdAt: Value(r.createdAt),
        position: Value(r.position),
      );
}
