import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// 侧边栏笔记列表项 — 支持点击、悬停删除、处理进度条
class NoteListItem extends StatefulWidget {
  /// 左侧图标
  final IconData icon;

  /// 图标颜色，默认使用 badgeColor
  final Color? iconColor;

  /// 选中时的强调色（左边框、图标背景），默认 accentBlue
  final Color? accentColor;

  final String title;
  final String subtitle;
  final bool isActive;
  final String badgeText;
  final Color badgeColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  /// 0.0~1.0 处理进度，设置后替代 badge 显示百分比 + 进度条
  final double? progress;

  const NoteListItem({
    super.key,
    this.icon = Icons.mic,
    this.iconColor,
    this.accentColor,
    required this.title,
    required this.subtitle,
    this.isActive = false,
    required this.badgeText,
    required this.badgeColor,
    this.onTap,
    this.onDelete,
    this.progress,
  });

  @override
  State<NoteListItem> createState() => _NoteListItemState();
}

class _NoteListItemState extends State<NoteListItem> {
  /// 鼠标是否悬停
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? ShadTheme.of(context).colorScheme.custom['navActiveBg']!
                  : null,
              border: Border(
                left: BorderSide(
                  color: widget.isActive
                      ? (widget.accentColor ??
                            ShadTheme.of(context).colorScheme.primary)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // 图标
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? widget.badgeColor)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 14,
                        color: widget.iconColor ?? widget.badgeColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    // 标题 + 时间
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ShadTheme.of(
                                context,
                              ).colorScheme.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: ShadTheme.of(
                                context,
                              ).colorScheme.custom['textTertiary']!,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    // 悬停时显示 × 删除 / 处理中显示进度 / 否则显示状态徽章
                    if (_isHovered && widget.onDelete != null)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 14,
                          icon: Icon(
                            Icons.close,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.custom['textTertiary']!,
                          ),
                          onPressed: widget.onDelete,
                        ),
                      )
                    else if (widget.progress != null)
                      Text(
                        '${(widget.progress! * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: ShadTheme.of(
                            context,
                          ).colorScheme.custom['accentGreen']!,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: widget.badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.badgeColor,
                          ),
                        ),
                      ),
                  ],
                ),
                // 处理进度条
                if (widget.progress != null)
                  Padding(
                    padding: EdgeInsets.only(left: 38, top: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        minHeight: 3,
                        backgroundColor: Color(0xFF3A3A3C),
                        valueColor: AlwaysStoppedAnimation(Color(0xFF30D158)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
