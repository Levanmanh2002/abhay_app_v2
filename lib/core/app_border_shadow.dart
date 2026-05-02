import 'package:abhay_app_v2/main.dart';
import 'package:flutter/material.dart';

class AppBorderShadow {
  static List<BoxShadow>? boxShadow = [
    const BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 0),
    ),
  ];

  static List<BoxShadow>? boxShadowAuth = [
    BoxShadow(
      color: appTheme.appColor.withAlpha(15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
