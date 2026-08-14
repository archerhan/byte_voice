import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'note_list_item.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../database/repositories/tts_history_repository.dart';
import '../../providers/tts_provider.dart';
import '../../services/audio_playback_service.dart';

/// TTS 模式下的侧边栏：历史合成记录列表
class TtsSidebarPanel extends ConsumerWidget {
  const TtsSidebarPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ttsHistoryListProvider);
    final selectedId = ref.watch(selectedTtsHistoryIdProvider);

    // 自动选中第一条历史记录
    ref.listen(ttsHistoryListProvider, (_, next) {
      next.whenData((records) {
        if (records.isNotEmpty &&
            ref.read(selectedTtsHistoryIdProvider) == null) {
          ref.read(selectedTtsHistoryIdProvider.notifier).set(
records.first.id);
        }
      });
    });

    return Column(
      children: [
        Expanded(
          child: historyAsync.when(
            data: (records) => records.isEmpty
                ? Center(
                    child: Text(
                      '暂无合成记录',
                      style: TextStyle(
                        color: ShadTheme.of(
                          context,
                        ).colorScheme.custom['textTertiary']!,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: records.length,
                    buildDefaultDragHandles: false,
                    onReorderItem: (oldIndex, newIndex) {
                      final items = List<TtsHistoryRecord>.from(records);
                      final entry = items.removeAt(oldIndex);
                      items.insert(newIndex, entry);
                      final positionEntries = items
                          .asMap()
                          .entries
                          .map(
                            (e) => MapEntry(e.value.id, items.length - e.key),
                          )
                          .toList();
                      ref
                          .read(ttsHistoryRepositoryProvider)
                          .updatePositions(positionEntries);
                      ref.invalidate(ttsHistoryListProvider);
                    },
                    itemBuilder: (_, i) => ReorderableDragStartListener(
                      index: i,
                      key: ValueKey(records[i].id),
                      child: NoteListItem(
                        icon: LucideIcons.volume2,
                        accentColor: ShadTheme.of(
                          context,
                        ).colorScheme.custom['accentGreen']!,
                        title: records[i].text.length > 40
                            ? '${records[i].text.substring(0, 40)}...'
                            : records[i].text,
                        subtitle: _fmtDate(records[i].createdAt),
                        isActive: records[i].id == selectedId,
                        badgeText:
                            records[i].audioFilePath != null &&
                                File(records[i].audioFilePath!).existsSync()
                            ? '已完成'
                            : '失败',
                        badgeColor:
                            records[i].audioFilePath != null &&
                                File(records[i].audioFilePath!).existsSync()
                            ? ShadTheme.of(
                                context,
                              ).colorScheme.custom['accentGreen']!
                            : ShadTheme.of(context).colorScheme.destructive,
                        onTap: () {
                          ref
                                  .read(selectedTtsHistoryIdProvider.notifier).set(records[i].id);
                          if (records[i].audioFilePath != null &&
                              File(records[i].audioFilePath!).existsSync()) {
                            ref.read(ttsOutputFilePathProvider.notifier).set(
records[i].audioFilePath);
                          }
                        },
                        onDelete: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) => ShadDialog.alert(
                              constraints: const BoxConstraints(maxWidth: 400),
                              title: const Text('删除记录'),
                              description: const Text(
                                '确认删除此条合成记录？\n对应的音频文件也将被删除。',
                              ),
                              actions: [
                                ShadButton.outline(
                                  child: const Text('取消'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                ShadButton(
                                  backgroundColor: ShadTheme.of(
                                    context,
                                  ).colorScheme.destructive,
                                  child: const Text('删除'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          ).then((confirmed) {
                            if (confirmed != true) return;
                            ref.read(audioPlaybackControllerProvider.notifier).stop();
                            if (records[i].audioFilePath != null) {
                              final file = File(records[i].audioFilePath!);
                              if (file.existsSync()) {
                                file.deleteSync();
                              }
                            }
                            ref
                                .read(ttsHistoryRepositoryProvider)
                                .delete(records[i].id);
                            ref.invalidate(ttsHistoryListProvider);
                            if (selectedId == records[i].id) {
                              ref
                                      .read(
    selectedTtsHistoryIdProvider.notifier,
  ).set(null);
                              ref
                                      .read(ttsOutputFilePathProvider.notifier).set(null);
                            }
                          });
                        },
                      ),
                    ),
                  ),
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '加载中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: ShadTheme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: TextStyle(
                  color: ShadTheme.of(context).colorScheme.destructive,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ShadButton(
              leading: Icon(LucideIcons.plus),
              backgroundColor: ShadTheme.of(
                context,
              ).colorScheme.custom["accentGreen"],
              hoverBackgroundColor: ShadTheme.of(
                context,
              ).colorScheme.custom["accentGreen"]!.withValues(alpha: 0.8),
              child: Text('新建合成任务', style: TextStyle(fontSize: 12)),
              onPressed: () {
                ref.read(selectedTtsHistoryIdProvider.notifier).set(null);
                ref.read(ttsOutputFilePathProvider.notifier).set(null);
                ref.read(ttsSelectedVoiceIdProvider.notifier).set(0);
                ref.read(ttsSpeedProvider.notifier).set(1.0);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (sameDay) return '今天 $time';
    return '${dt.month}月${dt.day}日 $time';
  }
}
