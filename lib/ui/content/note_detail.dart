import 'package:flutter/material.dart';
import '../../logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../models/note.dart';
import '../../models/segment.dart';
import '../../providers/notes_provider.dart';

/// 笔记详情面板 — 显示标题、片段列表、导出/删除操作
class NoteDetail extends ConsumerStatefulWidget {
  /// 笔记对象，用于显示标题和更新 DB
  final Note note;

  /// 转写片段列表
  final List<Segment> segments;

  /// 导出 TXT 回调
  final VoidCallback? onExport;

  /// 导出 SRT 回调
  final VoidCallback? onExportSrt;

  /// 导出音频回调

  /// 重新识别回调
  final VoidCallback? onReRecognize;

  /// 删除笔记回调

  /// 点击片段跳到音频对应位置
  final void Function(int startMs)? onSegmentTap;

  const NoteDetail({
    super.key,
    required this.note,
    required this.segments,
    this.onExport,
    this.onExportSrt,
    this.onReRecognize,
    this.onSegmentTap,
  });

  @override
  ConsumerState<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends ConsumerState<NoteDetail> {
  final TextEditingController _titleController = TextEditingController();

  /// 正在编辑的片段 ID
  String? _editingSegmentId;

  /// 文本编辑控制器
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
  }

  @override
  void didUpdateWidget(covariant NoteDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.note.title != _titleController.text) {
      _titleController.text = widget.note.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _editController.dispose();
    super.dispose();
  }

  /// 保存标题到数据库
  Future<void> _saveTitle() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty || newTitle == widget.note.title) return;
    try {
      await ref
          .read(notesRepositoryProvider)
          .update(widget.note.copyWith(title: newTitle));
      ref.invalidate(notesProvider);
    } catch (e) {
      appLog.d('[NoteDetail] 保存标题失败: $e');
    }
  }

  /// 进入片段文本编辑模式
  void _startEditing(Segment segment) {
    appLog.d('[UI] 编辑片段文本: id=${segment.id}');
    _editingSegmentId = segment.id;
    _editController.text = segment.text;
    _editController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: segment.text.length,
    );
    setState(() {});
  }

  /// 完成编辑，保存文本到数据库
  Future<void> _finishEditing() async {
    final segId = _editingSegmentId;
    if (segId == null) return;
    final newText = _editController.text.trim();
    _editingSegmentId = null;
    setState(() {});

    // 找到该 segment 并更新本地 + DB
    final idx = widget.segments.indexWhere((s) => s.id == segId);
    if (idx == -1 || newText == widget.segments[idx].text) return;

    // 通过 provider 更新本地 segment 的 text
    widget.segments[idx].text = newText;

    // 保存到数据库
    try {
      await ref.read(segmentsRepositoryProvider).updateText(segId, newText);
    } catch (e) {
      appLog.d('[NoteDetail] 保存文本失败: $e');
    }
  }

  /// 格式化毫秒为 mm:ss.mmm 时间字符串
  String _fmtMs(int ms) {
    final m = (ms ~/ 60000).toString().padLeft(2, '0');
    final s = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (ms % 1000).toString().padLeft(3, '0');
    return '$m:$s.$millis';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title bar
        Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ShadTheme.of(context).colorScheme.border,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _saveTitle(),
                  onTapOutside: (_) {
                    _saveTitle();
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
              Row(
                children: [
                  _headerButton('导出 TXT', widget.onExport),
                  SizedBox(width: 8),
                  _headerButton('导出 SRT', widget.onExportSrt),

                  SizedBox(width: 8),
                  _headerButton('重新识别', widget.onReRecognize),
                ],
              ),
            ],
          ),
        ),
        // List header
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ShadTheme.of(context).colorScheme.border,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  '开始时间',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(
                      context,
                    ).colorScheme.custom['textTertiary']!,
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: Text(
                  '结束时间',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(
                      context,
                    ).colorScheme.custom['textTertiary']!,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '内容（双击文字编辑）',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ShadTheme.of(
                      context,
                    ).colorScheme.custom['textTertiary']!,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Segment list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.segments.length,
            separatorBuilder: (_, _) => ShadSeparator.horizontal(
              thickness: 1,
              margin: .zero,
              color: ShadTheme.of(context).colorScheme.accent,
            ),
            itemBuilder: (context, i) {
              final seg = widget.segments[i];
              final isEditing = _editingSegmentId == seg.id;
              return GestureDetector(
                onTap: () {
                  if (!isEditing) {
                    appLog.d('[UI] 点击片段: id=${seg.id}, startMs=${seg.startMs}');
                    widget.onSegmentTap?.call(seg.startMs);
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 开始时间
                      SizedBox(
                        width: 72,
                        child: Text(
                          _fmtMs(seg.startMs),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.custom['textTertiary']!,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      // 结束时间
                      SizedBox(
                        width: 72,
                        child: Text(
                          _fmtMs(seg.endMs),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.custom['textTertiary']!,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      // 文本内容（可编辑）
                      Expanded(
                        child: isEditing
                            ? SizedBox(
                                height: 20,
                                child: TextField(
                                  controller: _editController,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: ShadTheme.of(
                                      context,
                                    ).colorScheme.foreground,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 4,
                                    ),
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _finishEditing(),
                                  onTapOutside: (_) => _finishEditing(),
                                ),
                              )
                            : GestureDetector(
                                onDoubleTap: () => _startEditing(seg),
                                child: SizedBox(
                                  height: 20,
                                  child: Text(
                                    seg.text,
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: ShadTheme.of(
                                        context,
                                      ).colorScheme.foreground,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerButton(String text, VoidCallback? onTap) {
    return ShadButton.outline(
      onPressed: onTap,
      child: Text(text, style: TextStyle(fontSize: 11)),
    );
  }
}
