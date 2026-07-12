import 'package:abhay_app_v2/extension/string_extension.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/receiver/receiver_model.dart';
import 'package:abhay_app_v2/pages/receive/receive_controller.dart';
import 'package:abhay_app_v2/pages/receive/widget/receive_empty.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_image_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsTabView extends GetView<ReceiveController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return Center(child: CircularProgressIndicator(color: appTheme.appColor));
      }
      if (controller.requests.isEmpty) {
        return ReceiveEmpty(message: 'receive_empty_requests'.tr, icon: Icons.person_add_disabled_outlined);
      }

      return RefreshIndicator(
        color: appTheme.appColor,
        onRefresh: controller.fetchRequests,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding(horizontal: 16, vertical: 8),
          itemCount: controller.requests.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (_, i) => _buildRequestCard(controller.requests[i]),
        ),
      );
    });
  }

  Widget _buildRequestCard(ReceiverModel item) {
    return Container(
      padding: padding(all: 14),
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: appTheme.appColor.withAlpha(12), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CustomImageWidget(
            imageUrl: item.senderAvatar ?? '',
            name: item.senderName ?? '',
            size: 44.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3.h,
              children: [
                Text(
                  item.senderName ?? '---',
                  style: StyleThemeData.size14Weight700(color: appTheme.blackColor),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.senderEmail ?? '---',
                  style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.createdAt?.formatTimeAgo ?? item.senderPhone ?? '---',
                  style: StyleThemeData.size10Weight400(color: appTheme.grayColor),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            spacing: 6.h,
            children: [
              _actionBtn(
                label: 'receive_accept'.tr,
                color: appTheme.greenColor,
                icon: Icons.check_rounded,
                onTap: () => controller.acceptRequest(item),
              ),
              _actionBtn(
                label: 'receive_reject'.tr,
                color: appTheme.errorColor,
                icon: Icons.close_rounded,
                onTap: () => controller.rejectRequest(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: padding(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 3.w,
          children: [
            Icon(icon, size: 12.w, color: color),
            Text(label, style: StyleThemeData.size10Weight700(color: color)),
          ],
        ),
      ),
    );
  }
}
