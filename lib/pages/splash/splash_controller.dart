import 'dart:async';

import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/utils/local_storage.dart';
import 'package:abhay_app_v2/utils/shared_key.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500)).then((value) => init());
  }

  void init() async {
    final token = LocalStorage.getString(SharedKey.token);

    if (token.isNotEmpty) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.SIGN_IN);
    }
  }
}
