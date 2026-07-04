import 'package:abhay_app_v2/models/response/noti_alert/noti_alert_model.dart';
import 'package:abhay_app_v2/resourese/alert_history/ialert_history_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class AlertHistoryController extends GetxController {
  final IAlertHistoryRepository alertHistoryRepository;

  AlertHistoryController({required this.alertHistoryRepository});

  final RxList<NotiAlertModel> alerts = <NotiAlertModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  int _page = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    if (isLoading.value) return;
    _page = 1;
    _hasMore = true;
    isLoading.value = true;
    try {
      final data = await alertHistoryRepository.getHistory(page: _page);
      alerts.value = data;
      _hasMore = data.isNotEmpty;
    } catch (e) {
      loggerHelper.error('fetchHistory: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      _page++;
      final data = await alertHistoryRepository.getHistory(page: _page);
      if (data.isEmpty) {
        _hasMore = false;
      } else {
        alerts.addAll(data);
      }
    } catch (e) {
      _page--;
      loggerHelper.error('loadMore: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }
}
