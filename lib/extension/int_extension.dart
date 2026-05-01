import 'dart:math' as math;

import 'package:get/get.dart';

extension IntInNullExtension on int? {
  bool get isSuccess => this == 200 || this == 201;

  bool get isAuthError => this == 401 || this == 403;
}

extension StatusExtension on int {
  int get weekdayToIndex {
    switch (this) {
      case 1:
        return 1; // => Thứ 2
      case 2:
        return 2; // => Thứ 3
      case 3:
        return 3; // => Thứ 4
      case 4:
        return 4; // => Thứ 5
      case 5:
        return 5; // => Thứ 6
      case 6:
        return 6; // => Thứ 7
      case 7:
        return 0; // => Chủ nhật
      default:
        return 0;
    }
  }

  String get getDayName {
    switch (this) {
      case 1:
        return 'mon'.tr;
      case 2:
        return 'tue'.tr;
      case 3:
        return 'wed'.tr;
      case 4:
        return 'thu'.tr;
      case 5:
        return 'fri'.tr;
      case 6:
        return 'sat'.tr;
      case 7:
        return 'sun'.tr;
      default:
        return '';
    }
  }
}

extension DoubleParsingExtension on int {
  String toThousandSeparatorFormat({int fractionDigits = 0}) {
    final value = this;
    final factor = math.pow(10, fractionDigits);
    final truncated = (value * factor).truncate() / factor;

    final parts = truncated.toString().split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    if (fractionDigits == 0) return integerPart;

    final decimalPart =
        parts.length > 1 ? parts[1].padRight(fractionDigits, '0').substring(0, fractionDigits) : '0' * fractionDigits;

    return '$integerPart,$decimalPart';
  }
}
