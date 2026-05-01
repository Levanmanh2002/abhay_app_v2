import 'package:abhay_app_v2/widget/reponsive/size_config.dart';
import 'package:flutter/material.dart';

extension Reponsive on num {
  double get w => SizeConfig.instance.getWidth(this) ?? 0;

  double get h => SizeConfig.instance.getHeight(this) ?? 0;

  double get fontSize => SizeConfig.instance.getFontSize(this) ?? 0;
}

EdgeInsets padding({
  double? left,
  double? right,
  double? top,
  double? bottom,
  double? all,
  double? horizontal,
  double? vertical,
}) {
  return SizeConfig.instance.paddingOnly(
        left: all ?? left ?? horizontal,
        right: all ?? right ?? horizontal,
        top: all ?? top ?? vertical,
        bottom: all ?? bottom ?? vertical,
      ) ??
      const EdgeInsets.all(0);
}
