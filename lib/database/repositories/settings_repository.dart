import '../../logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用设置仓库 — 封装 SharedPreferences 的读写操作
/// 所有 key 自动添加 bytevoice_ 前缀以避免命名冲突
class SettingsRepository {
  /// SharedPreferences key 前缀
  static const _prefix = 'bytevoice_';

  /// 获取字符串类型的设置项
  Future<String?> get(String key) async {
    final sharedKey = '$_prefix$key';
    appLog.d('[Settings] 读取设置: $sharedKey');
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedKey);
  }

  /// 设置字符串类型的配置项
  Future<void> set(String key, String value) async {
    final sharedKey = '$_prefix$key';
    appLog.d('[Settings] 写入设置: $sharedKey=$value');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedKey, value);
  }

  /// 获取设置值，若为 null 则返回默认值
  Future<String> getOrDefault(String key, String defaultValue) async {
    final val = await get(key);
    return val ?? defaultValue;
  }

  /// 主题模式：light / dark / system
  Future<String> getThemeMode() async => getOrDefault('theme_mode', 'system');

  /// 设置主题模式
  Future<void> setThemeMode(String mode) async => set('theme_mode', mode);
}
