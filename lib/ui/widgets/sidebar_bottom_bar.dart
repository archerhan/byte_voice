import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/settings_provider.dart';
import '../../services/model_download_service.dart';
import 'model_status_badge.dart';

/// 侧边栏底部栏：模型状态徽章 + 下载进度条 + 旋转设置按钮
class SidebarBottomBar extends ConsumerStatefulWidget {
  const SidebarBottomBar({super.key});

  @override
  ConsumerState<SidebarBottomBar> createState() => _SidebarBottomBarState();
}

class _SidebarBottomBarState extends ConsumerState<SidebarBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(modelDownloadServiceProvider);
    final states = svc.states;
    final models = svc.models;

    double totalSize = 0;
    double completedSize = 0;
    bool anyDownloading = false;
    bool anyProcessing = false;

    for (final m in models) {
      final s = states[m.key] ?? ModelDownloadState.notDownloaded;
      final p = svc.progress[m.key] ?? 0.0;
      totalSize += m.sizeMb;
      if (s == ModelDownloadState.downloaded) {
        completedSize += m.sizeMb;
      } else if (s == ModelDownloadState.downloading) {
        completedSize += m.sizeMb * p;
        anyDownloading = true;
      } else if (s == ModelDownloadState.processing) {
        completedSize += m.sizeMb;
        anyProcessing = true;
      }
    }

    final overallProgress =
        totalSize > 0 ? (completedSize / totalSize).clamp(0.0, 1.0) : 0.0;
    final isActive = anyDownloading || anyProcessing;
    final isComplete = overallProgress >= 1.0 && models.isNotEmpty;

    if (isActive && !_rotateCtrl.isAnimating) {
      _rotateCtrl.repeat();
    } else if (!isActive && _rotateCtrl.isAnimating) {
      _rotateCtrl.stop();
      _rotateCtrl.reset();
    }

    final theme = ShadTheme.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.custom["toolbarBg"]!,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const ModelStatusBadge(),
            if (!isComplete && models.isNotEmpty) ...[
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    backgroundColor: const Color(0xFF3A3A3C),
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white.withValues(alpha: 0.4),
                    ),
                    minHeight: 3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(overallProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.mutedForeground,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const Spacer(),
            AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateCtrl.value * 2 * 3.14159,
                  child: child,
                );
              },
              child: Icon(
                LucideIcons.cog,
                size: 18,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
