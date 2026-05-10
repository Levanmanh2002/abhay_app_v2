import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';

import 'inoti_repository.dart';

class NotiRepository extends INotiRepository {
  @override
  Future<List<NotiAlertModel>> getNotiAlerts() async {
    try {
      final response = await clientGetData(AppConstants.getNotiAlertsUri);

      if (response.isOk) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<NotiAlertModel> notiAlerts = NotiAlertModel.fromJsonList(data);
        return notiAlerts;
      } else {
        DialogUtils.showErrorDialog(response.body['message']);
        return [];
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }
}
