import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/repositories/settings_repository.dart';
import '../services/model_download_service.dart';
import '../services/notification_service.dart';
import '../services/audio_import_service.dart';
import 'transcription_provider.dart';

part 'settings_provider.g.dart';

/// 设置仓库提供器
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository();
}

/// 启动时从 SharedPreferences 读出的初始主题模式（由 main() 注入）
@riverpod
String? savedThemeMode(Ref ref) => null;

/// 模型下载服务提供器（自动初始化：拉取 Manifest、版本比对、按需更新）
@riverpod
ModelDownloadService modelDownloadService(Ref ref) {
  final service = ModelDownloadService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
}

/// 主题模式 Notifier — 持久化并响应式共享
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // 从 main() 预注入的 savedThemeModeProvider 中同步读取
    final saved = ref.read(savedThemeModeProvider);
    if (saved == 'light') return ThemeMode.light;
    if (saved == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final repo = ref.read(settingsRepositoryProvider);
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
    }
    await repo.setThemeMode(value);
  }
}

/// 通知服务提供器
@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}

/// 音频导入服务提供器
@riverpod
AudioImportService audioImportService(Ref ref) {
  final engineAsync = ref.watch(sherpaOnnxEngineProvider);
  final engine = engineAsync.value;
  final service = AudioImportService(engine: engine);
  ref.onDispose(() => service.dispose());
  return service;
}
