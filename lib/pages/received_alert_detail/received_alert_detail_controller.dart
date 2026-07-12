import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/pages/received_alert_detail/received_alert_detail_parameter.dart';
import 'package:abhay_app_v2/resourese/receive/receive_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class ReceivedAlertDetailController extends GetxController {
  final ReceivedAlertDetailParameter parameter;
  final IReceiveRepository receiveRepository;

  ReceivedAlertDetailController({required this.parameter, required this.receiveRepository});

  Rx<NotiAlertModel?> alertDetail = Rx<NotiAlertModel?>(null);

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAlertDetail();
  }

  void fetchAlertDetail() async {
    try {
      isLoading.value = true;
      final detail = await receiveRepository.getAlertDetail(parameter.id);
      alertDetail.value = detail;
    } catch (e) {
      loggerHelper.error('fetchAlertDetail: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
