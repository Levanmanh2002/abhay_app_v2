import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/models/response/profile/user_model.dart';
import 'package:abhay_app_v2/pages/home/home_controller.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeHeaderView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profileController = Get.find<ProfileController>();
      final user = profileController.userModel.value;

      return Container(
        padding: padding(all: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: appTheme.whiteColor,
          boxShadow: [
            BoxShadow(color: appTheme.appColor.withAlpha(10), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          spacing: 12.w,
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
                        errorWidget: (_, __, ___) => _placeholder(user),
                      )
                    : _placeholder(user),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.h,
                children: [
                  Text(
                    user?.fullname ?? '---',
                    style: StyleThemeData.size16Weight700(),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => Row(
                      spacing: 4.w,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 12.w,
                          color: controller.locationText.value.isEmpty ? appTheme.grayColor : appTheme.appColor,
                        ),
                        Expanded(
                          child: Text(
                            controller.locationText.value.isEmpty ? 'home_locating'.tr : controller.locationText.value,
                            style: StyleThemeData.size12Weight400(
                              color: controller.locationText.value.isEmpty ? appTheme.grayColor : appTheme.gray86Color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: padding(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: controller.isTracking.value ? appTheme.bgGreenColor : appTheme.grayF3Color,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5.w,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isTracking.value ? appTheme.greenColor : appTheme.grayColor,
                      ),
                    ),
                    Text(
                      controller.isTracking.value ? 'home_tracking_on'.tr : 'home_tracking_off'.tr,
                      style: StyleThemeData.size10Weight700(
                        color: controller.isTracking.value ? appTheme.greenColor : appTheme.grayColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(Routes.MAP_APP),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: appTheme.appColor.withAlpha(15),
                ),
                child: Icon(
                  Icons.map_rounded,
                  size: 18.w,
                  color: appTheme.appColor,
                ),
              ),
            ),
            InkWell(
              onTap: () => Get.toNamed(Routes.SETTINGS),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: appTheme.grayF3Color,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18.w,
                  color: appTheme.gray86Color,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _placeholder(UserModel? user) {
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
}
