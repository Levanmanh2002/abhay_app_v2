import 'package:flutter/services.dart';

class DecimalNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.startsWith('.')) return oldValue;
    if (text.contains('..')) return oldValue;
    if ('.'.allMatches(text).length > 1) return oldValue; // Chỉ 1 dấu chấm
    if (text.contains(' ')) return oldValue;

    // Chặn số 0 đứng đầu (01, 02,...) nhưng cho phép 0.5
    if (text.length > 1 && text.startsWith('0') && !text.startsWith('0.')) return oldValue;

    return newValue;
  }
}
