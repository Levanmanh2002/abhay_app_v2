import 'package:flutter_easyloading/flutter_easyloading.dart';

void showEasyLoading() {
  EasyLoading.show(dismissOnTap: false, maskType: EasyLoadingMaskType.clear);
}

void dismissEasyLoading() {
  EasyLoading.dismiss();
}
