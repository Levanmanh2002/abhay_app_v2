import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';
import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';

import 'irecipients_repository.dart';

class RecipientsRepository extends IRecipientsRepository {
  @override
  Future<List<RecipientsModel>> getRecipients() async {
    try {
      final response = await clientGetData(AppConstants.getRecipientsUri);

      if (response.isOk) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<RecipientsModel> recipients = RecipientsModel.fromJsonList(data);
        return recipients;
      } else {
        DialogUtils.showErrorDialog(response.body['message']);
        return [];
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }

  @override
  Future<bool> createRecipient(String code) async {
    try {
      final response = await clientGetData('${AppConstants.createRecipientUri}/$code');

      if (response.isOk) {
        DialogUtils.showErrorDialog(response.body['message']);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message']);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }
}
