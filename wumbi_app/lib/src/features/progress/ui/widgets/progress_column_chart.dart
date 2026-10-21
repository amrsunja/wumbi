import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../progress_labels.dart';

/// Thin rounded columns, one per slot (day of the month, month of the year,
/// weekday). The highlighted column (the peak by default) is solid in
/// [color] with its amount on top; the rest are the same colour, muted —
/// the Progress page's single bar style (history bars use it too).
/// Long-press a column for its exact amount.
class ProgressColumnChart extends StatelessWidget {
  const ProgressColumnChart({
    super.key,
    required this.values,
    required this.currency,
    required this.label,
    this.showLabel,
    this.tooltip,
    this.highlight,
    this.color,
    this.height = 88,
  });

  /// Minor amounts; null = slot not reached yet (drawn as a faint stub).
  final List<int?> values;
  final CurrencyType currency;

  /// Axis label of slot `i`.
  final String Function(int i) label;

  /// Which slots get an axis label (default: all).
  final bool Function(int i)? showLabel;

  /// Tooltip title of slot `i` (default: [label]).
  final String Function(int i)? tooltip;

  /// Solid column; default the peak.
  final int? highlight;

  /// Default: the expense colour.
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final base = color ?? colors.expenseColor;
    final muted = base.withValues(alpha: colors.isDark ? 0.3 : 0.22);
    final peak = values.fold<int>(0, (m, v) => math.max(m, v ?? 0));
    var peakIndex = -1;
    for (var i = 0; i < values.length; i++) {
      if ((values[i] ?? 0) == peak && peak > 0) {
        peakIndex = i;
        break;
      }
    }
    final solid = highlight ?? peakIndex;
    final unit = math.pow(10, currency.scale).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final column = constraints.maxWidth / math.max(values.length, 1);
        final barWidth = (column * 0.55).clamp(3.0, 14.0);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Amount over the solid column; may overflow its slot.
                    SizedBox(
                      height: 16,
                      child: i == solid && (values[i] ?? 0) > 0
                          ? OverflowBox(
                              maxWidth: 80,
                              child: Text(
                                ProgressLabels.compact(values[i]! / unit, currency),
                                maxLines: 1,
                                style: typo.captionBold.copyWith(color: colors.contentColor),
                              ),
                            )
                          : null,
                    ),
                    const UISpace.vert(4),
                    SizedBox(
                      height: height,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Tooltip(
                          message: values[i] == null
                              ? (tooltip ?? label)(i)
                              : '${(tooltip ?? label)(i)}\n${Money(values[i]!, currency).format()}',
                          textAlign: TextAlign.center,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: peak == 0 ? 0 : (values[i] ?? 0) / peak),
                            duration: UIAnim.normal,
                            curve: UIAnim.easeOut,
                            builder: (context, v, _) => Container(
                              width: barWidth,
                              // A 3 px stub keeps an empty slot visible.
                              height: math.max(height * v, 3),
                              decoration: BoxDecoration(
                                color: values[i] == null
                                    ? colors.dividerColor
                                    : (i == solid ? base : muted),
                                borderRadius: BorderRadius.circular(math.min(4.0, barWidth / 2)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const UISpace.vert(6),
                    SizedBox(
                      height: 14,
                      child: (showLabel?.call(i) ?? true)
                          ? OverflowBox(
                              maxWidth: 48,
                              child: Text(
                                label(i),
                                maxLines: 1,
                                style: typo.caption.copyWith(
                                  fontSize: 11,
                                  height: 1.2,
                                  color: i == solid ? colors.contentColor : colors.secondContentColor,
                                  fontWeight: i == solid ? FontWeight.w700 : null,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
