/// 本地通知服务 — 转写完成后弹出系统通知
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  /// 本地通知插件实例
  final _plugin = FlutterLocalNotificationsPlugin();

  /// 初始化通知插件
  Future<void> initialize() async {
    const settings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(macOS: settings),
    );
  }

  /// 弹出"转写完成"通知
  Future<void> showTranscriptionComplete(String noteId, String title) async {
    await _plugin.show(
      id: noteId.hashCode,
      title: '转写完成',
      body: '「$title」的转写已经完成',
      notificationDetails: const NotificationDetails(
        macOS: DarwinNotificationDetails(),
      ),
      payload: noteId,
    );
  }
}
