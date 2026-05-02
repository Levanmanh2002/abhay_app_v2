import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalendarConfigUtil {
  static CalendarDatePicker2WithActionButtonsConfig getDefaultConfig(
    BuildContext context, {
    bool singleMode = false,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final dayTextStyle = StyleThemeData.size14Weight400();
    return CalendarDatePicker2WithActionButtonsConfig(
      calendarViewScrollPhysics: const NeverScrollableScrollPhysics(),
      dayTextStyle: dayTextStyle,
      calendarType: singleMode ? CalendarDatePicker2Type.single : CalendarDatePicker2Type.range,
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
        // if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        //   textStyle = StyleThemeData.size14Weight400(
        //     color: appTheme.grayColor,
        //   );
        // }
        return textStyle;
      },
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  static Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? minAllowedTime,
    Size? dialogSize,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final selectedDate = await showCalendarDatePicker2Dialog(
      context: context,
      config: getDefaultConfig(
        context,
        singleMode: true,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      dialogSize: dialogSize ?? Size(Get.width, Get.width),
      borderRadius: BorderRadius.circular(15),
      value: [initialDate],
      dialogBackgroundColor: appTheme.whiteColor,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate[0];

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(minAllowedTime ?? initialDate),
      initialEntryMode: TimePickerEntryMode.dialOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: appTheme.appColor, onPrimary: appTheme.whiteColor),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: appTheme.appColor),
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime == null || selectedDate.isEmpty
        ? null
        : DateTime(
            selectedDate[0]!.year,
            selectedDate[0]!.month,
            selectedDate[0]!.day,
            selectedTime.hour,
            selectedTime.minute,
          );
  }
}
