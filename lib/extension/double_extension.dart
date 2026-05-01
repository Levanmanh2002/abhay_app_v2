import 'dart:math' as math;

extension DoubleFormatter on double {
  String get percentFormat {
    return this % 1 == 0 ? '${toInt()}%' : '${toStringAsFixed(1)}%';
  }

  String get toTrimmedString {
    return (this % 1 == 0) ? toInt().toString() : toStringAsFixed(2);
  }

  String get toCleanString {
    if (this == truncateToDouble()) {
      return toInt().toString();
    }
    return toString();
  }
}

extension NullableDoubleFormattingExtension on double? {
  String toThousandSeparatorFormat({int fractionDigits = 0}) {
    if (this == null) return '';

    final value = this!;
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

  String get formatWorkingTime {
    if (this == null || this == 0) return '--';

    final totalMinutes = (this! * 60).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
