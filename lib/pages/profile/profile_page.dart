import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/html/html_parameter.dart';
import 'package:abhay_app_v2/pages/my_info/my_info_parameter.dart';
import 'package:abhay_app_v2/pages/profile/profile_controller.dart';
import 'package:abhay_app_v2/pages/profile/view/profile_header_view.dart';
import 'package:abhay_app_v2/pages/profile/widget/menu_section_widget.dart';
import 'package:abhay_app_v2/routes/pages.dart';
import 'package:abhay_app_v2/widget/dialog/show_confirm_dialog.dart';
import 'package:abhay_app_v2/widget/loading_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends GetWidget<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProfile,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.h,
                pinned: true,
                backgroundColor: appTheme.appColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(background: ProfileHeaderView()),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(20.h),
                  child: Container(
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      color: appTheme.background,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: padding(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    MenuSectionWidget(
                      items: [
                        MenuItem(
                          icon: Icons.person_outline_rounded,
                          labelKey: 'profile_my_information',
                          onTap: () => Get.toNamed(
                            Routes.MY_INFO,
                            arguments: MyInfoParameter(user: controller.userModel.value),
                          ),
                        ),
                        MenuItem(
                          icon: Icons.supervised_user_circle_outlined,
                          labelKey: 'profile_supervised_users',
                          onTap: () => Get.toNamed(Routes.SUPERVISED_USERS),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    MenuSectionWidget(
                      items: [
                        MenuItem(
                          icon: Icons.description_outlined,
                          labelKey: 'profile_terms',
                          onTap: () => Get.toNamed(
                            Routes.HTML,
                            arguments: HtmlParameter(htmlType: HtmlType.termsAndPolicies),
                          ),
                        ),
                        MenuItem(
                          icon: Icons.headset_mic_outlined,
                          labelKey: 'profile_contact_support',
                          onTap: () => Get.toNamed(Routes.CONTACT_SUPPORT),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    MenuSectionWidget(
                      items: [
                        MenuItem(
                          icon: Icons.lock_outline_rounded,
                          labelKey: 'profile_change_password',
                          onTap: () => Get.toNamed(Routes.UPDATE_PASSWORD),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    MenuSectionWidget(
                      items: [
                        MenuItem(
                          icon: Icons.logout_rounded,
                          labelKey: 'logout',
                          onTap: () {
                            showConfirmDialog(
                              title: 'logout_confirm'.tr,
                              onConfirm: controller.onLogout,
                            );
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
