import 'package:abhay_app_v2/main.dart';
import 'package:abhay_app_v2/theme/style/style_theme.dart';
import 'package:abhay_app_v2/widget/reponsive/extension.dart';
import 'package:abhay_app_v2/widget/scroll_date/scroll_number.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrollDateView extends StatefulWidget {
  final DateTime? date;
  final void Function(DateTime)? onChanged;

  const ScrollDateView({
    super.key,
    this.date,
    this.onChanged,
  });

  @override
  State<ScrollDateView> createState() => _ScrollDateViewState();
}

class _ScrollDateViewState extends State<ScrollDateView> {
  final ValueNotifier<int> _day = ValueNotifier(1);
  final ValueNotifier<int> _month = ValueNotifier(1);
  final ValueNotifier<int> _maxDay = ValueNotifier(31);

  DateTime get _date => DateTime(DateTime.now().year, _month.value, _day.value);

  @override
  void initState() {
    if (widget.date != null) {
      _day.value = widget.date!.day;
      _month.value = widget.date!.month;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              spacing: 12.h,
              children: [
                Text('month'.tr, style: StyleThemeData.size12Weight700(color: appTheme.gray5BColor)),
                ValueListenableBuilder<int>(
                  valueListenable: _month,
                  builder: (context, value, _) {
                    return ScrollNumber(
                      minValue: 1,
                      maxValue: 12,
                      value: value,
                      infiniteLoop: true,
                      selectedTextStyle: StyleThemeData.size20Weight700(color: appTheme.gray5BColor),
                      textStyle: StyleThemeData.size14Weight400(color: appTheme.gray5BColor),
                      onChanged: (int newValue) {
                        _month.value = newValue;
                        int maxDays = _getMaxDaysInMonth(newValue, DateTime.now().year);
                        _maxDay.value = maxDays;

                        if (_day.value > maxDays) {
                          _day.value = maxDays;
                        }

                        widget.onChanged?.call(_date);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              spacing: 12.h,
              children: [
                Text('day'.tr, style: StyleThemeData.size12Weight700(color: appTheme.gray5BColor)),
                ValueListenableBuilder<int>(
                  valueListenable: _day,
                  builder: (context, value, _) {
                    return ScrollNumber(
                      minValue: 1,
                      maxValue: _maxDay.value,
                      value: value,
                      infiniteLoop: true,
                      selectedTextStyle: StyleThemeData.size20Weight700(color: appTheme.gray5BColor),
                      textStyle: StyleThemeData.size14Weight400(color: appTheme.gray5BColor),
                      onChanged: (int newValue) {
                        _day.value = newValue;
                        widget.onChanged?.call(_date);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getMaxDaysInMonth(int month, int year) {
    if (month == 2) {
      // nam nhuan
      if (year % 4 == 0 || year % 400 == 0) {
        return 29;
      }
      return 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    return 31;
  }
}
