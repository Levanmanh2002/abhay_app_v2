import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends GetWidget<SplashController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.appColor,
      body: Center(),
    );
  }
}
