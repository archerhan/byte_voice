/// 转写片段模型 — 对应数据库 segments_table 的一条记录
/// 每个片段包含起止时间戳、识别文本和置信度
class Segment {
  /// 片段唯一标识（UUID）
  final String id;

  /// 所属笔记的 ID
  final String noteId;

  /// 该片段在原始音频中的起始毫秒位置
  final int startMs;

  /// 该片段在原始音频中的结束毫秒位置
  final int endMs;

  /// 识别文本内容（用户可在 UI 中二次编辑）
  String text;

  /// ASR 置信度分数（0.0~1.0），来自 sherpa_onnx 引擎；可能为 null
  final double? confidence;

  /// 在笔记内部的排序序号，用于恢复正确的片段顺序
  final int sortIndex;

  Segment({
    required this.id,
    required this.noteId,
    required this.startMs,
    required this.endMs,
    this.text = '',
    this.confidence,
    required this.sortIndex,
  });

  Segment copyWith({String? text}) {
    return Segment(
      id: id,
      noteId: noteId,
      startMs: startMs,
      endMs: endMs,
      text: text ?? this.text,
      confidence: confidence,
      sortIndex: sortIndex,
    );
  }
}
