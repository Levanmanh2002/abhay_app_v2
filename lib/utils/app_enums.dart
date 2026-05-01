import 'dart:ui';

import 'package:abhay_app_v2/gen/assets.gen.dart';
import 'package:get/get.dart';

extension LanguageExtension on Languages {
  String get title {
    switch (this) {
      case Languages.vi:
        return 'vietnamese'.tr;
      case Languages.en:
        return 'english'.tr;
    }
  }

  Locale get locale {
    switch (this) {
      case Languages.vi:
        return const Locale('vi', 'VN');
      case Languages.en:
        return const Locale('en', 'US');
    }
  }

  String get flagAsset {
    switch (this) {
      case Languages.vi:
        return Assets.icons.vietnam.path;
      case Languages.en:
        return Assets.icons.english.path;
    }
  }

  Languages get opposite {
    switch (this) {
      case Languages.vi:
        return Languages.en;
      case Languages.en:
        return Languages.vi;
    }
  }
}

enum Languages {
  vi,
  en,
}

enum StatChangeType { up, down }

enum TimeFilter { today, week, thisMonth }

extension TimeFilterX on TimeFilter {
  String get title {
    switch (this) {
      case TimeFilter.today:
        return 'today'.tr;
      case TimeFilter.week:
        return 'this_week'.tr;
      case TimeFilter.thisMonth:
        return 'this_month'.tr;
    }
  }
}

enum WeekDay {
  // monday,
  // tuesday,
  // wednesday,
  // thursday,
  // friday,
  // saturday,
  // sunday,
  sunday, // 0
  monday, // 1
  tuesday, // 2
  wednesday, // 3
  thursday, // 4
  friday, // 5
  saturday, // 6
}

extension WeekDayX on WeekDay {
  String get title {
    switch (this) {
      case WeekDay.monday:
        return 'monday'.tr;
      case WeekDay.tuesday:
        return 'tuesday'.tr;
      case WeekDay.wednesday:
        return 'wednesday'.tr;
      case WeekDay.thursday:
        return 'thursday'.tr;
      case WeekDay.friday:
        return 'friday'.tr;
      case WeekDay.saturday:
        return 'saturday'.tr;
      case WeekDay.sunday:
        return 'sunday'.tr;
    }
  }
}

enum ReportRangeType {
  day,
  week,
  // month,
}

extension ReportRangeTypeX on ReportRangeType {
  String get title {
    switch (this) {
      case ReportRangeType.day:
        return 'day'.tr;
      case ReportRangeType.week:
        return 'week'.tr;
      // case ReportRangeType.month:
      //   return 'month'.tr;
    }
  }
}
