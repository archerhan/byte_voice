import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'model_status_badge.dart';

/// macOS unified title bar — thin bar merged into the system title bar area.
/// System traffic lights (close/minimize/zoom) are native — we add a
/// left padding of ~72px to avoid overlapping them.
/// macOS 统一标题栏 — 融合到系统标题栏区域
class AppTitleBar extends StatelessWidget {
  final String title;
  final VoidCallback? onSettings;

  const AppTitleBar({super.key, this.title = 'Byte Voice', this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: EdgeInsets.only(left: 74, right: 12),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.custom['titleBg']!,
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1E))),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE5E5E7),
            ),
          ),
          Spacer(),
          ModelStatusBadge(),
          SizedBox(width: 12),
          GestureDetector(
            onTap: onSettings,
            child: Icon(Icons.settings, size: 16, color: Color(0xFF98989D)),
          ),
        ],
      ),
    );
  }
}
