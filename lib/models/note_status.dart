/// 笔记状态枚举 — 定义笔记在转写流程中的生命周期阶段
enum NoteStatus {
  /// 转写中 — 录音完成或文件导入后，正在通过引擎处理音频
  transcribing,

  /// 已完成 — 转写结束，可查看/编辑/导出结果
  completed,

  /// 失败 — 转写过程中发生异常（模型缺失、ffmpeg 解码失败等）
  failed,
}

/// 笔记来源枚举 — 标识笔记的音频数据从何处获得
enum NoteSource {
  /// 录音 — 通过应用内麦克风录制
  recording,

  /// 导入 — 从文件选择器或拖放导入的音频文件
  import,
}
