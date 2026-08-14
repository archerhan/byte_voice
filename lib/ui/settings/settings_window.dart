import 'dart:async';
import 'dart:convert';
import '../../logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:path/path.dart' as p;
import '../../services/audio_storage_service.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transcription_provider.dart';
import '../../services/model_download_service.dart';

/// 设置窗口
/// 设置窗口 — 模型下载、存储信息、音频参数配置
class SettingsWindow extends StatefulWidget {
  final int initialTab;
  final bool autoDownload;
  const SettingsWindow({super.key, this.initialTab = 0, this.autoDownload = false})
    : assert(initialTab >= 0 && initialTab <= 1);

  @override
  State<SettingsWindow> createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  /// 当前选中的导航索引
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    if (widget.autoDownload && widget.initialTab == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final svc = ProviderScope.containerOf(context).read(modelDownloadServiceProvider);
        if (!svc.isDownloading) {
          svc.downloadModels();
        }
      });
    }
  }

  final _navItems = [
    // ('音频处理', Icons.headset),
    ('主题设置', LucideIcons.palette),
    ('语音模型', LucideIcons.package),
    // ('存储', Icons.storage),
    // ('导出', Icons.file_download),
    // ('数据', Icons.dns),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 680,
          height: 520,
          child: Row(
            children: [
              SizedBox(
                width: 180,
                child: Container(
                  color: ShadTheme.of(context).colorScheme.custom['sidebarBg']!,
                  child: Column(
                    children: [
                      SizedBox(height: 8),
                      ..._navItems.asMap().entries.map(
                        (e) => _navItem(
                          e.value.$1,
                          e.value.$2,
                          e.key == _selectedIndex,
                          () {
                            setState(() => _selectedIndex = e.key);
                          },
                        ),
                      ),
                      Spacer(),
                      _navItem(
                        '关于',
                        Icons.info_outline,
                        false,
                        () => _showAboutDialog(context),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: ShadTheme.of(context).colorScheme.background,
                  padding: EdgeInsets.all(24),
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    String label,
    IconData icon,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? ShadTheme.of(context).colorScheme.custom['navActiveBg']!
              : null,
          border: Border(
            left: BorderSide(
              color: active
                  ? ShadTheme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: active
                  ? ShadTheme.of(context).colorScheme.foreground
                  : ShadTheme.of(context).colorScheme.mutedForeground,
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: active
                    ? ShadTheme.of(context).colorScheme.foreground
                    : ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_selectedIndex == 0) {
      return _ThemeTab();
    }
    return const _ModelDownloadTab();
    // switch (_selectedIndex) {
    //   case 0:
    //     return _audioSettings();
    //   case 1:
    //     return const _ModelDownloadTab();
    //   case 2:
    //     return const _StorageTab();
    //   default:
    //     return Center(
    //       child: Text(
    //         _navItems[_selectedIndex].$1,
    //         style: TextStyle(color: ShadTheme.of(context).colorScheme.mutedForeground),
    //       ),
    //     );
    // }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const _AboutDialog());
  }
}

/// 存储信息标签页
class _StorageTab extends StatefulWidget {
  const _StorageTab();

  @override
  State<_StorageTab> createState() => _StorageTabState();
}

class _StorageTabState extends State<_StorageTab> {
  /// 沙盒路径显示文本
  String _sandboxPath = '加载中...';

  /// 音频目录大小文本
  String _sizeText = '';

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final path = await AudioStorageService.getSandboxPath();
      final totalBytes = await AudioStorageService.getAudioDirSize();
      final sizeMb = totalBytes > 0
          ? '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
          : '无';
      if (mounted) {
        setState(() {
          _sandboxPath = path;
          _sizeText = sizeMb;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sandboxPath = '获取失败');
    }
  }

  Future<void> _openInFileManager() async {
    final audioDirPath = await AudioStorageService.ensureAudioDir();
    appLog.d('[UI] 在文件管理器中打开: $audioDirPath');
    await Process.run(
      Platform.isWindows
          ? 'explorer'
          : Platform.isMacOS
          ? 'open'
          : 'xdg-open',
      [audioDirPath],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          '存储位置',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ShadTheme.of(context).colorScheme.foreground,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color(0xFF1C2027),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '沙盒路径',
                style: TextStyle(
                  fontSize: 12,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
              SizedBox(height: 6),
              SelectableText(
                _sandboxPath,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _openInFileManager,
                  icon: Icon(Icons.folder_open, size: 14),
                  label: Text('在文件管理器中打开'),
                  style: TextButton.styleFrom(
                    foregroundColor: ShadTheme.of(
                      context,
                    ).colorScheme.foreground,
                    backgroundColor: ShadTheme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color(0xFF1C2027),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '音频文件占用',
                style: TextStyle(
                  fontSize: 13,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              Text(
                _sizeText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 语音模型下载标签页
class _ModelDownloadTab extends ConsumerStatefulWidget {
  const _ModelDownloadTab();

  @override
  ConsumerState<_ModelDownloadTab> createState() => _ModelDownloadTabState();
}

class _ModelDownloadTabState extends ConsumerState<_ModelDownloadTab> {
  StreamSubscription? _stateSub;
  StreamSubscription? _progressSub;
  StreamSubscription? _errorSub;

  /// 是否正在检查完整性
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = ref.read(modelDownloadServiceProvider);
      // 订阅流，监听从设置操作触发的状态变更
      _stateSub = svc.statesStream.listen((_) {
        // 检查是否所有模型都下载完成 → 刷新引擎
        final states = svc.states;
        final allDone = svc.models.every(
          (m) => states[m.key] == ModelDownloadState.downloaded,
        );
        if (allDone) {
          ref.read(modelRefreshProvider.notifier).increment();
        }
        if (mounted) setState(() {});
      });
      _progressSub = svc.progressStream.listen((_) {
        if (mounted) setState(() {});
      });
      _errorSub = svc.errorStream.listen((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _progressSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(modelDownloadServiceProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '语音模型',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isChecking)
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ShadTheme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  // _smallButton(
                  //   Icons.refresh,
                  //   '检查完整性',
                  //   _isChecking ? null : _runIntegrityCheck,
                  // ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          if (service.isManifestLoaded)
            ...service.models.map((m) => _buildCard(service, m))
          else
            Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  '获取模型列表中...',
                  style: TextStyle(
                    fontSize: 13,
                    color: ShadTheme.of(
                      context,
                    ).colorScheme.custom['textTertiary']!,
                  ),
                ),
              ),
            ),
          Center(child: _buildActionButton(service)),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCard(ModelDownloadService svc, ManifestModel model) {
    final state = svc.states[model.key] ?? ModelDownloadState.notDownloaded;
    final progress = svc.progress[model.key] ?? 0.0;
    final errorMsg = svc.errorMessages[model.key];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_stateIcon(state), size: 18, color: _stateColor(state)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  model.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                ),
              ),
              _stateLabel(state),
              if (state == ModelDownloadState.downloaded ||
                  state == ModelDownloadState.error) ...[
                SizedBox(width: 6),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: TextButton(
                    onPressed: () async {
                      final svc = ref.read(modelDownloadServiceProvider);
                      await svc.downloadModel(model);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: ShadTheme.of(
                        context,
                      ).colorScheme.mutedForeground,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Icon(LucideIcons.refreshCw, size: 13),
                  ),
                ),
              ],
            ],
          ),
          if (state == ModelDownloadState.downloading) ...[
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: Color(0xFF3A3A3C),
                valueColor: AlwaysStoppedAnimation(
                  ShadTheme.of(context).colorScheme.primary,
                ),
                minHeight: 5,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                color: ShadTheme.of(
                  context,
                ).colorScheme.custom['textTertiary']!,
              ),
            ),
          ],
          // 显示错误信息
          if (state == ModelDownloadState.error && errorMsg != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ShadTheme.of(
                  context,
                ).colorScheme.destructive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 14,
                    color: ShadTheme.of(context).colorScheme.destructive,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMsg,
                      style: TextStyle(
                        fontSize: 11,
                        color: ShadTheme.of(context).colorScheme.destructive,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons: open location + delete
            if (state == ModelDownloadState.downloaded ||
                state == ModelDownloadState.error) ...[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state == ModelDownloadState.downloaded)
                    _actionButton(
                      Icons.folder_open,
                      '打开位置',
                      () => _openModelLocation(model),
                      color: ShadTheme.of(context).colorScheme.foreground,
                    ),
                  if (state == ModelDownloadState.downloaded ||
                      state == ModelDownloadState.error) ...[
                    SizedBox(width: 8),
                    _actionButton(
                      Icons.delete_outline,
                      '删除重新下载',
                      () => _confirmAndDeleteModel(model),
                      color: ShadTheme.of(context).colorScheme.destructive,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _openModelLocation(ManifestModel model) async {
    final svc = ref.read(modelDownloadServiceProvider);
    final path = svc.modelsPath;
    if (path == null) return;
    final target = p.join(path, model.key);
    appLog.d('[UI] 打开模型位置: $target');
    await Process.run(
      Platform.isWindows
          ? 'explorer'
          : Platform.isMacOS
          ? 'open'
          : 'xdg-open',
      [target],
    );
  }

  Future<void> _confirmAndDeleteModel(ManifestModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog.alert(
        title: Text('删除模型'),
        description: Text('确认删除「${model.name}」？\n删除后可以重新下载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(modelDownloadServiceProvider).deleteModel(model);
      if (mounted) setState(() {});
    }
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return SizedBox(
      height: 28,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 13),
        label: Text(label, style: TextStyle(fontSize: 11)),
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor:
              (color ?? ShadTheme.of(context).colorScheme.foreground)
                  .withValues(alpha: 0.1),
          padding: EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Future<void> _runIntegrityCheck() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final svc = ref.read(modelDownloadServiceProvider);

      if (svc.modelsPath == null || svc.manifest == null) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('模型列表尚未加载，请稍后再试。')));
        return;
      }

      final path = svc.modelsPath!;
      final manifestJson = jsonEncode(svc.manifest!.toJson());

      // 在后台 Isolate 中检查模型文件，避免卡 UI
      final result = await compute(_performIntegrityCheck, [
        path,
        manifestJson,
      ]);
      svc.updateStatesFromCheck(result);

      // 用底部长条 SnackBar 展示结果，不阻塞 UI
      final missingKeys = result.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .toList();
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            description: Text(
              missingKeys.isEmpty
                  ? '所有模型文件完整 ✓'
                  : '以下模型缺失，将自动下载：${missingKeys.join("、")}',
            ),
          ),
        );
      }

      // 自动下载缺失的模型
      if (missingKeys.isNotEmpty) {
        svc.downloadModels();
      }
    } catch (e) {
      appLog.e('[UI] 完整性检查失败: $e');
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast.destructive(description: Text('完整性检查出错：$e')));
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Widget _smallButton(IconData icon, String label, VoidCallback? onPressed) {
    return SizedBox(
      height: 26,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12),
        label: Text(label, style: TextStyle(fontSize: 11)),
        style: TextButton.styleFrom(
          foregroundColor: ShadTheme.of(context).colorScheme.mutedForeground,
          backgroundColor: ShadTheme.of(
            context,
          ).colorScheme.custom['sidebarBg']!,
          padding: EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _stateLabel(ModelDownloadState s) {
    final map = {
      ModelDownloadState.notDownloaded: '未下载',
      ModelDownloadState.downloading: '下载中',
      ModelDownloadState.processing: '处理中',
      ModelDownloadState.downloaded: '已就绪',
      ModelDownloadState.error: '失败',
    };
    return Text(map[s]!, style: TextStyle(fontSize: 11, color: _stateColor(s)));
  }

  Color _stateColor(ModelDownloadState s) {
    switch (s) {
      case ModelDownloadState.downloaded:
        return ShadTheme.of(context).colorScheme.custom['accentGreen']!;
      case ModelDownloadState.downloading:
        return ShadTheme.of(context).colorScheme.primary;
      case ModelDownloadState.processing:
        return ShadTheme.of(context).colorScheme.primary;
      case ModelDownloadState.error:
        return ShadTheme.of(context).colorScheme.destructive;
      default:
        return ShadTheme.of(context).colorScheme.custom['textTertiary']!;
    }
  }

  IconData _stateIcon(ModelDownloadState s) {
    switch (s) {
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

  Widget _buildActionButton(ModelDownloadService svc) {
    if (!svc.isManifestLoaded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: ShadTheme.of(context).colorScheme.custom['textTertiary']!,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '正在获取模型列表...',
            style: TextStyle(
              fontSize: 12,
              color: ShadTheme.of(context).colorScheme.custom['textTertiary']!,
            ),
          ),
        ],
      );
    }

    final allDownloaded = svc.models.every(
      (m) => svc.states[m.key] == ModelDownloadState.downloaded,
    );
    final anyDownloading = svc.states.values.any(
      (s) => s == ModelDownloadState.downloading,
    );

    if (allDownloaded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: ShadTheme.of(context).colorScheme.custom['accentGreen']!,
          ),
          SizedBox(width: 6),
          Text(
            '所有模型已就绪',
            style: TextStyle(
              fontSize: 12,
              color: ShadTheme.of(context).colorScheme.custom['accentGreen']!,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 200,
      child: TextButton.icon(
        onPressed: anyDownloading
            ? null
            : () {
                appLog.i('[UI] 开始下载全部模型');
                svc.downloadModels();
              },
        icon: Icon(
          anyDownloading ? Icons.hourglass_top : Icons.download,
          size: 16,
        ),
        label: Text(
          anyDownloading ? '正在下载...' : '下载全部模型',
          style: TextStyle(fontSize: 13),
        ),
        style: TextButton.styleFrom(
          foregroundColor: ShadTheme.of(context).colorScheme.foreground,
          backgroundColor: ShadTheme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.15),
          padding: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

/// 主题设置标签页
class _ThemeTab extends ConsumerWidget {
  const _ThemeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主题设置',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ShadTheme.of(context).colorScheme.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '外观模式',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ShadRadioGroup<ThemeMode>(
                      initialValue: themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(value);
                        }
                      },
                      spacing: 8,
                      items: const [
                        ShadRadio<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text("浅色模式"),
                        ),
                        ShadRadio<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('深色模式'),
                        ),
                        ShadRadio<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('跟随系统'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 关于对话框
class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: ShadCard(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        columnMainAxisSize: .min,
        columnCrossAxisAlignment: .center,
        columnMainAxisAlignment: .center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                LucideIcons.waves,
                size: 36,
                color: theme.colorScheme.primaryForeground,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'ByteVoice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.foreground,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '版本 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '离线语音转文字笔记工具',
                    textAlign: .center,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '© 2026 ByteVoice',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, bool> _performIntegrityCheck(List<String> args) {
  final modelsDir = args[0];
  final manifestJson = args[1];

  final m = jsonDecode(manifestJson) as Map<String, dynamic>;
  final modelsMap = m['models'] as Map<String, dynamic>;
  final results = <String, bool>{};

  for (final key in modelsMap.keys) {
    final entry = modelsMap[key] as Map<String, dynamic>;
    final files = (entry['files'] as Map<String, dynamic>).values
        .cast<String>();
    final modelDir = p.join(modelsDir, key);

    if (!Directory(modelDir).existsSync()) {
      results[key] = false;
      continue;
    }

    bool allExist = true;
    for (final filename in files) {
      if (!File(p.join(modelDir, filename)).existsSync()) {
        allExist = false;
        break;
      }
    }
    results[key] = allExist;
  }

  return results;
}
