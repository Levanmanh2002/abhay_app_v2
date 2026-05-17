import 'package:abhay_app_v2/models/request/alert/alert_request_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';

import 'itracking_repository.dart';

class TrackingRepository extends ITrackingRepository {
  @override
  Future<bool> sendAlert(AlertRequestModel params) async {
    try {
      final response = await clientPostMultipartData(
        AppConstants.sendAlertUri,
        params.toFormData(),
        [],
      );

      if (response.isOk) {
        loggerHelper.success('[ALERT] ✅ Sent: $params');
        return true;
      }

      loggerHelper.error('[ALERT] ❌ Failed: ${response.body}');
      return false;
    } catch (e, st) {
      handleError(e, st);
      return false;
    }
  }

  @override
  Future<bool> updateTrackingSettings({
    required int maxSpeed,
    required int maxSound,
    required int isStopAlert,
    required int delayTimeAlert,
    required int isMeasuringSound,
    required int isAutoDetectSpeedLimit,
  }) async {
    try {
      final response = await clientPostMultipartData(
        AppConstants.updateUserUri,
        {
          'max_speed': maxSpeed.toString(),
          'max_sound_intensity': maxSound.toString(),
          'is_stop_alert': isStopAlert.toString(),
          'delay_time_alert': delayTimeAlert.toString(),
          'is_measuring_sound': isMeasuringSound.toString(),
          'is_auto_detect_speed_limit': isAutoDetectSpeedLimit.toString(),
        },
        [],
      );

      if (response.isOk) {
        loggerHelper.success('[TRACKING] Settings updated');
        return true;
      }

      loggerHelper.error('[TRACKING] Update settings failed: ${response.body}');
      return false;
    } catch (e, st) {
      handleError(e, st);
      return false;
    }
  }
}
