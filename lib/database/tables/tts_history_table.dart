import 'package:drift/drift.dart';

/// TTS 合成历史数据表 — 存储每次合成的文字、音色参数和音频文件路径
class TtsHistoryTable extends Table {
  /// 唯一标识（UUID，主键）
  TextColumn get id => text()();

  /// 合成的文本内容
  TextColumn get content => text()();

  /// 音色 ID
  IntColumn get voiceId => integer()();

  /// 语速
  RealColumn get speed => real()();

  /// 合成音频文件路径（可能为空，表示合成失败或尚未合成）
  TextColumn? get audioFilePath => text().nullable()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime()();

  /// 排序位置（用于拖拽排序）
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
