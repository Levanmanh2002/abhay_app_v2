import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/receive/receive_controller.dart';
import 'package:abhay_app_v2/pages/receive/view/alerts_tab_view.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'view/requests_tab_view.dart';
import 'view/tab_bar_receive_view.dart';

class ReceivePage extends GetWidget<ReceiveController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'tab_received'.tr,
        backButton: false,
        backgroundColor: appTheme.background,
      ),
      body: Column(
        children: [
          TabBarReceiveView(),
          Expanded(
            child: Obx(() => controller.currentTab.value == 0 ? AlertsTabView() : RequestsTabView()),
          ),
        ],
      ),
    );
  }
}
