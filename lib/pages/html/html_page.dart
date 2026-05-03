import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/pages/html/html_parameter.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/build_html_widget.dart';
import 'package:abhay_app_v2/widget/default_app_bar.dart';
import 'package:abhay_app_v2/widget/loading_widget.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import 'html_controller.dart';

class HtmlPage extends GetWidget<HtmlController> {
  @override
  Widget build(BuildContext context) {
    final baseTextStyle = StyleThemeData.size14Weight400();

    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: DefaultAppBar(
        title:
            controller.parameter.htmlType == HtmlType.termsAndPolicies ? 'terms_and_policies'.tr : 'privacy_policy'.tr,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: padding(all: 16),
          physics: const ClampingScrollPhysics(),
          child: BuildHtmlWidget(
            htmlText: controller.htmlContent.value,
            htmlType: 'html_app_${controller.parameter.htmlType.name}',
            style: Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              textAlign: TextAlign.justify,
              fontFamily: baseTextStyle.fontFamily,
              fontSize: FontSize(baseTextStyle.fontSize ?? 14),
              lineHeight: LineHeight(baseTextStyle.height ?? 1.6),
              color: baseTextStyle.color,
            ),
            styleP: Style(
              margin: Margins.only(bottom: 8),
              padding: HtmlPaddings.zero,
              textAlign: TextAlign.justify,
              fontFamily: baseTextStyle.fontFamily,
              fontSize: FontSize(baseTextStyle.fontSize ?? 14),
              lineHeight: LineHeight(baseTextStyle.height ?? 1.6),
              color: baseTextStyle.color,
            ),
          ),
        );
      }),
    );
  }
}
