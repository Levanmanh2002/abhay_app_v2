import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/models/response/receiver/receiver_model.dart';
import 'package:abhay_app_v2/resourese/ibase_repository.dart';

abstract class IReceiveRepository extends IBaseRepository {
  Future<List<NotiAlertModel>> getReceivedAlerts();
  Future<List<ReceiverModel>> getReceiverRequests();
  Future<bool> acceptRequest(int id);
  Future<bool> rejectRequest(int id);
  Future<NotiAlertModel?> getAlertDetail(int id);
}
