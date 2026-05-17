import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/recipients/recipients_model.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_controller.dart';
import 'package:abhay_app_v2/pages/recipients/widget/notif_toggle.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/custom_image_widget.dart';
import 'package:abhay_app_v2/widget/dialog/show_confirm_dialog.dart';
import 'package:abhay_app_v2/widget/line_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemRecipientView extends GetView<RecipientsController> {
  const ItemRecipientView({super.key, required this.item});

  final RecipientsModel item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        showConfirmDialog(
          title: 'recipient_delete_confirm'.tr,
          onConfirm: () => controller.deleteRecipient(item),
        );
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: padding(right: 20),
        decoration: BoxDecoration(
          color: appTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.h,
          children: [
            Icon(Icons.delete_outline_rounded, color: appTheme.whiteColor, size: 22.w),
            Text(
              'recipient_delete'.tr,
              style: StyleThemeData.size10Weight700(color: appTheme.whiteColor),
            ),
          ],
        ),
      ),
      child: _buildCard(item),
    );
  }

  Widget _buildCard(RecipientsModel item) {
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
              CustomImageWidget(
                imageUrl: user?.avatar ?? '',
                name: user?.fullname ?? '',
                size: 48.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.h,
                  children: [
                    Text(
                      user?.fullname ?? '---',
                      style: StyleThemeData.size14Weight700(color: appTheme.blackColor),
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
          LineWidget(color: appTheme.grayE6Color, margin: padding(vertical: 12)),
          _buildNotifRow(item),
        ],
      ),
    );
  }

  Widget _buildNotifRow(RecipientsModel item) {
    return Row(
      children: [
        Text(
          'recipient_notify_via'.tr,
          style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
        ),
        const Spacer(),
        NotifToggle(
          icon: Icons.notifications_outlined,
          label: 'recipient_notify_push'.tr,
          value: item.isPushNotification == 1,
          onChanged: (v) => controller.updateRecipientNotification(
            item: item,
            isPush: v ? 1 : 0,
            isEmail: item.isEmailNotification ?? 0,
            isSms: item.isSmsNotification ?? 0,
          ),
        ),
        SizedBox(width: 6.w),
        NotifToggle(
          icon: Icons.email_outlined,
          label: 'recipient_notify_email'.tr,
          value: item.isEmailNotification == 1,
          onChanged: (v) => controller.updateRecipientNotification(
            item: item,
            isPush: item.isPushNotification ?? 0,
            isEmail: v ? 1 : 0,
            isSms: item.isSmsNotification ?? 0,
          ),
        ),
        SizedBox(width: 6.w),
        NotifToggle(
          icon: Icons.sms_outlined,
          label: 'recipient_notify_sms'.tr,
          value: item.isSmsNotification == 1,
          onChanged: (v) => controller.updateRecipientNotification(
            item: item,
            isPush: item.isPushNotification ?? 0,
            isEmail: item.isEmailNotification ?? 0,
            isSms: v ? 1 : 0,
          ),
        ),
      ],
    );
  }
}
