import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';
import 'package:abhay_app_v2/resourese/recipients/irecipients_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
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

  void fetchRecipients() async {
    try {
      isLoading.value = true;
      final data = await recipientsRepository.getRecipients();
      recipients.value = data;
    } catch (e) {
      loggerHelper.error('Failed to fetch recipients: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
