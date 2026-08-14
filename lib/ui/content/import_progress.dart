import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 导入进度面板 — 显示文件名和进度条
class ImportProgress extends StatelessWidget {
  final String fileName;
  final double progress;

  const ImportProgress({
    super.key,
    required this.fileName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fileName,
              style: TextStyle(
                fontSize: 14,
                color: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 320,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Color(0xFF3A3A3C),
                  valueColor: AlwaysStoppedAnimation(
                    ShadTheme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
