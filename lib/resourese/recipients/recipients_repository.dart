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
        return RecipientsModel.fromJsonList(data);
      }
      DialogUtils.showErrorDialog(response.body['message']);
      return [];
    } catch (error, st) {
      handleError(error, st);
      rethrow;
    }
  }

  @override
  Future<bool> createRecipient(String code) async {
    try {
      final response = await clientGetData('${AppConstants.createRecipientUri}/$code');
      if (response.isOk) {
        DialogUtils.showSuccessDialog(response.body['message']);
        return true;
      }
      DialogUtils.showErrorDialog(response.body['message']);
      return false;
    } catch (error, st) {
      handleError(error, st);
      rethrow;
    }
  }

  @override
  Future<bool> deleteRecipient(int id) async {
    try {
      final response = await clientGetData('${AppConstants.deleteRecipientUri}/$id');

      return response.isOk;
    } catch (error, st) {
      handleError(error, st);
      return false;
    }
  }

  @override
  Future<bool> updateRecipient({
    required int id,
    String? receiverEmail,
    String? receiverPhone,
    required int isPush,
    required int isEmail,
    required int isSms,
  }) async {
    try {
      final response = await clientPutData(
        AppConstants.updateRecipientUri,
        {
          'id': id.toString(),
          'receiver_email': receiverEmail ?? '',
          'receiver_phone': receiverPhone ?? '',
          'is_push_notification': isPush.toString(),
          'is_email_notification': isEmail.toString(),
          'is_sms_notification': isSms.toString(),
        },
      );
      return response.isOk;
    } catch (error, st) {
      handleError(error, st);
      return false;
    }
  }
}
