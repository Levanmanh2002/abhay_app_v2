import 'package:get/get.dart';

import 'map_app_controller.dart';

class MapAppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MapAppController());
  }
}
