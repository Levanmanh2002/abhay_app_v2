import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/models/response/receiver/receiver_model.dart';
import 'package:abhay_app_v2/resourese/receive/receive_repository.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';

class ReceiveRepository extends IReceiveRepository {
  @override
  Future<List<NotiAlertModel>> getReceivedAlerts() async {
    try {
      final response = await clientGetData(AppConstants.getReceivedAlertsUri);
      if (response.isOk) {
        final data = response.body['data'] as List<dynamic>? ?? [];
        return NotiAlertModel.fromJsonList(data);
      }
      return [];
    } catch (e, st) {
      loggerHelper.error('getReceivedAlerts: $e', stackTrace: st);
      return [];
    }
  }

  @override
  Future<List<ReceiverModel>> getReceiverRequests() async {
    try {
      final response = await clientGetData(AppConstants.getReceiverRequestsUri);
      if (response.isOk) {
        final data = response.body['data'] as List<dynamic>? ?? [];
        return ReceiverModel.fromJsonList(data);
      }
      return [];
    } catch (e, st) {
      loggerHelper.error('getReceiverRequests: $e', stackTrace: st);
      return [];
    }
  }

  @override
  Future<bool> acceptRequest(int id) async {
    try {
      final response = await clientGetData('${AppConstants.confirmReceiverRequestUri}/$id');
      return response.isOk;
    } catch (e, st) {
      loggerHelper.error('acceptRequest: $e', stackTrace: st);
      return false;
    }
  }

  @override
  Future<bool> rejectRequest(int id) async {
    try {
      final response = await clientGetData('${AppConstants.deleteReceiverRequestUri}/$id');
      return response.isOk;
    } catch (e, st) {
      loggerHelper.error('rejectRequest: $e', stackTrace: st);
      return false;
    }
  }
}
