import 'package:flutter/services.dart';

/// Mute tạm STREAM_MUSIC quanh lúc SpeechRecognizer start/stop để chặn tiếng
/// "beep" hệ thống mỗi lần session bị restart. Xem native handler tương ứng ở
/// MainActivity.kt (channel: com.chaitany.abhay/audio_mute).
/// No-op an toàn trên iOS / khi channel lỗi (không có beep này trên iOS).
class SystemSoundMuter {
  static const _channel = MethodChannel('com.chaitany.abhay/audio_mute');

  static Future<void> mute() async {
    try {
      await _channel.invokeMethod('mute');
    } catch (_) {}
  }

  static Future<void> unmute() async {
    try {
      await _channel.invokeMethod('unmute');
    } catch (_) {}
  }
}
