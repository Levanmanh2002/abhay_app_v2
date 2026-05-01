import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
      final f = NumberFormat('#,###');
      final number = int.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final newString = f.format(number).replaceAll(',', '.');
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }

  String format(String value) {
    if (value.isEmpty) return value;

    final number = double.parse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    final formatter = NumberFormat('#,###.##', 'en');

    return formatter.format(number).replaceAll(',', '.');
  }
}

extension OnlyDigits on String {
  String get onlyDigits => replaceAll(RegExp(r'\D'), '');
}
