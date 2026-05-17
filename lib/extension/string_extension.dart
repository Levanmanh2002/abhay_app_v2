import 'package:abhay_app_v2/utils/diacritic_utils.dart';
import 'package:get/get.dart';

extension StringToInt on String? {
  int get toIntValue {
    return int.tryParse(this ?? '') ?? 0;
  }

  double get toDoubleValue {
    return double.tryParse(this ?? '') ?? 0;
  }

  String get formatTimeAgo {
    if (this == null) return '';
    try {
      final dt = DateTime.parse(this!).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just_now'.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

extension StringFormatting on String {
  DateTime get toDateTime => DateTime.parse(this);

  String get formattedCurrency {
    final number = double.tryParse(this);
    if (number == null) {
      return this;
    }
    return '₫${number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  String get formatPhoneNumber {
    final clean = replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) return '';

    int firstGroupLength = (clean.length % 3 == 1) ? 4 : 3;
    if (clean.length <= firstGroupLength) return clean;

    String result = '';
    int index = 0;

    result = clean.substring(0, firstGroupLength);
    index = firstGroupLength;

    while (index < clean.length) {
      result += ' ';
      int nextIndex = index + 3;
      if (nextIndex > clean.length) {
        nextIndex = clean.length;
      }
      result += clean.substring(index, nextIndex);
      index = nextIndex;
    }
    return result;
  }

  String get getFormattedPhoneNumber {
    if (isEmpty) {
      return '';
    }

    String phoneNumber = this;
    bool addPlus = phoneNumber.startsWith('1');
    if (addPlus) phoneNumber = phoneNumber.substring(1);
    bool addParents = phoneNumber.length >= 3;
    bool addDash = phoneNumber.length >= 8;

    String updatedNumber = '';
    if (addPlus) updatedNumber += '+1';

    if (addParents) {
      updatedNumber += '(';
      updatedNumber += phoneNumber.substring(0, 3);
      updatedNumber += ')';
    } else {
      updatedNumber += phoneNumber.substring(0);
      return updatedNumber;
    }

    if (addDash) {
      updatedNumber += phoneNumber.substring(3, 6);
      updatedNumber += '-';
    } else {
      updatedNumber += phoneNumber.substring(3);
      return updatedNumber;
    }

    updatedNumber += phoneNumber.substring(6);
    return updatedNumber;
  }

  String get addSpaceAfterComma {
    return replaceAllMapped(
      RegExp(r',(?!\s)'),
      (match) => ', ',
    );
  }

  String get formatPhoneNumberApp {
    final digits = replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  String get toUsPhoneFormat {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return this;

    final areaCode = digits.substring(0, 3);
    final middle = digits.substring(3, 6);
    final last = digits.substring(6);
    return '($areaCode) $middle-$last';
  }

  int get toDigitsInt {
    final onlyDigits = replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(onlyDigits) ?? 0;
  }

  double get toDigitsDouble {
    final onlyDigits = replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(onlyDigits) ?? 0;
  }

  String get normalize => removeDiacritics(this).toLowerCase();

  String get toShortId {
    const length = 5;
    if (this.length <= length) return this;
    return substring(this.length - length);
  }

  String get removeAllStyle {
    return replaceAll(RegExp(r'style="[^"]*"'), '');
  }
}
