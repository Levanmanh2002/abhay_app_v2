import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/models/response/receiver/receiver_model.dart';
import 'package:abhay_app_v2/resourese/receive/receive_repository.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class ReceiveController extends GetxController {
  final IReceiveRepository repository;

  ReceiveController({required this.repository});

  RxList<NotiAlertModel> receivedAlerts = <NotiAlertModel>[].obs;
  RxList<ReceiverModel> requests = <ReceiverModel>[].obs;

  var isLoadingAlerts = false.obs;
  var isLoadingRequests = false.obs;

  var currentTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  void onRefresh() async {
    Future.wait([if (receivedAlerts.isEmpty) fetchAlerts(), if (requests.isEmpty) fetchRequests()]);
  }

  Future<void> fetchAll() async {
    Future.wait([fetchAlerts(), fetchRequests()]);
  }

  Future<void> fetchAlerts() async {
    try {
      isLoadingAlerts.value = true;
      receivedAlerts.value = await repository.getReceivedAlerts();
    } catch (e) {
      loggerHelper.error('fetchAlerts: $e');
    } finally {
      isLoadingAlerts.value = false;
    }
  }

  Future<void> fetchRequests() async {
    try {
      isLoadingRequests.value = true;
      requests.value = await repository.getReceiverRequests();
    } catch (e) {
      loggerHelper.error('fetchRequests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  Future<void> acceptRequest(ReceiverModel item) async {
    if (item.id == null) return;
    final ok = await repository.acceptRequest(item.id!);
    if (ok) {
      requests.removeWhere((r) => r.id == item.id);
      DialogUtils.showSuccessDialog('receive_accept_success'.tr);
    }
  }

  Future<void> rejectRequest(ReceiverModel item) async {
    if (item.id == null) return;
    final ok = await repository.rejectRequest(item.id!);
    if (ok) {
      requests.removeWhere((r) => r.id == item.id);
      DialogUtils.showSuccessDialog('receive_reject_success'.tr);
    }
  }
}
