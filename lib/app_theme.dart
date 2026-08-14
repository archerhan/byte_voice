import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 应用主题 — 基于 BytePolar (字节极地) 视觉系统 V2（提升色彩通透度与辨识度）
class AppTheme {
  AppTheme._();

  // -- BytePolar Dark 特有颜色 --
  static const Map<String, Color> _darkCustom = <String, Color>{
    'surfaceLight': Color(0xFF1E293B),
    'textTertiary': Color(0xFF64748B),
    'accentGreen': Color(0xFF00FFCC), // 极光绿：极致纯净的荧光绿，与主色深蓝完美错开
    'sidebarBg': Color(0xFF0B111E), // 极地夜海：稍微加深，让右侧面板更浮现
    'navActiveBg': Color(0xFF1E293B),
    'toolbarBg': Color(0xFF0B111E),
    'titleBg': Color(0xFF1E293B),
  };

  // -- BytePolar Light 特有颜色 --
  static const Map<String, Color> _lightCustom = <String, Color>{
    'surfaceLight': Color(0xFFE2E8F0),
    'textTertiary': Color(0xFF94A3B8),
    'accentGreen': Color(0xFF0C8A4E), // 苔原绿：洗去灰调，换成更翠绿、清爽的北欧植物绿
    'sidebarBg': Color(0xFFF1F5F9),
    'navActiveBg': Color(0xFFE0F2FE), // 冰盖蓝：更有空气感的水蓝色选中态
    'toolbarBg': Color(0xFFF1F5F9),
    'titleBg': Color(0xFFE2E8F0),
  };

  // -- 深色 BytePolar ShadColorScheme --
  static final ShadColorScheme _darkColorScheme = ShadColorScheme(
    background: const Color(0xFF070A10),
    foreground: const Color(0xFFF8FAFC),
    card: const Color(0xFF131A26),
    cardForeground: const Color(0xFFE2E8F0),
    popover: const Color(0xFF131A26),
    popoverForeground: const Color(0xFFE2E8F0),
    primary: const Color(0xFF38BDF8), // 冰川蓝：从之前的青蓝改为了“纯净天空蓝”，彻底和绿拉开距离
    primaryForeground: const Color(0xFF070A10),
    secondary: const Color(0xFF1E293B),
    secondaryForeground: const Color(0xFF94A3B8),
    muted: const Color(0xFF1E293B),
    mutedForeground: const Color(0xFF64748B),
    accent: const Color(0xFF1E293B),
    accentForeground: const Color(0xFFF8FAFC),
    destructive: const Color(0xFFEF4444),
    destructiveForeground: const Color(0xFFFFFFFF),
    border: const Color(0xFF243147),
    input: const Color(0xFF1E293B),
    ring: const Color(0xFF38BDF8),
    selection: const Color(0xFF0369A1),
    custom: _darkCustom,
  );

  // -- 浅色 BytePolar ShadColorScheme --
  static final ShadColorScheme _lightColorScheme = ShadColorScheme(
    background: const Color(0xFFF8FAFC), // 冰界白：背景稍微提亮，更有通透感
    foreground: const Color(0xFF0F172A), // 深色字改用深邃蓝黑，更清晰
    card: const Color(0xFFFFFFFF),
    cardForeground: const Color(0xFF0F172A),
    popover: const Color(0xFFFFFFFF),
    popoverForeground: const Color(0xFF0F172A),
    primary: const Color(0xFF0284C7), // 冰川蓝：洗去灰调，采用明亮洗练的纯净湛蓝
    primaryForeground: const Color(0xFFFFFFFF),
    secondary: const Color(0xFFF1F5F9),
    secondaryForeground: const Color(0xFF475569),
    muted: const Color(0xFFF8FAFC),
    mutedForeground: const Color(0xFF64748B),
    accent: const Color(0xFFE0F2FE),
    accentForeground: const Color(0xFF0284C7),
    destructive: const Color(0xFFDC2626),
    destructiveForeground: const Color(0xFFFFFFFF),
    border: const Color(0xFFE2E8F0), // 边框更淡更精致，消灭脏感
    input: const Color(0xFFFFFFFF),
    ring: const Color(0xFF0284C7),
    selection: const Color(0xFFBAE6FD),
    custom: _lightCustom,
  );

  /// 深色 ShadThemeData
  static ShadThemeData get darkShadTheme => ShadThemeData(
    colorScheme: _darkColorScheme,
    brightness: Brightness.dark,
    primaryDialogTheme: const ShadDialogTheme(
      backgroundColor: Colors.transparent,
    ),
  );

  /// 浅色 ShadThemeData
  static ShadThemeData get lightShadTheme => ShadThemeData(
    colorScheme: _lightColorScheme,
    brightness: Brightness.light,
    primaryDialogTheme: const ShadDialogTheme(
      backgroundColor: Colors.transparent,
    ),
  );
}
