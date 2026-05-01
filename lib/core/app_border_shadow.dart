import 'package:flutter/material.dart';

class AppBorderShadow {
  static List<BoxShadow>? boxShadow = [
    const BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 0),
    ),
  ];

  static List<BoxShadow>? boxShadowDropdown = [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 100,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];
}
