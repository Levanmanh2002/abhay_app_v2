import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/my_info/my_info_controller.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyInfoPage extends GetWidget<MyInfoController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: appTheme.background,
        appBar: DefaultAppBar(
          title: 'profile_my_information'.tr,
          isBackIconCustom: true,
          backgroundColor: appTheme.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: padding(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                _buildAvatar(),
                SizedBox(height: 32.h),
                _buildFormCard(),
                SizedBox(height: 32.h),
                Obx(
                  () => CustomButton(
                    buttonText: 'save'.tr,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.isFormValid.value ? controller.updateProfile : null,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(() {
      final user = controller.user.value;
      final avatarFile = controller.avatarFile.value;

      return Center(
        child: Stack(
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: appTheme.appColor.withAlpha(40),
                  width: 3.w,
                ),
              ),
              child: ClipOval(
                child: avatarFile != null
                    ? Image.file(
                        avatarFile.file!,
                        fit: BoxFit.cover,
                      )
                    : user?.avatar != null
                        ? CachedNetworkImage(
                            imageUrl: user!.avatar!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _avatarPlaceholder(),
                            errorWidget: (_, __, ___) => _avatarPlaceholder(),
                          )
                        : _avatarPlaceholder(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: controller.onPickImageAvatar,
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: appTheme.whiteColor, width: 2.w),
                    color: appTheme.appColor,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 14.w,
                    color: appTheme.whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _avatarPlaceholder() {
    return Container(
      color: appTheme.appColor.withAlpha(15),
      child: Icon(
        Icons.person_rounded,
        color: appTheme.appColor,
        size: 48.w,
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: padding(all: 20),
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppBorderShadow.boxShadow,
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: controller.fullnameController,
            titleText: 'full_name'.tr,
            hintText: 'full_name_hint'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.name,
            prefixIcon: Icon(Icons.person_outline_rounded, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validateFullName,
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            controller: controller.phoneController,
            titleText: 'phone'.tr,
            hintText: 'phone_hint'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.phone,
            prefixIcon: Icon(Icons.phone_outlined, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validatePhone,
          ),
          SizedBox(height: 20.h),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'email'.tr,
                      style: StyleThemeData.size14Weight700(),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: padding(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: appTheme.bgGreenColor,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 3.w,
                        children: [
                          Icon(Icons.verified_rounded, size: 10.w, color: appTheme.greenColor),
                          Text(
                            'email_verified'.tr,
                            style: StyleThemeData.size10Weight700(color: appTheme.greenColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: padding(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: appTheme.grayF3Color,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: appTheme.grayColor,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          controller.user.value?.email ?? '---',
                          style: StyleThemeData.size14Weight400(color: appTheme.gray86Color),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: padding(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: appTheme.appColor.withAlpha(15),
                          ),
                          child: Text(
                            'change'.tr,
                            style: StyleThemeData.size12Weight700(color: appTheme.appColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'email_change_note'.tr,
                    style: StyleThemeData.size10Weight400(color: appTheme.gray86Color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
