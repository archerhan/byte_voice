import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../logger.dart';
import 'tables/notes_table.dart';
import 'tables/segments_table.dart';
import 'tables/tts_history_table.dart';

part 'app_database.g.dart';

/// 应用数据库 — 使用 drift ORM 管理 SQLite 持久化
/// 包含笔记表（notes_table）、片段表（segments_table）和 TTS 历史表（tts_history_table）
@DriftDatabase(tables: [NotesTable, SegmentsTable, TtsHistoryTable])
class AppDatabase extends _$AppDatabase {
  /// 构造数据库实例，自动初始化延迟连接
  AppDatabase() : super(_openConnection());

  /// 数据库架构版本号（增量迁移用）
  @override
  int get schemaVersion => 3;

  /// 数据库迁移策略
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(ttsHistoryTable);
      }
      if (from < 3) {
        await m.addColumn(notesTable, notesTable.position);
        await m.addColumn(ttsHistoryTable, ttsHistoryTable.position);
      }
    },
  );
}

/// 创建延迟 SQLite 连接
/// 数据库文件位于系统应用支持目录下的 byte_voice.db
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final dataDir = Directory(p.join(dir.path, 'data'));
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    final file = File(p.join(dataDir.path, 'byte_voice.db'));
    appLog.i('[DB] 数据库路径: ${file.path}');
    return NativeDatabase(file);
  });
}
