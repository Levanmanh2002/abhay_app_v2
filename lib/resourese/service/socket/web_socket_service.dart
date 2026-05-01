// import 'dart:async';
// import 'dart:convert';

// import 'package:get/get.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'package:web_socket_channel/web_socket_channel.dart';

// class WebSocketService extends GetxService {
//   WebSocketChannel? _channel;

//   final Map<String, List<Function(dynamic)>> _listeners = {};
//   final List<Function(String, dynamic)> _anyListeners = [];
//   final List<Function()> _reconnectedCallbacks = [];

//   // Reconnect logic
//   Timer? _reconnectTimer;
//   int _reconnectAttempts = 0;
//   static const int _maxDelay = 30;

//   // Connection state
//   final Rx<ConnectionState> connectionState = ConnectionState.disconnected.obs;

//   bool get isConnected => _channel != null && connectionState.value == ConnectionState.connected;

//   @override
//   void onClose() {
//     disconnect();
//     _reconnectTimer?.cancel();
//     super.onClose();
//   }

//   Future<void> connect() async {
//     if (isConnected) return;

//     connectionState.value = ConnectionState.connecting;
//     loggerHelper.log('Connecting to WebSocket…');

//     try {
//       _channel = WebSocketChannel.connect(
//         Uri.parse(AppConstants.socketUrl),
//         // Thêm ping interval để keep-alive
//         // protocols: ['websocket'],
//       );

//       loggerHelper.log('WebSocket connected');
//       connectionState.value = ConnectionState.connected;
//       _reconnectAttempts = 0; // Reset reconnect attempts

//       _channel!.stream.listen(
//         (raw) => _handleRawMessage(raw),
//         onError: (err) {
//           loggerHelper.log('[WS ERROR] $err');
//           connectionState.value = ConnectionState.error;
//           _attemptReconnect();
//         },
//         onDone: () {
//           loggerHelper.log('[WS DONE] connection closed');
//           connectionState.value = ConnectionState.disconnected;
//           _channel = null;
//           _attemptReconnect();
//         },
//         cancelOnError: false, // Không cancel stream khi có error
//       );
//     } catch (e) {
//       loggerHelper.log('[WS CONNECT ERROR] $e');
//       connectionState.value = ConnectionState.error;
//       _attemptReconnect();
//     }
//   }

//   void _attemptReconnect() {
//     _reconnectAttempts++;
//     final delay = Duration(seconds: (_reconnectAttempts * 3).clamp(3, _maxDelay));
//     loggerHelper.log('[WS] Reconnecting... Attempt $_reconnectAttempts, delay: ${delay.inSeconds}s');

//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(delay, () async {
//       await connect();
//       if (isConnected) {
//         for (final cb in _reconnectedCallbacks) {
//           cb();
//         }
//       }
//     });
//   }

//   void disconnect() {
//     if (_channel == null) return;

//     _reconnectTimer?.cancel();
//     _channel?.sink.close(status.normalClosure);
//     _channel = null;
//     connectionState.value = ConnectionState.disconnected;
//     loggerHelper.log('WebSocket disconnected');
//   }

//   void emit(String action, dynamic data) {
//     if (!isConnected) {
//       loggerHelper.log('[WS] Cannot emit, not connected');
//       return;
//     }

//     try {
//       final payload = jsonEncode({
//         'action': action,
//         ...data,
//       });

//       loggerHelper.log('[SEND] $payload');
//       _channel!.sink.add(payload);
//     } catch (e) {
//       loggerHelper.log('[EMIT ERROR] $e');
//     }
//   }

//   void subscribe(String channel) {
//     emit('subscribe', {'channel': channel});
//   }

//   void on(String event, Function(dynamic data) callback) {
//     _listeners.putIfAbsent(event, () => []);
//     _listeners[event]!.add(callback);
//   }

//   void off(String event, [Function(dynamic data)? callback]) {
//     if (callback == null) {
//       _listeners.remove(event);
//     } else {
//       _listeners[event]?.remove(callback);
//     }
//   }

//   void onAny(Function(String event, dynamic data) callback) {
//     _anyListeners.add(callback);
//   }

//   void offAny(Function(String event, dynamic data) callback) {
//     _anyListeners.remove(callback);
//   }

//   void _handleRawMessage(dynamic raw) {
//     loggerHelper.log('[RAW] $raw');

//     dynamic jsonData;

//     try {
//       jsonData = jsonDecode(raw);
//     } catch (e) {
//       loggerHelper.log('[JSON PARSE ERROR] $e');
//       return;
//     }

//     final event = jsonData['event'];
//     final data = jsonData['data'];

//     // Gọi any listeners
//     for (final callback in _anyListeners) {
//       try {
//         callback(event, data);
//       } catch (e) {
//         loggerHelper.log('[ANY LISTENER ERROR] $e');
//       }
//     }

//     // Gọi listeners theo event
//     if (_listeners.containsKey(event)) {
//       for (final callback in _listeners[event]!) {
//         try {
//           callback(data);
//         } catch (e) {
//           loggerHelper.log('[LISTENER ERROR on $event] $e');
//         }
//       }
//     }
//   }

//   void addReconnectedCallback(Function() callback) {
//     _reconnectedCallbacks.add(callback);
//   }

//   void clearReconnectedCallbacks() {
//     _reconnectedCallbacks.clear();
//   }
// }

// enum ConnectionState {
//   disconnected,
//   connecting,
//   connected,
//   error,
// }
