import 'package:abhay_app_v2/utils/app_constants.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:get/get.dart';

import 'ihome_repository.dart';

class HomeRepository extends IHomeRepository {
  @override
  Future<bool> onSosSend({
    required double latitude,
    required double longitude,
    required String address,
    String? content,
  }) async {
    try {
      final response = await clientPostData(
        AppConstants.sosUri,
        {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'address': address,
          if (content != null) 'content': content,
        },
      );

      if (response.isOk) {
        DialogUtils.showSuccessDialog('sos_send_success'.tr);
        return true;
      } else {
        DialogUtils.showErrorDialog(response.body['message'] ?? 'sos_send_failed'.tr);
        return false;
      }
    } catch (error) {
      handleError(error);
      rethrow;
    }
  }
}
