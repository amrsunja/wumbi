import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/progress_stats.dart';
import '../progress_labels.dart';

enum ProgressHistorySeries { saved, income, spent }

/// One bar per period for a single series (saved / income / spent), the
/// viewed period solid and the others muted, with a dashed average rule.
/// Saved can go below zero: overspent periods hang under the axis in the
/// expense colour. Tapping a bar opens that period.
class ProgressHistoryChart extends StatelessWidget {
  const ProgressHistoryChart({
    super.key,
    required this.report,
    required this.series,
    required this.onSelect,
  });

  final ProgressReport report;
  final ProgressHistorySeries series;
  final ValueChanged<DateTime> onSelect;

  static const double _height = 170;

  int _value(ProgressPeriod p) => switch (series) {
        ProgressHistorySeries.saved => p.net.minor,
        ProgressHistorySeries.income => p.income.minor,
        ProgressHistorySeries.spent => p.expense.minor,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final r = report;
    final g = r.granularity;
    final periods = r.history;
    final unit = math.pow(10, r.currency.scale).toDouble();
    final values = [for (final p in periods) _value(p) / unit];

    final avgTotals = r.historyAverage();
    final avg = avgTotals == null
        ? null
        : switch (series) {
            ProgressHistorySeries.saved => avgTotals.net.minor / unit,
            ProgressHistorySeries.income => avgTotals.income.minor / unit,
            ProgressHistorySeries.spent => avgTotals.expense.minor / unit,
          };

    final top = math.max(values.fold<double>(0, math.max), avg ?? 0);
    final bottom = math.min(values.fold<double>(0, math.min), avg ?? 0);
    final span = math.max(top - bottom, 1.0);
    final maxY = top <= 0 ? 0.0 : top + span * 0.12;
    final minY = bottom >= 0 ? 0.0 : bottom - span * 0.12;

    Color colorOf(double v) => switch (series) {
          ProgressHistorySeries.income => UIColorToken.blue,
          ProgressHistorySeries.spent => colors.expenseColor,
          ProgressHistorySeries.saved => v < 0 ? colors.expenseColor : UIColorToken.blue,
        };

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final column = constraints.maxWidth / math.max(periods.length, 1);
          final rodWidth = (column * 0.5).clamp(6.0, 22.0);

          return BarChart(
            BarChartData(
              minY: minY,
              maxY: maxY == minY ? 1 : maxY,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),
              // Only the zero rule (as an extra line: the grid skips minY)
              // and the average; every other figure is in the tooltip.
              gridData: const FlGridData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(y: 0, color: colors.dividerColor, strokeWidth: 1),
                  if (avg != null && avg != 0)
                    HorizontalLine(
                      y: avg,
                      color: colors.secondContentColor,
                      strokeWidth: 1,
                      dashArray: const [4, 4],
                    ),
                ],
              ),
              barGroups: [
                for (var i = 0; i < periods.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        fromY: 0,
                        toY: values[i],
                        width: rodWidth,
                        color: periods[i].start == r.viewed
                            ? colorOf(values[i])
                            : colorOf(values[i]).withValues(alpha: colors.isDark ? 0.3 : 0.22),
                        borderRadius: values[i] < 0
                            ? const BorderRadius.vertical(bottom: Radius.circular(4))
                            : const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (i < 0 || i >= periods.length) return const SizedBox.shrink();
                      final viewed = periods[i].start == r.viewed;
                      final label = ProgressLabels.periodShort(g, periods[i].start);
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          // 12 months on a phone: first letter only for the others.
                          g == ProgressGranularity.month && column < 30 && !viewed ? label.characters.first : label,
                          style: typo.caption.copyWith(
                            fontSize: 11,
                            color: viewed ? colors.contentColor : colors.secondContentColor,
                            fontWeight: viewed ? FontWeight.w700 : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) return;
                  final i = response?.spot?.touchedBarGroupIndex;
                  if (i == null || i < 0 || i >= periods.length) return;
                  if (periods[i].start == r.viewed) return;
                  AppVibrations.selection();
                  onSelect(periods[i].start);
                },
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(10),
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tooltipMargin: 6,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (_) => colors.contentColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    if (groupIndex < 0 || groupIndex >= periods.length) return null;
                    final p = periods[groupIndex];
                    final money = Money(_value(p), r.currency);
                    return BarTooltipItem(
                      '${ProgressLabels.period(g, p.start)}\n'
                      '${money.format(signed: series == ProgressHistorySeries.saved, positiveSign: series == ProgressHistorySeries.saved)}',
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
}
