import 'package:flutter/services.dart';

class MaxMoneyInputFormatter extends TextInputFormatter {
  final double maxValue;

  MaxMoneyInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');

    if (raw.isEmpty) return newValue;

    final value = double.tryParse(raw);
    if (value == null) return oldValue;

    if (value > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}
