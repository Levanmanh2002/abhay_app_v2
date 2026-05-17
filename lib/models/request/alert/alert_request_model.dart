/// Params gửi lên API /notifications/send-notification
///
/// Alert types:
///   2 = over speed limit
///   3 = sudden stop
///   4 = vehicle stopped (speed → 0)
class AlertRequestModel {
  final int type;
  final String location;
  final double lat;
  final double lng;
  final double speed;
  final double sound;
  final int speedLimit;

  const AlertRequestModel({
    required this.type,
    required this.location,
    required this.lat,
    required this.lng,
    required this.speed,
    required this.sound,
    required this.speedLimit,
  });

  /// Dùng cho multipart/form-data (API dùng FormData)
  Map<String, String> toFormData() => {
        'type': type.toString(),
        'location': location,
        'lat': lat.toString(),
        'lng': lng.toString(),
        'speed': speed.toString(),
        'sound': sound.toString(),
        'speed_limit': speedLimit.toString(),
      };

  @override
  String toString() =>
      'AlertRequest(type=$type, speed=${speed.toStringAsFixed(1)}, '
      'limit=$speedLimit, lat=$lat, lng=$lng)';
}
