/// Phát hiện tai nạn / dừng đột ngột khẩn cấp.
///
/// Đúng theo yêu cầu: chỉ fire khi tốc độ CAO giảm về GẦN 0
/// trong thời gian RẤT NGẮN — tức là tình huống tai nạn thực sự.
///
/// Điều kiện để coi là sudden stop:
///   1. Peak speed >= [_minPeakKmh] (30 km/h) — đang chạy đủ nhanh
///   2. Speed giảm về <= [_stopThresholdKmh] (5 km/h) — gần như dừng hẳn
///   3. Thời gian từ peak → gần 0 <= [_maxTimeSec] (6 giây)
///
/// Đèn đỏ bình thường (60→18 km/h trong 15-20s) → KHÔNG fire
/// Tai nạn (60→0 km/h trong 2-3s)               → fire ✅
class SuddenStopDetector {
  /// Tốc độ tối thiểu để bắt đầu theo dõi
  static const double _minPeakKmh = 30.0;

  /// Coi là "gần dừng" khi tốc độ <= ngưỡng này
  static const double _stopThresholdKmh = 5.0;

  /// Thời gian tối đa từ đỉnh tốc độ xuống gần 0 để coi là đột ngột (giây)
  static const int _maxTimeSec = 6;

  double _peakSpeed = 0.0;
  DateTime? _peakTime;
  bool _triggered = false;

  /// Trả về true nếu phát hiện dừng đột ngột.
  bool detect(double currentSpeedKmh) {
    final now = DateTime.now();

    // Cập nhật peak nếu tốc độ tăng
    if (currentSpeedKmh > _peakSpeed) {
      _peakSpeed = currentSpeedKmh;
      _peakTime = now;
      _triggered = false; // reset khi tốc độ tăng trở lại
      return false;
    }

    // Chưa đủ tốc độ để theo dõi
    if (_peakSpeed < _minPeakKmh || _peakTime == null) return false;

    // Đã trigger rồi thì không trigger lại cho cùng 1 sự kiện
    if (_triggered) return false;

    // Tốc độ hiện tại vẫn cao → không phải sudden stop
    if (currentSpeedKmh > _stopThresholdKmh) return false;

    // Tính thời gian từ peak → gần 0
    final elapsed = now.difference(_peakTime!).inSeconds;

    // Tai nạn thực: tốc độ cao → gần 0 trong vòng _maxTimeSec giây
    if (elapsed <= _maxTimeSec) {
      _triggered = true;
      return true;
    }

    // Giảm tốc từ từ (đèn đỏ, kẹt xe) → đã mất > 6 giây → không phải đột ngột
    // Reset để theo dõi tiếp
    _peakSpeed = currentSpeedKmh;
    _peakTime = now;
    return false;
  }

  void reset() {
    _peakSpeed = 0.0;
    _peakTime = null;
    _triggered = false;
  }
}
