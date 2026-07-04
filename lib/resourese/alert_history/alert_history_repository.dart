import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';

import 'ialert_history_repository.dart';

class AlertHistoryRepository extends IAlertHistoryRepository {
  @override
  Future<List<NotiAlertModel>> getHistory({int page = 1}) async {
    try {
      final response = await clientGetData(
        '${AppConstants.alertHistoryUri}?page=$page',
      );
      if (response.isOk) {
        final data = response.body['data'] as List<dynamic>? ?? [];
        return NotiAlertModel.fromJsonList(data);
      }
      return [];
    } catch (e, st) {
      loggerHelper.error('getHistory: $e', stackTrace: st);
      return [];
    }
  }
}
