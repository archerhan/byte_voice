import 'package:logger/logger.dart' as l;

/// 全局日志实例 — 直接使用 `appLog.i(...)` / `d(...)` / `e(...)` 等
final l.Logger appLog = l.Logger(
  filter: l.DevelopmentFilter(),
  printer: l.PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);
