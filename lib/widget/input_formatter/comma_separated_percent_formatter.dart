import 'package:flutter/services.dart';

class CommaSeparatedPercentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.startsWith(',')) return oldValue;
    if (text.contains(',,')) return oldValue;

    final parts = text.split(',');

    for (final part in parts) {
      if (part.length > 1 && part.startsWith('0')) {
        final fixed = parts.map((p) => (p.length > 1 && p.startsWith('0')) ? p.substring(1) : p).join(',');
        return newValue.copyWith(
          text: fixed,
          selection: TextSelection.collapsed(offset: fixed.length),
        );
      }
      // Chặn > 100
      final number = int.tryParse(part);
      if (number != null && number > 100) return oldValue;
    }

    return newValue;
  }
}
