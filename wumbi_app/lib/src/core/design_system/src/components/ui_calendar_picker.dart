import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../app_ui.dart';

/// Single-date month calendar (Syncfusion) styled with the app tokens.
class UICalendarPicker extends StatelessWidget {
  const UICalendarPicker({
    super.key,
    this.initialDate,
    this.minDate,
    this.maxDate,
    this.specialDates,
    required this.onChanged,
  });

  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<DateTime>? specialDates;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final typo = theme.typo.inter;
    final bgColor = colors.fgColor;

    return SfDateRangePicker(
      backgroundColor: bgColor,
      todayHighlightColor: UIColorToken.blue,
      view: DateRangePickerView.month,
      headerHeight: 56,
      showNavigationArrow: true,
      selectionMode: DateRangePickerSelectionMode.single,
      initialSelectedDate: initialDate,
      initialDisplayDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
      onSelectionChanged: (args) {
        final value = args.value;
        if (value is DateTime) onChanged(value);
      },
      headerStyle: DateRangePickerHeaderStyle(
        backgroundColor: bgColor,
        textAlign: TextAlign.center,
        textStyle: typo.rowTitle,
      ),
      yearCellStyle: DateRangePickerYearCellStyle(
        todayTextStyle: typo.bold.copyWith(color: UIColorToken.blue),
        textStyle: typo.medium,
        disabledDatesTextStyle: typo.medium.copyWith(color: colors.disabledContentColor),
      ),
      monthViewSettings: DateRangePickerMonthViewSettings(
        specialDates: specialDates,
        viewHeaderStyle: DateRangePickerViewHeaderStyle(
          textStyle: typo.captionBold,
        ),
      ),
      monthCellStyle: DateRangePickerMonthCellStyle(
        disabledDatesTextStyle: typo.medium.copyWith(color: colors.disabledContentColor),
        todayTextStyle: typo.bold.copyWith(color: UIColorToken.blue, fontSize: 14),
        todayCellDecoration: BoxDecoration(
          border: Border.all(color: UIColorToken.blue),
          shape: BoxShape.circle,
        ),
        textStyle: typo.labelMedium,
      ),
      selectionColor: UIColorToken.blue,
      selectionTextStyle: typo.bold.copyWith(color: UIColorToken.white, fontSize: 14),
    );
  }
}
