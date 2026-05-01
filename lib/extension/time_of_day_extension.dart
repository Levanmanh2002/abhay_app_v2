import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  String get toFormattedHHmmss {
    final now = DateTime.now();
    final formattedTime = DateTime(now.year, now.month, now.day, hour, minute);

    return "${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}:${formattedTime.second.toString().padLeft(2, '0')}";
  }

  String get to24hString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

extension TimeOfDayExtensions on TimeOfDay? {
  String get toTimeFormat {
    if (this == null) return '--:--';
    return '${this!.hour.toString().padLeft(2, '0')}:${this!.minute.toString().padLeft(2, '0')}';
  }
}

extension StringToTimeOfDay on String {
  TimeOfDay get toHmTimeOfDay {
    final parts = split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  }

  TimeOfDay get toTimeOfDay {
    final s = trim();
    if (s.contains(RegExp(r'(AM|PM)$', caseSensitive: false))) {
      // "11:15 PM"
      final parts = s.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      if (parts[1].toUpperCase() == 'PM' && hour < 12) hour += 12;
      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      // "23:15"
      final timeParts = s.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }
  }
}
