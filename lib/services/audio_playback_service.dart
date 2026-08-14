import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../logger.dart';

part 'audio_playback_service.g.dart';

/// 音频播放状态模型
class AudioPlaybackState {
  /// 是否正在播放
  final bool isPlaying;

  /// 当前播放位置
  final Duration position;

  /// 音频总时长
  final Duration duration;

  /// 当前加载的音频文件路径
  final String? filePath;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息（加载或播放失败时）
  final String? errorMessage;

  const AudioPlaybackState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.filePath,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 播放进度比例，0.0~1.0
  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  /// 是否已加载音频且就绪
  bool get hasAudio => filePath != null && !isLoading && errorMessage == null;
}

/// 音频播放控制器 — 使用 @riverpod Notifier 模式替代 ChangeNotifier
@riverpod
class AudioPlaybackController extends _$AudioPlaybackController {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;

  @override
  AudioPlaybackState build() {
    _positionSub = _player.onPositionChanged.listen((pos) {
      state = AudioPlaybackState(
        isPlaying: state.isPlaying,
        position: pos,
        duration: state.duration,
        filePath: state.filePath,
        isLoading: false,
        errorMessage: state.errorMessage,
      );
    });

    _stateSub = _player.onPlayerStateChanged.listen((ps) {
      final playing = ps == PlayerState.playing;
      state = AudioPlaybackState(
        isPlaying: playing,
        position: state.position,
        duration: state.duration,
        filePath: state.filePath,
        isLoading: false,
        errorMessage: state.errorMessage,
      );
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      state = AudioPlaybackState(
        isPlaying: state.isPlaying,
        position: state.position,
        duration: d,
        filePath: state.filePath,
        isLoading: false,
        errorMessage: state.errorMessage,
      );
    });

    ref.onDispose(() {
      _positionSub?.cancel();
      _stateSub?.cancel();
      _durationSub?.cancel();
      _player.dispose();
    });

    return AudioPlaybackState();
  }

  /// 加载音频文件。先检查文件是否存在再加载，出错时状态回退到无音频
  Future<void> loadFile(String path) async {
    appLog.i('[AudioPlayback] 加载音频文件: $path');
    state = AudioPlaybackState(isLoading: true, filePath: path);

    try {
      if (!await File(path).exists()) {
        appLog.w('[AudioPlayback] 文件不存在: $path');
        state = AudioPlaybackState(errorMessage: '音频文件不存在: $path');
        return;
      }

      await _player.stop();
      await _player.setSource(DeviceFileSource(path));
      state = AudioPlaybackState(
        isPlaying: false,
        position: Duration.zero,
        duration: state.duration,
        filePath: path,
        isLoading: false,
      );
    } catch (e) {
      appLog.d('[AudioPlayback] 加载文件失败: $e');
      state = AudioPlaybackState(errorMessage: '加载音频失败: $e');
    }
  }

  /// 切换播放 / 暂停
  Future<void> togglePlayPause() async {
    if (state.isLoading || state.errorMessage != null) return;
    appLog.d('[AudioPlayback] 切换播放/暂停: ');
    try {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.play(DeviceFileSource(state.filePath!));
      }
    } catch (e) {
      appLog.d('[AudioPlayback] 切换失败: $e');
      state = AudioPlaybackState(
        errorMessage: '播放失败: $e',
        filePath: state.filePath,
      );
    }
  }

  /// 跳转到指定播放位置
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// 从指定毫秒位置开始播放
  Future<void> playFromMs(int ms) async {
    final pos = Duration(milliseconds: ms);
    if (state.errorMessage == null) {
      try {
        await _player.play(DeviceFileSource(state.filePath!), position: pos);
      } catch (e) {
        state = AudioPlaybackState(
          errorMessage: '播放失败: $e',
          filePath: state.filePath,
        );
      }
    }
  }

  /// 停止播放
  Future<void> stop() async {
    await _player.stop();
  }
}
