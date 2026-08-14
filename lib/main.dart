import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'providers/settings_provider.dart';
import 'ui/main_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 预先读取用户保存的主题，避免启动时先显示默认主题再闪变
  final prefs = await SharedPreferences.getInstance();
  final savedThemeMode = prefs.getString('bytevoice_theme_mode');

  runApp(
    ProviderScope(
      overrides: [savedThemeModeProvider.overrideWithValue(savedThemeMode)],
      child: const ByteVoiceApp(),
    ),
  );
}

class ByteVoiceApp extends ConsumerWidget {
  const ByteVoiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return ShadApp(
      title: 'Byte Voice',
      theme: AppTheme.lightShadTheme,
      darkTheme: AppTheme.darkShadTheme,
      themeMode: themeMode,
      home: MainWindow(),
    );
  }
}
