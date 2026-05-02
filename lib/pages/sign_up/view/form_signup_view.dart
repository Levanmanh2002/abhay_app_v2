import 'package:abhay_app_v2/core/app_border_shadow.dart';
import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/sign_up/sign_up_controller.dart';
import 'package:abhay_app_v2/utils/app/gender_utils.dart';
import 'package:abhay_app_v2/utils/calendar_config_util.dart';
import 'package:abhay_app_v2/utils/custom_validator.dart';
import 'package:abhay_app_v2/utils/formatter_util.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:abhay_app_v2/widget/simple_dropdown_widget.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormSignupView extends GetView<SignUpController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding(all: 20),
      decoration: BoxDecoration(
        color: appTheme.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppBorderShadow.boxShadowAuth,
      ),
      child: Column(
        spacing: 16.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller.fullnameController,
            titleText: 'full_name'.tr,
            hintText: 'full_name_hint'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.name,
            inputFormatters: FormatterUtil.fullNameFormatter,
            prefixIcon: Icon(Icons.person_outline_rounded, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validateFullName,
          ),
          CustomTextField(
            controller: controller.phoneController,
            titleText: 'phone'.tr,
            hintText: 'phone_hint'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.phone,
            inputFormatters: FormatterUtil.phoneFormatter,
            prefixIcon: Icon(Icons.phone_outlined, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validatePhone,
          ),
          CustomTextField(
            controller: controller.emailController,
            titleText: 'email'.tr,
            hintText: 'email_hint'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.emailAddress,
            inputFormatters: FormatterUtil.emailFormatter,
            prefixIcon: Icon(Icons.email_outlined, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validateEmail,
          ),
          SimpleDropdownWidget<Gender>(
            title: 'gender'.tr,
            hintText: 'select_gender'.tr,
            isRequired: true,
            isExpanded: false,
            items: Gender.values,
            selectedItem: controller.selectedGender.value,
            itemAsString: (Gender gender) => gender.displayName,
            onChanged: (Gender? gender) => controller.onSelectGender(gender),
          ),
          CustomTextField(
            controller: controller.birthdayController,
            titleText: 'birthday'.tr,
            hintText: 'select_birthday'.tr,
            readOnly: true,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            suffixIcon: IconButton(
              onPressed: null,
              icon: Assets.icons.calendarGray.svg(width: 21.w, height: 21.w),
            ),
            onTap: () async {
              final ranges = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarConfigUtil.getDefaultConfig(context, singleMode: true, lastDate: DateTime.now()),
                dialogSize: Size(551.w, 420.h),
                borderRadius: BorderRadius.circular(15),
                dialogBackgroundColor: appTheme.whiteColor,
                value: [controller.selectedBirthday.value ?? DateTime.now()],
              );

              if (ranges != null) {
                controller.onSelectBirthday(ranges.first!);
              }
            },
          ),
          CustomTextField(
            controller: controller.addressController,
            titleText: 'address'.tr,
            hintText: 'enter_address'.tr,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputFormatters: FormatterUtil.addressFormatter,
            onValidate: CustomValidator.validateAddress,
            inputType: TextInputType.streetAddress,
          ),
          CustomTextField(
            controller: controller.passwordController,
            titleText: 'password'.tr,
            hintText: 'password_hint'.tr,
            isPassword: true,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.visiblePassword,
            inputFormatters: FormatterUtil.passwordFormatter,
            prefixIcon: Icon(Icons.lock_outline_rounded, color: appTheme.grayColor, size: 20.w),
            onValidate: CustomValidator.validatePassword,
          ),
          CustomTextField(
            controller: controller.confirmPasswordController,
            titleText: 'confirm_password'.tr,
            hintText: 'password_hint'.tr,
            isPassword: true,
            showBorder: false,
            fillColor: appTheme.grayF3Color,
            inputType: TextInputType.visiblePassword,
            inputFormatters: FormatterUtil.passwordFormatter,
            prefixIcon: Icon(Icons.lock_outline_rounded, color: appTheme.grayColor, size: 20.w),
            onValidate: (value) {
              if (value != controller.passwordController.text) {
                return 'passwords_do_not_match'.tr;
              }
              return '';
            },
          ),
        ],
      ),
    );
  }
}
