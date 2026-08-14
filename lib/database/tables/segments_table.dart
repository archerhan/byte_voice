import 'package:drift/drift.dart';

/// 转写片段数据表定义 — 存储 ASR 引擎输出的每个语音片段
class SegmentsTable extends Table {
  /// 片段唯一标识（UUID，主键）
  TextColumn get id => text()();

  /// 所属笔记的 ID
  TextColumn get noteId => text()();

  /// 片段在音频中的起始毫秒
  IntColumn get startMs => integer()();

  /// 片段在音频中的结束毫秒
  IntColumn get endMs => integer()();

  /// 识别文本内容
  TextColumn get content => text()();

  /// ASR 置信度（0.0~1.0）
  RealColumn? get confidence => real().nullable()();

  /// 片段排序序号
  IntColumn get sortIndex => integer()();

  /// 主键为 id
  @override
  Set<Column> get primaryKey => {id};
}
