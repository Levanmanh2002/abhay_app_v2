import 'package:flutter/material.dart';

class SizeConfig {
  late double designScreenWidth;
  late double desginScreenHeight;

  static final SizeConfig instance = SizeConfig._();

  SizeConfig._();

  late double _widthMultipler;

  late double _heightMultipler;

  late double _textMultiplier;

  void init({required double screenWidth, required double screenHeight, required BoxConstraints constraints}) {
    desginScreenHeight = screenHeight;
    designScreenWidth = screenWidth;
    _widthMultipler = _textMultiplier = constraints.maxWidth / designScreenWidth;
    _heightMultipler = constraints.maxHeight / desginScreenHeight;
  }

  double? getWidth(num? width) {
    if (width == null) {
      return null;
    }
    return width * _widthMultipler;
  }

  double? getHeight(num? height) {
    if (height == null) {
      return null;
    }
    return height * _heightMultipler;
  }

  EdgeInsets? paddingOnly({double? left, double? right, double? top, double? bottom}) {
    return EdgeInsets.only(
      left: left != null ? left * _widthMultipler : 0,
      right: right != null ? right * _widthMultipler : 0,
      top: top != null ? top * _heightMultipler : 0,
      bottom: bottom != null ? bottom * _heightMultipler : 0,
    );
  }

  EdgeInsets? paddingAll({double? all}) {
    return EdgeInsets.all(all != null ? all * _widthMultipler : 0);
  }

  EdgeInsets? paddingSymmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? horizontal * _widthMultipler : 0,
      vertical: vertical != null ? vertical * _heightMultipler : 0,
    );
  }

  double? getFontSize(num? size) => (size ?? 0) * _textMultiplier;
}
