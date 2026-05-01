import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:flutter/material.dart';

class ClearIconText extends StatelessWidget {
  const ClearIconText({
    super.key,
    this.controller,
    this.text = '',
    this.mainAxisAlignment,
    this.handleAfterClear,
    this.icon,
  });

  final String? text;
  final TextEditingController? controller;
  final VoidCallback? handleAfterClear;
  final MainAxisAlignment? mainAxisAlignment;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: () {
        if (controller != null) {
          controller?.text = '';
        }
        handleAfterClear?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
        children: [
          icon ?? Assets.icons.closeCircleOutline.svg(width: 20.w, height: 20.w),
        ],
      ),
    );
    if (controller != null) {
      return ValueListenableBuilder(
        valueListenable: controller!,
        builder: (_, textCtrl, __) => Visibility(visible: textCtrl.text.isNotEmpty, child: child),
      );
    }
    return Visibility(visible: text?.isNotEmpty ?? false, child: child);
  }
}
