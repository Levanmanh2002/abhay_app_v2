import 'package:geolocator/geolocator.dart';

/// Kết quả sau khi GPS đã lọc.
class GpsResult {
  /// Tốc độ đã lọc (km/h). Có thể = 0 nếu đứng yên.
  final double speedKmh;
  final Position position;

  const GpsResult({required this.speedKmh, required this.position});
}

/// Lọc các position GPS không hợp lệ:
/// - Accuracy quá tệ (> 20m)
/// - Mock location
/// - GPS spike (nhảy cách biệt quá lớn)
/// - Tốc độ vật lý bất khả thi (> 252 km/h)
class GpsFilter {
  static const double _maxAccuracyM = 20.0;
  static const double _maxSpeedJumpKmh = 70.0; // jump tối đa giữa 2 lần đo
  static const double _maxPhysicalSpeedMs = 70.0; // ~252 km/h

  Position? _lastValidPosition;

  /// Trả về [GpsResult] nếu hợp lệ, null nếu nên bỏ qua.
  GpsResult? filter(Position pos) {
    // 1. Accuracy
    if (pos.accuracy > _maxAccuracyM) return null;

    // 2. Mock location
    if (pos.isMocked) return null;

    double speedKmh = pos.speed * 3.6;

    if (_lastValidPosition != null) {
      final distM = Geolocator.distanceBetween(
        _lastValidPosition!.latitude,
        _lastValidPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      final dtMs = pos.timestamp
          .difference(_lastValidPosition!.timestamp)
          .inMilliseconds;
      final dtSec = dtMs / 1000.0;

      if (dtSec > 0) {
        // 3. Teleportation check: tốc độ vật lý bất khả thi
        if (distM / dtSec > _maxPhysicalSpeedMs) {
          // Không cập nhật _lastValidPosition → thử lần sau
          return null;
        }

        // 4. Cross-validate GPS speed vs khoảng cách/thời gian
        final calcSpeedKmh = (distM / dtSec) * 3.6;
        final delta = (speedKmh - calcSpeedKmh).abs();
        // Nếu tốc độ GPS báo cao nhưng thực ra không di chuyển → reset về 0
        if (distM < 2.0 && speedKmh > 10 && delta > calcSpeedKmh * 0.3) {
          speedKmh = 0.0;
        }

        // 5. Spike rejection: tốc độ tăng đột biến bất hợp lý
        final lastSpeedKmh = _lastValidPosition!.speed * 3.6;
        if (lastSpeedKmh > 5 && (speedKmh - lastSpeedKmh) > _maxSpeedJumpKmh) {
          return null;
        }
      }
    }

    _lastValidPosition = pos;
    return GpsResult(speedKmh: speedKmh.clamp(0, 300), position: pos);
  }

  void reset() => _lastValidPosition = null;
}
