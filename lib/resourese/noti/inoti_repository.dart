import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';

import '../ibase_repository.dart';

abstract class INotiRepository extends IBaseRepository {
  Future<List<NotiAlertModel>> getNotiAlerts();
}
