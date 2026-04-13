import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../app_ui.dart';

class UICalendarPicker extends HookWidget {
  const UICalendarPicker({
    super.key,
    this.submitTitle,
    this.cancelTitle,
    this.selectRange = false,
    this.initialDate,
    this.initialStartDate,
    this.initialEndDate,
    this.specialDates,
    required this.onSubmit,
    required this.onCancel
  });

  final String? submitTitle;
  final String? cancelTitle;
  final bool selectRange;
  final DateTime? initialDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<DateTime>? specialDates;
  final Function(DateTime? selectedDate, DateTime? startDate, DateTime? endDate) onSubmit;
  final Function(BuildContext context) onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bgColor = theme.colors.fgColor;

    final selectedDate = useState<DateTime?>(initialDate);
    final startDate = useState<DateTime?>(initialStartDate);
    final endDate = useState<DateTime?>(initialEndDate);


    return Column(
      mainAxisAlignment: .spaceBetween,
      children: [
        SfDateRangePicker(
          backgroundColor: bgColor,
          todayHighlightColor: theme.colors.contentColor,
          view: .month,
          headerHeight: 80,
          showNavigationArrow: true,
          selectionMode: selectRange ?  .range : .single,
          initialSelectedDate: initialDate,
          initialSelectedRange: PickerDateRange(initialStartDate, initialEndDate),
          selectableDayPredicate: (date) {
            return date.isBefore(DateTime.now());
          },
          onSelectionChanged: (arg) {
            if (arg.value.runtimeType == DateTime) {
              selectedDate.value = arg.value;
            } else if (arg.value.runtimeType == PickerDateRange) {
              final value = arg.value as PickerDateRange;
              startDate.value = value.startDate;
              endDate.value = value.endDate;
            }
          },
          headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: bgColor,
            textAlign: .center,
            textStyle: UITextStyleToken.interBold.copyWith(
              color: theme.colors.contentColor,
              fontSize: 18
            )
          ),
          yearCellStyle: DateRangePickerYearCellStyle(
            todayTextStyle: UITextStyleToken.interBold.copyWith(
              color: theme.colors.contentColor,
            ),
            textStyle: UITextStyleToken.interMedium.copyWith(
              color: theme.colors.contentColor,
            ),
          ),
          monthViewSettings: DateRangePickerMonthViewSettings(
            specialDates: specialDates,
            viewHeaderStyle: DateRangePickerViewHeaderStyle(
              textStyle: UITextStyleToken.interSemiBold.copyWith(
                color: Color(0xff9CA3AF),
                fontSize: 12
              )
            )
          ),
          monthCellStyle: DateRangePickerMonthCellStyle(
            disabledDatesTextStyle: UITextStyleToken.interMedium.copyWith(
              color: theme.colors.disabledContentColor
            ),
            specialDatesTextStyle: UITextStyleToken.interMedium.copyWith(
              color: UIColorToken.pos500
            ),
            specialDatesDecoration: BoxDecoration(
              color: UIColorToken.pos200.withValues(alpha: 0.8),
              shape: .circle
            ),
            todayTextStyle: UITextStyleToken.interBold.copyWith(
              color: UIColorToken.blue,
              fontSize: 14
            ),
            todayCellDecoration: BoxDecoration(
              border: .all(color: UIColorToken.blue),
              shape: .circle
            ),
            textStyle: UITextStyleToken.interMedium.copyWith(
              color: theme.colors.contentColor,
              fontSize: 14
            ),
          ),
          startRangeSelectionColor: UIColorToken.blue,
          endRangeSelectionColor: UIColorToken.blue,
          rangeSelectionColor: UIColorToken.bismark.withValues(alpha: 0.4),
          selectionColor: UIColorToken.blue,
          rangeTextStyle: UITextStyleToken.interMedium.copyWith(
            color: theme.colors.contentColor,
            fontSize: 14
          ),
          selectionTextStyle: UITextStyleToken.interBold.copyWith(
            color: UIColorToken.white,
            fontSize: 14
          ),
        ),
      ],
    );
  }
}
