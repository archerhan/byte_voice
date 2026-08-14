import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 空状态占位 — 未选中笔记时的引导界面
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 48,
            color: ShadTheme.of(
              context,
            ).colorScheme.custom['textTertiary']!.withValues(alpha: 0.4),
          ),
          SizedBox(height: 12),
          Text(
            '点击录音或拖入文件开始',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '支持 mp3, m4a, wav, ogg, flac, aac',
            style: TextStyle(
              fontSize: 13,
              color: ShadTheme.of(context).colorScheme.custom['textTertiary']!,
            ),
          ),
        ],
      ),
    );
  }
}
