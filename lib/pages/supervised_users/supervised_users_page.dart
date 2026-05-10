import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/pages/supervised_users/supervised_users_controller.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupervisedUsersPage extends GetWidget<SupervisedUsersController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title: 'profile_supervised_users'.tr,
        isBackIconCustom: true,
        backgroundColor: appTheme.background,
        actions: [
          Padding(
            padding: padding(right: 16),
            child: InkWell(
              onTap: () => Get.toNamed(Routes.UPSERT_SUPERVISED_USERS),
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
            return Center(
              child: CircularProgressIndicator(color: appTheme.appColor),
            );
          }

          if (controller.supervisedUsers.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            color: appTheme.appColor,
            onRefresh: () async => controller.fetchSupervisedUsers(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding(horizontal: 24, vertical: 16),
              itemCount: controller.supervisedUsers.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) {
                final user = controller.supervisedUsers[index];
                return _buildUserCard(user);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      padding: padding(all: 16),
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appTheme.appColor.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
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
              child: user.avatar != null
                  ? CachedNetworkImage(
                      imageUrl: user.avatar!,
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
                  user.fullname ?? '---',
                  style: StyleThemeData.size14Weight700(),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  spacing: 4.w,
                  children: [
                    Icon(Icons.email_outlined, size: 12.w, color: appTheme.grayColor),
                    Expanded(
                      child: Text(
                        user.email ?? '---',
                        style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (user.phoneVerified != null)
                  Row(
                    spacing: 4.w,
                    children: [
                      Icon(Icons.phone_outlined, size: 12.w, color: appTheme.grayColor),
                      Text(
                        user.phoneVerified!,
                        style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (user.code != null)
            Container(
              padding: padding(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: appTheme.appColor.withAlpha(15),
              ),
              child: Text(
                '#${user.code}',
                style: StyleThemeData.size10Weight700(color: appTheme.appColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder(UserModel user) {
    final initial = (user.fullname ?? '?')[0].toUpperCase();
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
              shape: BoxShape.circle,
              color: appTheme.appColor.withAlpha(15),
            ),
            child: Icon(
              Icons.supervised_user_circle_outlined,
              size: 36.w,
              color: appTheme.appColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'supervised_users_empty'.tr,
            style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () => Get.toNamed(Routes.UPSERT_SUPERVISED_USERS),
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
                  Text(
                    'supervised_user_add'.tr,
                    style: StyleThemeData.size14Weight700(color: appTheme.whiteColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
