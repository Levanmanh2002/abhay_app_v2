// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';

// import 'background_service.dart';

// class NotificationService {
//   StreamSubscription<RemoteMessage>? _onMessageSub;
//   StreamSubscription<RemoteMessage>? _onMessageOpenAppSub;
//   StreamSubscription<String>? _onTokenRefresh;

//   final _messaging = FirebaseMessaging.instance;
//   final _plugin = FlutterLocalNotificationsPlugin();

//   void onClose() {
//     _onTokenRefresh?.cancel();
//     _onMessageSub?.cancel();
//     _onMessageOpenAppSub?.cancel();
//   }

//   Future<bool?> onRequestPermission() async {
//     if (Platform.isAndroid) {
//       final granted = _plugin
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
//           .requestNotificationsPermission();

//       await _plugin
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(
//             const AndroidNotificationChannel(
//               AppConstants.notificationChannelId,
//               'Normal POSNAIL_IPAD channel',
//               description: 'This channel is used for normal notifications.',
//               importance: Importance.high,
//             ),
//           );

//       return granted;
//     } else if (Platform.isMacOS) {
//       final settings = await _plugin
//           .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//       loggerHelper.logBlue('macOS notification permission: $settings');
//       return settings;
//     } else {
//       return _plugin
//           .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(alert: true, badge: true, sound: true);
//     }
//   }

//   Future<void> onInit() async {
//     _plugin.initialize(
//       const InitializationSettings(
//         android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//         iOS: DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestSoundPermission: true,
//           requestBadgePermission: true,
//           // onDidReceiveLocalNotification: (id, title, body, payload) {
//           //   _plugin.cancel(id);
//           //   onHandleNotification(jsonDecode(payload ?? '{}'));
//           // },
//         ),
//         macOS: DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestSoundPermission: true,
//           requestBadgePermission: true,
//         ),
//       ),
//       onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
//       onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//     );

//     _onMessageOpenAppSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       onHandleNotification(message.data);
//     });

//     _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
//       loggerHelper.success('FCM Message Data: ${message.data}');
//       _hardReloadService(message.data);
//       if (message.notification != null) {
//         showNotification(message);
//       }
//     });

//     _onTokenRefresh = _messaging.onTokenRefresh.listen((token) async {
//       loggerHelper.logBlue('FCM Token Refresh: $token');
//     });
//   }

//   Future<void> onHandleInitialMessage() async {
//     final lastMessage = await _messaging.getInitialMessage();
//     if (lastMessage != null) {
//       onHandleNotification(lastMessage.data);
//       return;
//     }

//     final lastNotification = await _plugin.getNotificationAppLaunchDetails();
//     if (lastNotification != null &&
//         lastNotification.didNotificationLaunchApp &&
//         lastNotification.notificationResponse != null) {
//       onDidReceiveNotificationResponse(lastNotification.notificationResponse!);
//     }
//   }

//   Future<String?> getFcmToken() async {
//     try {
//       if (Platform.isIOS) {
//         await onRequestPermission();
//       } else if (Platform.isMacOS) {
//         await onRequestPermission();

//         String? apnsToken = await _messaging.getAPNSToken();
//         loggerHelper.success('APNs token: $apnsToken');

//         return apnsToken;
//       }
//       return _messaging.getToken();
//     } catch (e) {
//       loggerHelper.error('Error getting FCM token: $e');
//       return null;
//     }
//   }

//   void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
//     final payload = (jsonDecode(notificationResponse.payload ?? '{}') as Map<String, dynamic>);
//     onHandleNotification(payload['data']);
//   }

//   void showNotification(RemoteMessage message) {
//     _plugin.show(
//       message.notification.hashCode,
//       message.notification?.title ?? '',
//       message.notification?.body ?? '',
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           AppConstants.notificationChannelId,
//           '',
//           color: Color(0xFF434336),
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(
//           presentBadge: true,
//           presentAlert: true,
//           presentSound: true,
//         ),
//       ),
//       payload: jsonEncode(message.toMap()),
//     );
//   }

//   void onHandleNotification(Map<String, dynamic> payload) {
//     loggerHelper.logWhite('Handle notification: $payload', name: 'NotificationService - CLICK');

//     try {
//       final modelType = payload['model_type'] as String? ?? '';

//       switch (modelType) {
//         case ModelTypeUtils.ticket:
//           break;

//         default:
//           break;
//       }
//     } catch (e) {
//       loggerHelper.error('Error handling notification: $e', name: 'NotificationService - CLICK');
//     }
//   }

//   void _hardReloadService(Map<String, dynamic> payload) {
//     final modelType = payload['model_type'] as String? ?? '';

//     final userNotiId = int.tryParse(payload['user_notification_id']?.toString() ?? '');

//     final modelId = payload['model_id'] as String? ?? '';
//     loggerHelper.log('Hard reload service for modelType: $modelType, modelId: $modelId');

//     if (modelType == ModelTypeUtils.ticket) {
//       if (Get.isRegistered<DashboardController>()) {
//         final dashboardController = Get.find<DashboardController>();
//         dashboardController.addUnreadCount(userNotiId);
//       }
//     }
//   }
// }
