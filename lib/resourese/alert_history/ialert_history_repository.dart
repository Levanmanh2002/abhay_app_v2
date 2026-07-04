import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';

import '../ibase_repository.dart';

abstract class IAlertHistoryRepository extends IBaseRepository {
  Future<List<NotiAlertModel>> getHistory({int page = 1});
}
