import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/dialogs/create_recipients_view.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_controller.dart';
import 'package:abhay_app_v2/pages/recipients/view/item_recipient_view.dart';
import 'package:abhay_app_v2/pages/recipients/widget/recipient_empty.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipientsPage extends GetWidget<RecipientsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'tab_recipients'.tr,
        backButton: false,
        backgroundColor: appTheme.background,
        actions: [
          Padding(
            padding: padding(right: 16),
            child: InkWell(
              onTap: () => CreateRecipientsView.show(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: appTheme.appColor,
                ),
                child: Icon(Icons.add_rounded, color: appTheme.whiteColor, size: 20.w),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: appTheme.appColor));
          }
          if (controller.recipients.isEmpty) return const RecipientEmpty();

          return RefreshIndicator(
            color: appTheme.appColor,
            onRefresh: () async => controller.fetchRecipients(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding(horizontal: 16, vertical: 16),
              itemCount: controller.recipients.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => ItemRecipientView(item: controller.recipients[index]),
            ),
          );
        }),
      ),
    );
  }
}
