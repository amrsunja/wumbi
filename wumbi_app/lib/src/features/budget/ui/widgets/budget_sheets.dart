import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/enums/budget_period_type.dart';
import '../../../../core/utils/enums/rollover_mode.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../budget_labels.dart';

/// Radio sheet helper shared by the budget pickers below.
Future<T?> _radioSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) label,
  String? Function(T)? description,
}) =>
    UIModalSheet.modalSheet<T>(
      context: context,
      title: title,
      fitContent: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options) ...[
              UiRadioRow(
                label: label(o),
                description: description?.call(o),
                selected: o == selected,
                onTap: () => Navigator.of(context).pop(o),
              ),
              if (o != options.last) const UIDivider(),
            ],
          ],
        ),
      ),
    );

/// Weekly / Monthly / Yearly / One-time.
abstract class BudgetPeriodSheet {
  static Future<BudgetPeriodType?> show(BuildContext context, {required BudgetPeriodType selected}) {
    final l10n = context.l10n;
    return _radioSheet(
      context,
      title: l10n.budget_repeats,
      options: BudgetPeriodType.values,
      selected: selected,
      label: (t) => BudgetLabels.periodType(l10n, t),
    );
  }
}

/// What happens to the leftover at the end of a period.
abstract class RolloverSheet {
  static Future<RolloverMode?> show(BuildContext context, {required RolloverMode selected}) {
    final l10n = context.l10n;
    return _radioSheet(
      context,
      title: l10n.budget_carry_over,
      options: RolloverMode.values,
      selected: selected,
      label: (m) => BudgetLabels.rollover(l10n, m),
      description: (m) => BudgetLabels.rolloverDescription(l10n, m),
    );
  }
}

/// Weekday a weekly budget starts on (`DateTime.monday` … `sunday`), names in
/// the app locale.
abstract class WeekdaySheet {
  static String name(int weekday) {
    // 2024-01-01 is a Monday.
    final day = DateTime(2024, 1, weekday);
    try {
      return DateFormat('EEEE', Intl.defaultLocale).format(day);
    } catch (_) {
      return DateFormat('EEEE', 'en_US').format(day);
    }
  }

  static Future<int?> show(BuildContext context, {required int selected}) => _radioSheet(
        context,
        title: context.l10n.budget_start_weekday_title,
        options: const [1, 2, 3, 4, 5, 6, 7],
        selected: selected,
        label: name,
      );
}

/// Day of the month (1–31) a monthly budget starts on — e.g. salary day.
/// Days a month does not have clamp to its last day.
abstract class MonthDaySheet {
  static Future<int?> show(BuildContext context, {required int selected}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<int>(
      context: context,
      title: l10n.budget_start_day_title,
      fitContent: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (var d = 1; d <= 31; d++) _DayCell(day: d, selected: d == selected),
              ],
            ),
            const UISpace.vert(8),
            Text(l10n.budget_start_day_hint, textAlign: TextAlign.center, style: context.typo.inter.caption),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.selected});

  final int day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return UITap(
      onTap: () => Navigator.of(context).pop(day),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? UIColorToken.blue : Colors.transparent,
        ),
        child: Text('$day', style: typo.label.copyWith(color: selected ? UIColorToken.white : null)),
      ),
    );
  }
}
