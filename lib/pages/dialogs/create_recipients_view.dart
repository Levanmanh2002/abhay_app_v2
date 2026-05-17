import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/recipients/recipients_controller.dart';
import 'package:abhay_app_v2/resourese/recipients/irecipients_repository.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/utils/logger_helper.dart';
import 'package:abhay_app_v2/widget/custom_button.dart';
import 'package:abhay_app_v2/widget/custom_text_field.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateRecipientsView extends StatefulWidget {
  const CreateRecipientsView({super.key});

  @override
  State<CreateRecipientsView> createState() => _CreateRecipientsViewState();

  static Future<void> show() {
    return showDialog(
      context: Get.context!,
      builder: (_) => const CreateRecipientsView(),
    );
  }
}

class _CreateRecipientsViewState extends State<CreateRecipientsView> {
  final IRecipientsRepository recipientsRepository = Get.find<IRecipientsRepository>();
  final RecipientsController recipientsController = Get.find<RecipientsController>();

  final TextEditingController codeController = TextEditingController();

  var isLoading = false.obs;
  var isValid = false.obs;

  void createRecipient() async {
    try {
      isLoading.value = true;

      final code = codeController.text.trim();

      final result = await recipientsRepository.createRecipient(code);

      if (result) {
        recipientsController.fetchRecipients();
        Get.back();
      }
    } catch (e) {
      loggerHelper.error('Failed to create recipient: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: appTheme.whiteColor,
      insetPadding: padding(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: padding(all: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.h,
                      children: [
                        Text(
                          'recipient_add'.tr,
                          style: StyleThemeData.size16Weight700(),
                        ),
                        Text(
                          'recipient_add_subtitle'.tr,
                          style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(1000),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: appTheme.grayF3Color),
                      child: Icon(Icons.close_rounded, size: 16.w, color: appTheme.gray86Color),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                controller: codeController,
                titleText: 'recipient_code'.tr,
                hintText: 'recipient_code_hint'.tr,
                showBorder: false,
                fillColor: appTheme.grayF3Color,
                prefixIcon: Icon(Icons.tag_rounded, color: appTheme.grayColor, size: 20.w),
                onChanged: (value) => isValid.value = value.trim().isNotEmpty,
              ),
              SizedBox(height: 8.h),
              Text(
                'recipient_code_note'.tr,
                style: StyleThemeData.size12Weight400(color: appTheme.gray86Color),
              ),
              SizedBox(height: 24.h),
              Obx(
                () => CustomButton(
                  buttonText: 'confirm'.tr,
                  isLoading: isLoading.value,
                  onPressed: isValid.value ? createRecipient : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
