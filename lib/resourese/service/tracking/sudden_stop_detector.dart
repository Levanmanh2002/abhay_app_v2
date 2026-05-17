/// Phát hiện dừng đột ngột bằng thuật toán peak-speed-window.
///
/// Nguyên lý:
/// - Theo dõi tốc độ đỉnh (_peakSpeed) trong cửa sổ 10 giây.
/// - Coi là dừng đột ngột khi:
///   1. Tốc độ giảm về 0 từ peak >= 5 km/h, HOẶC
///   2. Tốc độ giảm >= 60% so với peak (peak phải >= 10 km/h).
/// - Cooldown: chỉ báo 1 lần cho mỗi sự kiện, reset khi phục hồi tốc độ.
class SuddenStopDetector {
  static const int _peakWindowSeconds = 10;
  static const double _minPeakKmh = 10.0;
  static const double _dropPercentThreshold = 60.0;

  double _peakSpeed = 0.0;
  DateTime? _peakSpeedTime;
  bool _hasJustSentAlert = false;

  /// Trả về true nếu phát hiện dừng đột ngột với [currentSpeedKmh].
  bool detect(double currentSpeedKmh) {
    final now = DateTime.now();

    // Cập nhật peak speed
    if (currentSpeedKmh > _peakSpeed) {
      _peakSpeed = currentSpeedKmh;
      _peakSpeedTime = now;
    }

    // Reset peak nếu ngoài cửa sổ thời gian
    if (_peakSpeedTime != null &&
        now.difference(_peakSpeedTime!).inSeconds > _peakWindowSeconds) {
      _peakSpeed = currentSpeedKmh;
      _peakSpeedTime = now;
      _hasJustSentAlert = false;
      return false;
    }

    if (_peakSpeed >= _minPeakKmh && _peakSpeedTime != null) {
      final stoppedCompletely = _peakSpeed >= 5 && currentSpeedKmh <= 0;
      final percentDrop = _peakSpeed > 0
          ? ((_peakSpeed - currentSpeedKmh) / _peakSpeed) * 100
          : 0.0;
      final hasSuddenDrop =
          _peakSpeed >= _minPeakKmh && percentDrop >= _dropPercentThreshold;

      if ((stoppedCompletely || hasSuddenDrop) && !_hasJustSentAlert) {
        _hasJustSentAlert = true;
        // Reset peak ngay sau khi detect
        _peakSpeed = currentSpeedKmh;
        _peakSpeedTime = now;
        return true;
      }
    }

    // Reset flag khi tốc độ phục hồi trở lại
    if (currentSpeedKmh >= _peakSpeed * 0.8 && currentSpeedKmh >= _minPeakKmh) {
      _hasJustSentAlert = false;
    }

    return false;
  }

  void reset() {
    _peakSpeed = 0.0;
    _peakSpeedTime = null;
    _hasJustSentAlert = false;
  }
}
