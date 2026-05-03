import 'package:get/get.dart';

import 'contact_support_controller.dart';

class ContactSupportBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ContactSupportController(
        profileRepository: Get.find(),
      ),
    );
  }
}
