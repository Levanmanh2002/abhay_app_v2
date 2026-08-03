import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';
import 'package:abhay_app_v2/resourese/recipients/irecipients_repository.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/easyloading_utils.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:get/get.dart';

class RecipientsController extends GetxController {
  final IRecipientsRepository recipientsRepository;

  RecipientsController({required this.recipientsRepository});

  RxList<RecipientsModel> recipients = <RecipientsModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipients();
  }

  void onRefresh() async {
    if (recipients.isEmpty) {
      fetchRecipients();
    }
  }

  Future<void> fetchRecipients() async {
    try {
      isLoading.value = true;
      final data = await recipientsRepository.getRecipients();
      recipients.value = data;
      await LocalStorage.setInt(SharedKey.cachedRecipientCount, data.length);
    } catch (e) {
      loggerHelper.error('Failed to fetch recipients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRecipient(RecipientsModel item) async {
    if (item.id == null) return;

    final ok = await recipientsRepository.deleteRecipient(item.id!);
    if (ok) {
      recipients.removeWhere((r) => r.id == item.id);
      await LocalStorage.setInt(SharedKey.cachedRecipientCount, recipients.length);
      DialogUtils.showSuccessDialog('recipient_delete_success'.tr);
    } else {
      DialogUtils.showErrorDialog('recipient_delete_failed'.tr);
    }
  }

  Future<void> updateRecipientNotification({
    required RecipientsModel item,
    required int isPush,
    required int isEmail,
    required int isSms,
  }) async {
    try {
      showEasyLoading();
      if (item.id == null) return;

      final ok = await recipientsRepository.updateRecipient(
        id: item.id!,
        receiverEmail: item.receiverEmail,
        receiverPhone: item.receiverPhone,
        isPush: isPush,
        isEmail: isEmail,
        isSms: isSms,
      );
      if (ok) {
        // Cập nhật local list ngay — không cần reload API
        final idx = recipients.indexWhere((r) => r.id == item.id);
        if (idx != -1) {
          recipients[idx] = RecipientsModel(
            id: item.id,
            user: item.user,
            receiverPhone: item.receiverPhone,
            receiverEmail: item.receiverEmail,
            isApproved: item.isApproved,
            isPushNotification: isPush,
            isEmailNotification: isEmail,
            isSmsNotification: isSms,
          );
        }
        DialogUtils.showSuccessDialog('recipient_edit_success'.tr);
      }
    } catch (e) {
      loggerHelper.error('Failed to update recipient: $e');
      DialogUtils.showErrorDialog('recipient_update_failed'.tr);
    } finally {
      dismissEasyLoading();
    }
  }
}
