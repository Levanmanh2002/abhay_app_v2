import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/my_info/my_info_parameter.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/dialog_utils.dart';
import 'package:abhay_app_v2/widget/custom_image_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileHeaderView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.userModel.value;
      return Container(
        color: appTheme.appColor,
        padding: padding(horizontal: 16, bottom: 32),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              CustomImageWidget(
                imageUrl: user?.avatar ?? '',
                width: 68.w,
                height: 68.w,
                showBoder: true,
                colorBoder: appTheme.whiteColor,
                noImage: false,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullname ?? '---',
                      style: StyleThemeData.size18Weight700(color: appTheme.whiteColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    if (user?.code != null)
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: user!.code!));
                          DialogUtils.showSuccessDialog('copied_to_clipboard'.tr);
                        },
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          padding: padding(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: appTheme.whiteColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            spacing: 4.w,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#${user?.code ?? ''}',
                                style: StyleThemeData.size10Weight700(color: appTheme.whiteColor),
                              ),
                              Icon(Icons.copy_rounded, size: 10.w, color: appTheme.whiteColor.withAlpha(180)),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      user?.email ?? '---',
                      style: StyleThemeData.size12Weight400(color: appTheme.whiteColor.withAlpha(200)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(
                  Routes.MY_INFO,
                  arguments: MyInfoParameter(user: controller.userModel.value),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: padding(all: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: appTheme.whiteColor.withAlpha(30),
                  ),
                  child: Icon(Icons.edit_outlined, color: appTheme.whiteColor, size: 18.w),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
