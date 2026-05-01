import 'package:abhay_app_v2/pages/sign_in/sign_in_controller.dart';
import 'package:get/get.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SignInController(
        authRepository: Get.find(),
      ),
    );
  }
}
