import 'dart:io';
import '../logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 音频文件存储管理服务
///
/// 统一管理沙盒内 `audio/` 目录下的音频文件。
/// 目录结构：`<app_support_dir>/audio/<noteId>.wav`
/// 音频文件存储管理服务 — 统一管理沙盒 audio/ 目录
class AudioStorageService {
  AudioStorageService._();

  static const String _audioDirName = 'audios';

  /// 获取应用沙盒根路径
  /// 获取应用沙盒根路径
  static Future<String> getSandboxPath() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  /// 获取音频存储目录路径（不存在则创建）
  /// 获取音频存储目录路径（不存在则创建）
  static Future<String> ensureAudioDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, _audioDirName, 'asr_src'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// 获取音频存储目录路径（不创建，只返回路径）
  /// 获取音频存储目录路径（不创建，只返回路径）
  static Future<String> getAudioDirPath() async {
    final appDir = await getApplicationSupportDirectory();
    return p.join(appDir.path, _audioDirName);
  }

  /// 笔记音频文件名
  static String _filename(String noteId) => 'asr_$noteId.wav';

  /// 笔记对应的音频文件完整路径
  static Future<String> audioPathFor(String noteId) async {
    final audioDir = await ensureAudioDir();
    return p.join(audioDir, _filename(noteId));
  }

  /// 保存导入的 WAV 文件到沙盒永久目录，返回永久路径
  /// 保存导入的 WAV 文件到沙盒永久目录，返回永久路径
  static Future<String> saveImportedAudio({
    required String noteId,
    required String wavFilePath,
  }) async {
    final audioDir = await ensureAudioDir();
    final destPath = p.join(audioDir, _filename(noteId));
    appLog.d('[AudioStorage] 复制: $wavFilePath → $destPath');
    final srcFile = File(wavFilePath);
    if (!await srcFile.exists()) {
      throw Exception('源文件不存在: $wavFilePath');
    }
    await File(wavFilePath).copy(destPath);
    if (!await File(destPath).exists()) {
      throw Exception('复制失败，目标文件未创建: $destPath');
    }
    appLog.d('[AudioStorage] 复制成功: $destPath');
    return destPath;
  }

  /// 检查笔记对应的音频文件是否存在
  /// 检查笔记对应的音频文件是否存在
  static Future<bool> audioExists(String noteId) async {
    final path = await audioPathFor(noteId);
    return File(path).exists();
  }

  /// 删除笔记对应的音频文件
  /// 删除笔记对应的音频文件
  static Future<void> deleteAudio(String noteId) async {
    final path = await audioPathFor(noteId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 获取音频目录总大小（字节）
  /// 获取音频目录总大小（字节）
  static Future<int> getAudioDirSize() async {
    try {
      final audioDir = await getAudioDirPath();
      final dir = Directory(audioDir);
      if (!await dir.exists()) return 0;
      int total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// TTS 音频存储目录（audios/tts_gen/）
  static Future<String> ensureTtsAudioDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(appDir.path, _audioDirName, 'tts_gen'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// TTS 音频文件完整路径
  static Future<String> ttsAudioPathFor(String recordId) async {
    final ttsDir = await ensureTtsAudioDir();
    return p.join(ttsDir, 'tts_$recordId.wav');
  }
}
