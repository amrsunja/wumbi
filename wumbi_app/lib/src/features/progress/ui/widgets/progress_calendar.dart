import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../data/models/progress_stats.dart';
import '../progress_labels.dart';

/// Spending calendar of the viewed period: a month grid of days (Month tab)
/// or 12 months (Year tab). Each slot is a circle filled with the expense
/// colour — the more spent, the stronger — with the compact amount inside.
/// Slots still ahead are empty outlines. Tap a slot: its date and exact
/// amount show under the grid (today / the running month by default, else
/// the biggest slot).
class ProgressCalendar extends StatefulWidget {
  const ProgressCalendar({super.key, required this.report});

  final ProgressReport report;

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  int? _selected;

  ProgressReport get _r => widget.report;
  bool get _month => _r.granularity == ProgressGranularity.month;

  /// Spending per slot (minor), null for slots not reached yet.
  List<int?> get _values {
    final cum = _r.paceCurrent;
    return [
      for (var i = 0; i < _r.totalSlots; i++)
        if (i >= cum.length) null else cum[i] - (i == 0 ? 0 : cum[i - 1]),
    ];
  }

  DateTime _dateOf(int i) =>
      _month ? DateTime(_r.viewed.year, _r.viewed.month, i + 1) : DateTime(_r.viewed.year, i + 1);

  @override
  void didUpdateWidget(ProgressCalendar old) {
    super.didUpdateWidget(old);
    // Another period / scope: back to the default slot.
    if (old.report.viewed != _r.viewed || old.report.granularity != _r.granularity) _selected = null;
  }

  int _defaultSlot(List<int?> values) {
    if (_r.isCurrent && _r.paceCurrent.isNotEmpty) return _r.paceCurrent.length - 1;
    var best = 0;
    for (var i = 0; i < values.length; i++) {
      if ((values[i] ?? 0) > (values[best] ?? 0)) best = i;
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final values = _values;
    final peak = values.fold<int>(0, (m, v) => math.max(m, v ?? 0));
    final selected = (_selected ?? _defaultSlot(values)).clamp(0, values.length - 1);
    final today = _r.isCurrent ? _r.paceCurrent.length - 1 : -1;

    // Month: weekday columns starting on the locale's first day.
    final firstDay = (MaterialLocalizations.of(context).firstDayOfWeekIndex + 6) % 7; // 0 = Monday
    final lead = _month ? (_dateOf(0).weekday - 1 - firstDay + 7) % 7 : 0;
    final columns = _month ? 7 : 4;

    final selectedValue = values[selected];
    final selectedDate = _dateOf(selected);
    final selectedLabel = _month
        ? _capitalized('${ProgressLabels.weekday(selectedDate.weekday - 1)} ${selectedDate.formatShortDate()}')
        : _capitalized(ProgressLabels.period(_r.granularity, selectedDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_month) ...[
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Text(
                    ProgressLabels.weekday((firstDay + c) % 7, short: true),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: typo.caption.copyWith(fontSize: 11),
                  ),
                ),
            ],
          ),
          const UISpace.vert(8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final cellWidth = constraints.maxWidth / columns;
            final circle = _month ? math.min(cellWidth - 6, 40.0) : math.min(cellWidth - 18, 58.0);
            final cells = lead + values.length;
            final rows = (cells / columns).ceil();

            Widget cell(int i) {
              final v = values[i];
              final future = v == null;
              final strength = peak == 0 || v == null || v == 0 ? 0.0 : v / peak;
              final fill = future
                  ? Colors.transparent
                  : v == 0
                      ? colors.secondContentColor.withValues(alpha: 0.08)
                      : colors.expenseColor.withValues(alpha: 0.12 + 0.88 * strength);
              final onFill = strength > 0.5 ? colors.bgColor : colors.contentColor;
              final isSelected = i == selected;
              final label = _month ? '${i + 1}' : ProgressLabels.periodShort(_r.granularity, _dateOf(i));

              return UITap(
                onTap: future
                    ? null
                    : () {
                        if (i == _selected) return;
                        AppVibrations.selection();
                        setState(() => _selected = i);
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Selection ring sits outside the circle.
                      AnimatedContainer(
                        duration: UIAnim.fast,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? colors.contentColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: fill),
                          duration: UIAnim.normal,
                          curve: UIAnim.easeOut,
                          builder: (context, color, child) => Container(
                            width: circle,
                            height: circle,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: future ? Border.all(color: colors.dividerColor) : null,
                            ),
                            child: child,
                          ),
                          child: v == null || v == 0
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      ProgressLabels.compact(v / math.pow(10, _r.currency.scale), _r.currency),
                                      maxLines: 1,
                                      style: typo.captionBold.copyWith(
                                        fontSize: _month ? 9 : 11,
                                        color: onFill,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const UISpace.vert(3),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: typo.caption.copyWith(
                          fontSize: 11,
                          color: i == today || isSelected ? colors.contentColor : colors.secondContentColor,
                          fontWeight: i == today ? FontWeight.w700 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (var row = 0; row < rows; row++)
                  Row(
                    children: [
                      for (var col = 0; col < columns; col++)
                        Expanded(
                          child: () {
                            final i = row * columns + col - lead;
                            return i < 0 || i >= values.length ? const SizedBox.shrink() : cell(i);
                          }(),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
        const UISpace.vert(12),
        const UIDivider(),
        const UISpace.vert(12),
        // The tapped slot, exact.
        AnimatedSwitcher(
          duration: UIAnim.fast,
          child: Row(
            key: ValueKey(selected),
            children: [
              Expanded(child: Text(selectedLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.body)),
              const UISpace.horz(12),
              Text(
                Money(selectedValue ?? 0, _r.currency).format(),
                style: typo.rowTitle.copyWith(
                  color: (selectedValue ?? 0) == 0 ? colors.secondContentColor : colors.expenseColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _capitalized(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
