/// 导出服务 — 将笔记转写成 TXT / Markdown / SRT 格式
library;

import 'dart:io';
import '../models/note.dart';
import '../models/segment.dart';

/// 导出格式
enum ExportFormat { txt, md, srt }

class ExportService {
  /// 生成文本内容
  String export(Note note, List<Segment> segments, ExportFormat format) {
    switch (format) {
      case ExportFormat.txt:
        return _exportTxt(segments);
      case ExportFormat.md:
        return _exportMd(note, segments);
      case ExportFormat.srt:
        return _exportSrt(segments);
    }
  }

  /// 写入文件
  Future<void> exportToFile(
    Note note,
    List<Segment> segments,
    ExportFormat format,
    String path,
  ) async {
    final content = export(note, segments, format);
    await File(path).writeAsString(content);
  }

  String _exportTxt(List<Segment> segments) {
    return segments.map((s) => s.text).join('\n');
  }

  String _exportMd(Note note, List<Segment> segments) {
    final buf = StringBuffer();
    buf.writeln('# ${note.title}');
    buf.writeln();
    for (final s in segments) {
      buf.writeln('**[${_fmt(s.startMs)}]** ${s.text}');
      buf.writeln();
    }
    return buf.toString();
  }

  String _exportSrt(List<Segment> segments) {
    final buf = StringBuffer();
    var i = 1;
    for (final s in segments) {
      buf.writeln(i++);
      buf.writeln('${_srtTime(s.startMs)} --> ${_srtTime(s.endMs)}');
      buf.writeln(s.text);
      buf.writeln();
    }
    return buf.toString();
  }

  String _fmt(int ms) {
    final m = (ms ~/ 60000).toString().padLeft(2, '0');
    final s = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _srtTime(int ms) {
    final h = (ms ~/ 3600000).toString().padLeft(2, '0');
    final m = ((ms % 3600000) ~/ 60000).toString().padLeft(2, '0');
    final s = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final millis = (ms % 1000).toString().padLeft(3, '0');
    return '$h:$m:$s,$millis';
  }
}
