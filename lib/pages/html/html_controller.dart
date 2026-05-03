import 'package:abhay_app_v2/pages/html/html_parameter.dart';
import 'package:abhay_app_v2/resourese/html/ihtml_repository.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:get/get.dart';

class HtmlController extends GetxController {
  final HtmlParameter parameter;
  final IHtmlRepository htmlRepository;

  HtmlController({required this.parameter, required this.htmlRepository});

  var isLoading = false.obs;
  var htmlContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHtmlContent();
  }

  void fetchHtmlContent() async {
    try {
      isLoading.value = true;

      String content = await htmlRepository.getTermsAndPolicies();
      htmlContent.value = content;
    } catch (error) {
      loggerHelper.error('Failed to fetch HTML content: $error');
    } finally {
      isLoading.value = false;
    }
  }
}
