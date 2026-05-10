import 'package:get/get.dart';

import 'upsert_supervised_users_controller.dart';

class UpsertSupervisedUsersBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => UpsertSupervisedUsersController(
        supervisedUsersRepository: Get.find(),
      ),
    );
  }
}
