import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/transcription_provider.dart';
import '../../services/engine_service.dart';

/// 实时转写流显示组件 — 录音过程中实时显示转写结果
class TranscriptStream extends ConsumerStatefulWidget {
  const TranscriptStream({super.key});

  @override
  ConsumerState<TranscriptStream> createState() => _TranscriptStreamState();
}

class _TranscriptStreamState extends ConsumerState<TranscriptStream> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _fmtMs(int ms) {
    final m = (ms ~/ 60000).toString().padLeft(2, '0');
    final s = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final liveAsync = ref.watch(liveTranscriptProvider);

    return liveAsync.when(
      data: (segments) {
        final durAsync = ref.watch(recordingDurationProvider);
        final durationMs = durAsync.asData?.value ?? 0;
        final remainingMs = (30 * 60 * 1000) - durationMs;
        final remainingSec = remainingMs ~/ 1000;
        final showWarning = remainingSec < 60 && remainingSec > 0;

        if (segments.isEmpty) {
          return Column(
            children: [
              _buildDurationBar(durationMs, showWarning),
              Expanded(
                child: Center(
                  child: Text(
                    '等待语音输入…',
                    style: TextStyle(
                      fontSize: 14,
                      color: ShadTheme.of(
                        context,
                      ).colorScheme.custom['textTertiary']!,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildDurationBar(durationMs, showWarning),
            Expanded(child: _buildTranscriptList(segments)),
          ],
        );
      },
      loading: () => Center(
        child: Text(
          '准备录音…',
          style: TextStyle(
            fontSize: 14,
            color: ShadTheme.of(context).colorScheme.custom['textTertiary']!,
          ),
        ),
      ),
      error: (e, _) => Center(
        child: Text(
          '转写异常: $e',
          style: TextStyle(
            fontSize: 14,
            color: ShadTheme.of(context).colorScheme.destructive,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationBar(int durationMs, bool showWarning) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        '录音 ${_fmtMs(durationMs)} / 30:00${showWarning ? " — 即将结束" : ""}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: showWarning ? FontWeight.w600 : FontWeight.w400,
          color: showWarning
              ? ShadTheme.of(context).colorScheme.destructive
              : ShadTheme.of(context).colorScheme.custom['textTertiary']!,
        ),
      ),
    );
  }

  Widget _buildTranscriptList(List<TranscribedSegment> segments) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(20),
      itemCount: segments.length,
      itemBuilder: (context, i) {
        final seg = segments[i];
        final isLast = i == segments.length - 1;
        return _line(seg, isLast: isLast);
      },
    );
  }

  Widget _line(TranscribedSegment seg, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              _fmtMs(seg.startMs),
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: ShadTheme.of(
                  context,
                ).colorScheme.custom['textTertiary']!,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    seg.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: ShadTheme.of(context).colorScheme.foreground,
                    ),
                  ),
                ),
                if (isLast)
                  Container(
                    width: 2,
                    height: 18,
                    color: ShadTheme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
