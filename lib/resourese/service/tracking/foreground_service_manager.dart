import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'background_task_handler.dart';

/// Quản lý vòng đời của flutter_foreground_task.
///
/// Gọi [init] một lần khi khởi động app (trong main hoặc AppService).
/// Gọi [start] khi user bắt đầu tracking.
/// Gọi [stop]  khi user dừng tracking.
class ForegroundServiceManager {
  static const int _serviceId = 1001;

  /// Khởi tạo cấu hình cho foreground task (gọi 1 lần trong main()).
  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tracking_channel',
        channelName: 'Speed Tracking',
        channelDescription: 'Keeps GPS tracking active in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          Platform.isIOS ? 2000 : 1000, // iOS: 2s, Android: 1s
        ),
        autoRunOnBoot: Platform.isAndroid,
        allowWakeLock: Platform.isAndroid,
        allowWifiLock: Platform.isAndroid,
      ),
    );
  }

  /// Bắt đầu foreground service.
  static Future<void> start() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) return;

    await FlutterForegroundTask.startService(
      serviceId: _serviceId,
      notificationTitle: 'Speed tracking active',
      notificationText: 'Monitoring your speed in the background',
      callback: trackingTaskCallback,
    );
  }

  /// Dừng foreground service.
  static Future<void> stop() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) return;
    await FlutterForegroundTask.stopService();
  }

  static Future<bool> get isRunning =>
      FlutterForegroundTask.isRunningService;
}
