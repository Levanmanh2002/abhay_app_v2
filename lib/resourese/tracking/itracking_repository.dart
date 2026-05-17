import 'package:abhay_app_v2/models/request/alert/alert_request_model.dart';
import 'package:abhay_app_v2/resourese/ibase_repository.dart';

abstract class ITrackingRepository extends IBaseRepository {
  /// Gửi cảnh báo lên server.
  /// Returns true nếu thành công.
  Future<bool> sendAlert(AlertRequestModel params);

  /// Cập nhật cấu hình tracking của user trên server.
  Future<bool> updateTrackingSettings({
    required int maxSpeed,
    required int maxSound,
    required int isStopAlert,
    required int delayTimeAlert,
    required int isMeasuringSound,
    required int isAutoDetectSpeedLimit,
  });
}
