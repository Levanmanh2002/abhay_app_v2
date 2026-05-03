import 'package:abhay_app_v2/models/response/config/config_info_model.dart';
import 'package:abhay_app_v2/resourese/profile/iprofile_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class ContactSupportController extends GetxController {
  final IProfileRepository profileRepository;

  ContactSupportController({required this.profileRepository});

  Rx<ConfigInfoModel?> configInfo = Rx<ConfigInfoModel?>(null);

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfigInfo();
  }

  void fetchConfigInfo() async {
    try {
      isLoading.value = true;

      final info = await profileRepository.getConfigInfo();
      configInfo.value = info;
    } catch (error) {
      loggerHelper.error('Error fetching config info: $error');
    } finally {
      isLoading.value = false;
    }
  }
}
