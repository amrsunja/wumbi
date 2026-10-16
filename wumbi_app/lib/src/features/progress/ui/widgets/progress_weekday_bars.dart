import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../progress_labels.dart';

/// Seven thin columns — average spending per weekday. The priciest day is
/// solid with its amount on top; the rest stay muted. Starts on the
/// locale's first day of the week.
class ProgressWeekdayBars extends StatelessWidget {
  const ProgressWeekdayBars({super.key, required this.averages, required this.currency});

  /// Monday-based minor amounts.
  final List<int> averages;
  final CurrencyType currency;

  static const double _barArea = 72;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final peak = averages.fold<int>(0, math.max);
    // MaterialLocalizations: 0 = Sunday. Ours: 0 = Monday.
    final first = (MaterialLocalizations.of(context).firstDayOfWeekIndex + 6) % 7;
    final order = [for (var i = 0; i < 7; i++) (first + i) % 7];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final day in order)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                  child: averages[day] == peak && peak > 0
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            ProgressLabels.compact(averages[day] / math.pow(10, currency.scale), currency),
                            style: typo.captionBold.copyWith(color: colors.contentColor),
                          ),
                        )
                      : null,
                ),
                const UISpace.vert(4),
                SizedBox(
                  height: _barArea,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Tooltip(
                      message: Money(averages[day], currency).format(),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: peak == 0 ? 0 : averages[day] / peak),
                        duration: UIAnim.normal,
                        curve: UIAnim.easeOut,
                        builder: (context, v, _) => Container(
                          width: 14,
                          // A 3 px stub keeps an empty day visible.
                          height: math.max(_barArea * v, 3),
                          decoration: BoxDecoration(
                            color: averages[day] == peak && peak > 0
                                ? colors.expenseColor
                                : colors.secondContentColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const UISpace.vert(6),
                Text(
                  ProgressLabels.weekday(day, short: true),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: typo.caption.copyWith(
                    fontSize: 11,
                    color: averages[day] == peak && peak > 0 ? colors.contentColor : colors.secondContentColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
