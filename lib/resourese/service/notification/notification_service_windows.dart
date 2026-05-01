// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationServiceWindows {
//   final _plugin = FlutterLocalNotificationsPlugin();

//   Future<void> onInit() async {
//     await _plugin.initialize(
//       InitializationSettings(
//         windows: WindowsInitializationSettings(
//           guid: AppConstants.windowsNotificationGuid,
//           appName: AppConstants.appName,
//           appUserModelId: 'com.posnail_ipad_quan_ly',
//         ),
//       ),
//       onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//     );
//   }

//   Future<void> onHandleInitialMessage() async {
//     final lastNotification = await _plugin.getNotificationAppLaunchDetails();
//     if (lastNotification != null &&
//         lastNotification.didNotificationLaunchApp &&
//         lastNotification.notificationResponse != null) {
//       onDidReceiveNotificationResponse(lastNotification.notificationResponse!);
//     }
//   }

//   void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
//     onHandleNotification((jsonDecode(notificationResponse.payload ?? '{}') as Map<String, dynamic>));
//   }

//   void showNotification({required String title, required String body, Map<String, dynamic>? payload}) {
//     if (title.isEmpty && body.isEmpty) return;

//     try {
//       loggerHelper.logWhite('$title', name: 'SHOW NOTI TITLE');
//       loggerHelper.logWhite('$body', name: 'SHOW NOTI BODY');

//       final int id = DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF);

//       _plugin.show(
//         id,
//         title,
//         body,
//         NotificationDetails(
//           windows: WindowsNotificationDetails(
//             scenario: WindowsNotificationScenario.urgent,
//             audio: WindowsNotificationAudio.preset(sound: WindowsNotificationSound.defaultSound),
//             duration: WindowsNotificationDuration.long,
//           ),
//         ),
//         payload: payload != null ? jsonEncode(payload) : null,
//       );
//     } catch (e) {
//       loggerHelper.error(e.toString());
//     }
//   }

//   void onHandleNotification(Map<String, dynamic> payload) {
//     loggerHelper.logWhite('Handle notification: $payload', name: 'NotificationServiceWindows - CLICK');
//     try {
//       // Handle notification click
//     } catch (e) {
//       loggerHelper.error('Error handling notification: $e', name: 'NotificationServiceWindows - CLICK');
//     }
//   }
// }
