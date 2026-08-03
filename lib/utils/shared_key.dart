class SharedKey {
  static const String token = 'token';

  /// NO CLEAR
  static const String language = 'language';

  // Tracking state (survive app kill → auto-resume)
  static const String isTracking = 'is_tracking';

  // Cached user tracking settings (used by background task handler)
  static const String cachedMaxSpeed = 'cached_max_speed';
  static const String cachedMaxSound = 'cached_max_sound';
  static const String cachedDelayTimeAlert = 'cached_delay_time_alert';
  static const String cachedIsStopAlert = 'cached_is_stop_alert';
  static const String cachedIsMeasuringSound = 'cached_is_measuring_sound';
  static const String cachedIsAutoDetectSpeedLimit = 'cached_is_auto_detect_speed_limit';

  // Số lượng recipient đã accept — cache để BackgroundTaskHandler (isolate riêng,
  // không có GetX/API) biết có nên bật ghi âm bằng chứng SOS hay không.
  static const String cachedRecipientCount = 'cached_recipient_count';

  // Alert cooldown timestamps (shared between foreground & background)
  static const String lastSpeedAlertAt = 'last_speed_alert_at';
  static const String lastSuddenStopAlertAt = 'last_sudden_stop_alert_at';
  static const String lastStopAlertAt = 'last_stop_alert_at';
}
