import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../app_ui.dart';

/// Single-date month calendar (Syncfusion) styled with the app tokens.
/// [onChanged] also fires when the already-selected day is tapped again, so a
/// pick-and-close sheet can treat that tap as "keep this date".
class UICalendarPicker extends StatefulWidget {
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
  State<UICalendarPicker> createState() => _UICalendarPickerState();
}

class _UICalendarPickerState extends State<UICalendarPicker> {
  late DateTime? _selected = widget.initialDate;

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
      initialSelectedDate: widget.initialDate,
      initialDisplayDate: widget.initialDate,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      // Re-tapping the selected day toggles it off (value == null) — report it
      // as a re-pick of that day instead of a deselection.
      toggleDaySelection: true,
      onSelectionChanged: (args) {
        final value = args.value;
        if (value is DateTime) {
          _selected = value;
          widget.onChanged(value);
        } else if (value == null && _selected != null) {
          widget.onChanged(_selected!);
        }
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
        specialDates: widget.specialDates,
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
