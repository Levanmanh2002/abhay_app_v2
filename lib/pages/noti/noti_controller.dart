import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/resourese/noti/inoti_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class NotiController extends GetxController {
  final INotiRepository notiRepository;

  NotiController({required this.notiRepository});

  RxList<NotiAlertModel> notiAlerts = <NotiAlertModel>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotiAlerts();
  }

  void fetchNotiAlerts() async {
    try {
      isLoading.value = true;
      final alerts = await notiRepository.getNotiAlerts();
      notiAlerts.value = alerts;
    } catch (e) {
      loggerHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
