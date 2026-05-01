import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

class CalendarConfigUtil {
  static CalendarDatePicker2WithActionButtonsConfig getDefaultConfig() {
    final dayTextStyle = StyleThemeData.size14Weight400();
    return CalendarDatePicker2WithActionButtonsConfig(
      calendarViewScrollPhysics: const NeverScrollableScrollPhysics(),
      dayTextStyle: dayTextStyle,
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: appTheme.appColor,
      closeDialogOnCancelTapped: true,
      firstDayOfWeek: 1,
      weekdayLabelTextStyle: StyleThemeData.size14Weight700(),
      controlsTextStyle: StyleThemeData.size14Weight400(),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox.shrink(),
      selectedDayTextStyle: dayTextStyle.copyWith(color: appTheme.whiteColor),
      dayTextStylePredicate: ({required date}) {
        TextStyle? textStyle;
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          textStyle = StyleThemeData.size14Weight400(
            color: appTheme.grayColor,
          );
        }
        return textStyle;
      },
    );
  }
}
