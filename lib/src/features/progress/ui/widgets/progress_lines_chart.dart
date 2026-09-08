import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/progress_stats.dart';

/// Income and expense as two curved lines over the same periods as the bars.
///
/// Same semantic pair as everywhere else in the app: income is
/// [UIColorToken.blue] and expense is `colors.expenseColor` — near-black on
/// the light theme, near-white on the dark one, so the "black" line stays
/// visible instead of disappearing into the panel.
class ProgressLinesChart extends StatelessWidget {
  const ProgressLinesChart({super.key, required this.stats});

  final ProgressStats stats;

  static const double _height = 170;

  /// fl_chart identifies a touched spot by its bar index, and both the
  /// tooltip and the dot painter need to know which series it came from.
  static const int _incomeBar = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final unit = math.pow(10, stats.currency.scale).toDouble();
    final lastIndex = stats.periods.length - 1;

    const incomeColor = UIColorToken.blue;
    final expenseColor = colors.expenseColor;

    // Both series are positive magnitudes, so the axis starts at zero and the
    // tallest of the two sets the ceiling (15 % headroom).
    final peak = math.max(stats.peakMinor / unit, 1.0);
    final maxY = peak * 1.15;

    LineChartBarData line(Color color, int Function(ProgressPeriod) value) =>
        LineChartBarData(
          spots: [
            for (var i = 0; i < stats.periods.length; i++)
              FlSpot(i.toDouble(), value(stats.periods[i]) / unit),
          ],
          isCurved: true,
          curveSmoothness: 0.28,
          preventCurveOverShooting: true,
          barWidth: 2.5,
          isStrokeCapRound: true,
          isStrokeJoinRound: true,
          color: color,
          dotData: FlDotData(
            // Only the running period keeps a dot, so the lines stay calm.
            checkToShowDot: (spot, _) => spot.x.round() == lastIndex,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: colors.fgColor,
              strokeWidth: 2.5,
              strokeColor: color,
            ),
          ),
          belowBarData: BarAreaData(show: false),
        );

    return SizedBox(
      height: _height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: lastIndex.toDouble(),
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          // Three dashed rules instead of a filled area: with two lines any
          // wash under them would muddy where they cross.
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.dividerColor,
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                interval: 1,
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
                        color: isCurrent ? incomeColor : colors.secondContentColor,
                        fontWeight: isCurrent ? FontWeight.w700 : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Income first: that is what makes it bar index [_incomeBar].
          lineBarsData: [
            line(incomeColor, (p) => p.income.minor),
            line(expenseColor, (p) => p.expense.minor),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              tooltipMargin: 6,
              maxContentWidth: 160,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => colors.contentColor,
              // One row per series, so a touch reads both values at once.
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    _row(spot, l10n.progress_income, l10n.progress_expense),
                    typo.captionBold.copyWith(color: colors.bgColor),
                  ),
              ],
            ),
            getTouchedSpotIndicator: (bar, indexes) => indexes
                .map(
                  (_) => TouchedSpotIndicatorData(
                    FlLine(color: colors.dividerColor, strokeWidth: 1),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: colors.fgColor,
                        strokeWidth: 2.5,
                        strokeColor: barData.color ?? incomeColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// `Income   $600.00` — the period itself is already named by the axis
  /// label under the touch indicator, so it is not repeated here.
  String _row(LineBarSpot spot, String incomeLabel, String expenseLabel) {
    final index = spot.x.round();
    if (index < 0 || index >= stats.periods.length) return '';
    final period = stats.periods[index];
    final isIncome = spot.barIndex == _incomeBar;
    final money = isIncome ? period.income : period.expense;
    return '${isIncome ? incomeLabel : expenseLabel}   ${money.format()}';
  }
}
