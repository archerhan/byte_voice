import 'package:drift/drift.dart';

/// 笔记数据表定义 — 使用 drift ORM 框架存储笔记元信息
class NotesTable extends Table {
  /// 笔记唯一标识（UUID，主键）
  TextColumn get id => text()();

  /// 笔记标题
  TextColumn get title => text()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 最后更新时间
  DateTimeColumn get updatedAt => dateTime()();

  /// 音频总时长（毫秒）
  IntColumn get durationMs => integer()();

  /// 永久音频文件路径
  TextColumn? get audioFilePath => text().nullable()();

  /// 是否保留音频文件
  BoolColumn get keepAudio => boolean()();

  /// 笔记来源：recording / import
  TextColumn get source => text()();

  /// 转写状态：transcribing / completed / failed
  TextColumn get status => text()();

  /// 转写进度（0.0~1.0）
  RealColumn? get currentProgress => real().nullable()();

  /// 排序位置（用于拖拽排序）
  IntColumn get position => integer().withDefault(const Constant(0))();

  /// 主键为 id
  @override
  Set<Column> get primaryKey => {id};
}
