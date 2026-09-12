import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/progress_stats.dart';

/// Grouped income / expense bars, one column per period, oldest → newest.
///
/// Every colour comes from [UIColorToken] / the active [AppThemeData]:
/// income is `blue`, expense is the theme's `expenseColor` (the same pair the
/// amount rows use), and each rod sits in a faint `dividerColor` track so the
/// column keeps its shape while a period is still empty.
class ProgressBarChart extends StatelessWidget {
  const ProgressBarChart({super.key, required this.stats});

  final ProgressStats stats;

  /// Chart body height (labels excluded).
  static const double _height = 190;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final currency = stats.currency;
    final unit = math.pow(10, currency.scale).toDouble();

    // 18 % headroom so the tallest rod never touches the top edge. The `1`
    // floor keeps the axis valid while every period is still empty.
    final peak = stats.peakMinor / unit;
    final maxY = peak <= 0 ? 1.0 : peak * 1.18;

    const incomeColor = UIColorToken.blue;
    final expenseColor = colors.expenseColor;
    final trackColor = colors.dividerColor.withValues(alpha: 0.45);
    final lastIndex = stats.periods.length - 1;

    LinearGradient rodGradient(Color color) => LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color, color.withValues(alpha: 0.55)],
        );

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Two rods + their spacing have to fit the column the chart gives
          // each group; 7–15 px keeps them readable on a narrow phone.
          final columnWidth = constraints.maxWidth / math.max(stats.periods.length, 1);
          final rodWidth = ((columnWidth - 22) / 2).clamp(7.0, 15.0);

          BarChartRodData rod(int minor, Color color) => BarChartRodData(
                toY: minor / unit,
                width: rodWidth,
                gradient: rodGradient(color),
                borderRadius: BorderRadius.circular(rodWidth / 2),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: trackColor,
                ),
              );

          return BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              barGroups: [
                for (var i = 0; i < stats.periods.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      rod(stats.periods[i].income.minor, incomeColor),
                      rod(stats.periods[i].expense.minor, expenseColor),
                    ],
                  ),
              ],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= stats.periods.length) {
                        return const SizedBox.shrink();
                      }
                      final isCurrent = index == lastIndex;
                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          stats.labelOf(stats.periods[index]),
                          style: typo.caption.copyWith(
                            color: isCurrent ? UIColorToken.blue : colors.secondContentColor,
                            fontWeight: isCurrent ? FontWeight.w700 : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(10),
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tooltipMargin: 6,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (_) => colors.contentColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < 0 || groupIndex >= stats.periods.length) return null;
                    final period = stats.periods[groupIndex];
                    final money = rodIndex == 0 ? period.income : period.expense;
                    if (money.isZero) return null;
                    return BarTooltipItem(
                      _tooltipText(stats, period, money),
                      typo.captionBold.copyWith(color: colors.bgColor),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _tooltipText(ProgressStats stats, ProgressPeriod period, Money money) =>
      '${stats.labelOf(period)}\n${money.format()}';
}
