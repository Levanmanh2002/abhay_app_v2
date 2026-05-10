import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';
import 'package:abhay_app_v2/pages/dialogs/create_recipients_view.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipientsPage extends GetWidget<RecipientsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'tab_recipients'.tr,
        isBackIconCustom: true,
        backgroundColor: appTheme.background,
        actions: [
          Padding(
            padding: padding(right: 16),
            child: InkWell(
              onTap: () {
                CreateRecipientsView.show();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: appTheme.appColor,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: appTheme.whiteColor,
                  size: 20.w,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: appTheme.appColor),
            );
          }

          if (controller.recipients.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: appTheme.appColor,
            onRefresh: () async => controller.fetchRecipients(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding(horizontal: 24, vertical: 16),
              itemCount: controller.recipients.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => _buildRecipientCard(controller.recipients[index]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecipientCard(RecipientsModel item) {
    final user = item.user;
    final isApproved = item.isApproved == 1;

    return Container(
      padding: padding(all: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: appTheme.whiteColor,
        boxShadow: [
          BoxShadow(
            color: appTheme.appColor.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appTheme.appColor.withAlpha(40),
                    width: 2.w,
                  ),
                ),
                child: ClipOval(
                  child: user?.avatar != null
                      ? CachedNetworkImage(
                          imageUrl: user!.avatar!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _avatarPlaceholder(user),
                          errorWidget: (_, __, ___) => _avatarPlaceholder(user),
                        )
                      : _avatarPlaceholder(user),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.h,
                  children: [
                    Text(
                      user?.fullname ?? '---',
                      style: StyleThemeData.size14Weight700(
                        color: appTheme.blackColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      spacing: 4.w,
                      children: [
                        Icon(Icons.email_outlined, size: 12.w, color: appTheme.grayColor),
                        Expanded(
                          child: Text(
                            item.receiverEmail ?? user?.email ?? '---',
                            style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if ((item.receiverPhone ?? user?.phoneVerified) != null)
                      Row(
                        spacing: 4.w,
                        children: [
                          Icon(Icons.phone_outlined, size: 12.w, color: appTheme.grayColor),
                          Text(
                            item.receiverPhone ?? user!.phoneVerified!,
                            style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: padding(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isApproved ? appTheme.bgGreenColor : appTheme.secondaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 3.w,
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: 10.w,
                      color: isApproved ? appTheme.greenColor : appTheme.secondaryColor,
                    ),
                    Text(
                      isApproved ? 'recipient_approved'.tr : 'recipient_pending'.tr,
                      style: StyleThemeData.size10Weight700(
                        color: isApproved ? appTheme.greenColor : appTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_hasAnyNotification(item)) ...[
            SizedBox(height: 12.h),
            Divider(color: appTheme.grayE6Color, height: 1),
            SizedBox(height: 10.h),
            Row(
              spacing: 8.w,
              children: [
                Text(
                  'recipient_notify_via'.tr,
                  style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                ),
                if (item.isPushNotification == 1) _notifBadge(Icons.notifications_outlined, 'Push'),
                if (item.isEmailNotification == 1) _notifBadge(Icons.email_outlined, 'Email'),
                if (item.isSmsNotification == 1) _notifBadge(Icons.sms_outlined, 'SMS'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _hasAnyNotification(RecipientsModel item) =>
      item.isPushNotification == 1 || item.isEmailNotification == 1 || item.isSmsNotification == 1;

  Widget _notifBadge(IconData icon, String label) {
    return Container(
      padding: padding(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: appTheme.appColor.withAlpha(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 3.w,
        children: [
          Icon(icon, size: 10.w, color: appTheme.appColor),
          Text(
            label,
            style: StyleThemeData.size10Weight700(color: appTheme.appColor),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(UserModel? user) {
    final initial = (user?.fullname ?? '?')[0].toUpperCase();
    return Container(
      color: appTheme.appColor.withAlpha(20),
      child: Center(
        child: Text(
          initial,
          style: StyleThemeData.size16Weight700(color: appTheme.appColor),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: appTheme.appColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 36.w,
              color: appTheme.appColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'recipients_empty'.tr,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () {
              CreateRecipientsView.show();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: padding(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: appTheme.appColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6.w,
                children: [
                  Icon(Icons.add_rounded, color: appTheme.whiteColor, size: 18.w),
                  Text('recipient_add'.tr, style: StyleThemeData.size14Weight700(color: appTheme.whiteColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
