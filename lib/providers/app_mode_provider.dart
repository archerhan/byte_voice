import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_mode_provider.g.dart';

/// 应用模式：ASR（语音转文字）和 TTS（文字转语音）
enum AppMode { asr, tts }

/// 当前应用模式，默认 ASR
@riverpod
class AppModeController extends _$AppModeController {
  @override
  AppMode build() => AppMode.asr;

  void set(AppMode mode) => state = mode;
}
