import 'package:flutter/services.dart';

class LeadingZeroBlockFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Nếu nhập > 1 ký tự và bắt đầu bằng 0 → bỏ số 0 đầu
    if (text.length > 1 && text.startsWith('0')) {
      text = text.replaceFirst('0', '');
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
