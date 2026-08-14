import 'note_status.dart';

/// 笔记数据模型 — 对应数据库 notes_table 的一条记录
/// 包含元信息（标题/时间/时长）、音频文件路径、转写状态和进度
class Note {
  /// 笔记唯一标识（UUID）
  final String id;

  /// 笔记标题（由源文件名自动生成，用户可二次修改）
  String title;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间（每次 copyWith 或状态变更时更新）
  DateTime updatedAt;

  /// 音频总时长（毫秒）
  final int durationMs;

  /// 永久音频文件存储路径，指向沙盒 audio/ 目录下的 WAV 文件
  final String? audioFilePath;

  /// 是否保留音频文件（删除笔记时根据此值决定是否清理磁盘文件）
  final bool keepAudio;

  /// 笔记来源（录音 / 导入）
  final NoteSource source;

  /// 当前转写状态（转写中 / 已完成 / 失败）
  NoteStatus status;

  /// 转写进度（0.0~1.0），仅在 status==transcribing 时有意义
  double? currentProgress;
  final int position;

  /// 构造一条笔记记录
  Note({
    required this.id,
    this.title = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.durationMs = 0,
    this.audioFilePath,
    this.keepAudio = false,
    this.source = NoteSource.recording,
    this.status = NoteStatus.transcribing,
    this.currentProgress,
    this.position = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 创建一个更新了部分字段的新笔记副本（不可变风格）
  Note copyWith({
    String? title,
    NoteStatus? status,
    double? currentProgress,
    DateTime? updatedAt,
    int? position,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      durationMs: durationMs,
      audioFilePath: audioFilePath,
      keepAudio: keepAudio,
      source: source,
      status: status ?? this.status,
      currentProgress: currentProgress ?? this.currentProgress,
      position: position ?? this.position,
    );
  }
}
