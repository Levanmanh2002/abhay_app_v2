import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void onNotificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}

@pragma('vm:entry-point')
Future<void> onBackgroundNotificationHandle(RemoteMessage remoteMessage) async {}
