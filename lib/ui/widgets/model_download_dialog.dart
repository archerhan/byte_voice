import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/settings_provider.dart';
import '../../services/model_download_service.dart';

/// 模型下载弹窗 — 可关闭但下载任务继续
class ModelDownloadDialog extends ConsumerStatefulWidget {
  const ModelDownloadDialog({super.key});

  @override
  ConsumerState<ModelDownloadDialog> createState() =>
      _ModelDownloadDialogState();
}

class _ModelDownloadDialogState extends ConsumerState<ModelDownloadDialog> {
  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(modelDownloadServiceProvider);
    final states = svc.states;
    final models = svc.models;

    // 计算整体进度
    double totalSize = 0;
    double completedSize = 0;
    for (final m in models) {
      final s = states[m.key] ?? ModelDownloadState.notDownloaded;
      final p = svc.progress[m.key] ?? 0.0;
      totalSize += m.sizeMb;
      if (s == ModelDownloadState.downloaded) {
        completedSize += m.sizeMb;
      } else if (s == ModelDownloadState.downloading) {
        completedSize += m.sizeMb * p;
      } else if (s == ModelDownloadState.processing) {
        completedSize += m.sizeMb;
      }
    }
    final overallProgress =
        totalSize > 0 ? (completedSize / totalSize).clamp(0.0, 1.0) : 0.0;
    final allDone = models.isNotEmpty &&
        models.every(
          (m) => svc.states[m.key] == ModelDownloadState.downloaded,
        );

    final theme = ShadTheme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 500,
          height: 420,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.custom['sidebarBg']!,
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.download,
                      size: 18,
                      color: theme.colorScheme.foreground,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '下载模型',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      allDone ? '已完成' : '\${(overallProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: allDone
                            ? theme.colorScheme.custom['accentGreen']!
                            : theme.colorScheme.mutedForeground,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: allDone ? 1.0 : overallProgress,
                    backgroundColor: const Color(0xFF3A3A3C),
                    valueColor: AlwaysStoppedAnimation(
                      allDone
                          ? theme.colorScheme.custom['accentGreen']!
                          : theme.colorScheme.primary,
                    ),
                    minHeight: 3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Model cards
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: models.map((m) {
                      final state =
                          svc.states[m.key] ?? ModelDownloadState.notDownloaded;
                      final progress = svc.progress[m.key] ?? 0.0;
                      final errorMsg = svc.errorMessages[m.key];
                      return _ModelCard(
                        name: m.name,
                        sizeMb: m.sizeMb,
                        state: state,
                        progress: progress,
                        errorMsg: errorMsg,
                        onRetry:
                            state == ModelDownloadState.error
                                ? () => svc.downloadModel(m)
                                : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Bottom bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.custom['sidebarBg']!,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton.ghost(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('后台下载'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String name;
  final double sizeMb;
  final ModelDownloadState state;
  final double progress;
  final String? errorMsg;
  final VoidCallback? onRetry;

  const _ModelCard({
    required this.name,
    required this.sizeMb,
    required this.state,
    required this.progress,
    this.errorMsg,
    this.onRetry,
  });

  String get _stateText {
    switch (state) {
      case ModelDownloadState.notDownloaded:
        return '待下载';
      case ModelDownloadState.downloading:
        return '\${(progress * 100).toInt()}%';
      case ModelDownloadState.processing:
        return '处理中';
      case ModelDownloadState.downloaded:
        return '已完成';
      case ModelDownloadState.error:
        return '失败';
    }
  }

  Color _stateColor(ShadThemeData theme) {
    switch (state) {
      case ModelDownloadState.downloaded:
        return theme.colorScheme.custom['accentGreen']!;
      case ModelDownloadState.downloading:
      case ModelDownloadState.processing:
        return theme.colorScheme.primary;
      case ModelDownloadState.error:
        return theme.colorScheme.destructive;
      default:
        return theme.colorScheme.mutedForeground;
    }
  }

  IconData get _stateIcon {
    switch (state) {
      case ModelDownloadState.downloaded:
        return Icons.check_circle;
      case ModelDownloadState.downloading:
        return Icons.cloud_download;
      case ModelDownloadState.processing:
        return Icons.hourglass_top;
      case ModelDownloadState.error:
        return Icons.error;
      default:
        return Icons.cloud_download_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(_stateIcon, size: 16, color: _stateColor(theme)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\${sizeMb.toStringAsFixed(0)} MB',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _stateText,
            style: TextStyle(
              fontSize: 11,
              color: _stateColor(theme),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            ShadButton.ghost(
              onPressed: onRetry,
              child: Icon(LucideIcons.refreshCw, size: 13),
            ),
          ],
        ],
      ),
    );
  }
}
