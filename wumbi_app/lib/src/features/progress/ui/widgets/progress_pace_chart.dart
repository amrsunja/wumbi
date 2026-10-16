import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/progress_stats.dart';
import '../progress_labels.dart';

/// Cumulative spending through the viewed period (solid, expense colour)
/// over the comparison's curve (dashed, casper), plus a faint dashed
/// projection to the forecast while the period is running.
///
/// One series is the user's money, the other only a reference — so the
/// reference stays recessive and never competes with the solid line.
class ProgressPaceChart extends StatelessWidget {
  const ProgressPaceChart({super.key, required this.report, required this.baselineLabel});

  final ProgressReport report;
  final String baselineLabel;

  static const double _height = 180;
  static const int _currentBar = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final r = report;
    final g = r.granularity;
    final unit = math.pow(10, r.currency.scale).toDouble();
    final slots = r.totalSlots;
    final lastX = (slots - 1).toDouble();
    final current = r.paceCurrent;
    final base = r.paceBaseline;
    final forecast = r.forecast;
    final lineColor = colors.expenseColor;
    final refColor = colors.secondContentColor;

    final peakMinor = [
      if (current.isNotEmpty) current.last,
      if (base != null && base.isNotEmpty) base.last,
      ?forecast?.minor,
    ].fold<int>(0, math.max);
    final maxY = math.max(peakMinor / unit, 1.0) * 1.12;
    final step = ProgressLabels.niceStep(maxY / 3);

    FlSpot spot(int i, int minor) => FlSpot(i.toDouble(), minor / unit);

    final bars = <LineChartBarData>[
      LineChartBarData(
        spots: [for (var i = 0; i < current.length; i++) spot(i, current[i])],
        isCurved: true,
        curveSmoothness: 0.2,
        preventCurveOverShooting: true,
        barWidth: 2.5,
        isStrokeCapRound: true,
        color: lineColor,
        dotData: FlDotData(
          // Only "today" (or the period's end) keeps a dot.
          checkToShowDot: (s, _) => s.x.round() == current.length - 1,
          getDotPainter: (s, p, b, i) => FlDotCirclePainter(
            radius: 4,
            color: colors.bgColor,
            strokeWidth: 2.5,
            strokeColor: lineColor,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lineColor.withValues(alpha: 0.08), lineColor.withValues(alpha: 0)],
          ),
        ),
      ),
      if (base != null)
        LineChartBarData(
          spots: [for (var i = 0; i < base.length; i++) spot(i, base[i])],
          isCurved: true,
          curveSmoothness: 0.2,
          preventCurveOverShooting: true,
          barWidth: 2,
          color: refColor,
          dashArray: const [5, 4],
          dotData: const FlDotData(show: false),
        ),
      if (forecast != null && current.isNotEmpty)
        LineChartBarData(
          spots: [spot(current.length - 1, current.last), FlSpot(lastX, forecast.minor / unit)],
          barWidth: 1.5,
          color: lineColor.withValues(alpha: 0.35),
          dashArray: const [2, 4],
          dotData: FlDotData(
            checkToShowDot: (s, _) => s.x == lastX,
            getDotPainter: (s, p, b, i) => FlDotCirclePainter(
              radius: 3,
              color: colors.bgColor,
              strokeWidth: 1.5,
              strokeColor: lineColor.withValues(alpha: 0.5),
            ),
          ),
        ),
    ];

    String slotLabel(int i) => switch (g) {
          ProgressGranularity.month => l10n.progress_day(i + 1),
          ProgressGranularity.year => ProgressLabels.periodShort(g, DateTime(r.viewed.year, i + 1)),
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _height,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: lastX,
              minY: 0,
              maxY: maxY,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: step,
                getDrawingHorizontalLine: (_) => FlLine(color: colors.dividerColor, strokeWidth: 1, dashArray: const [4, 4]),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    interval: step,
                    // Only the rounded steps: an odd maxY label would collide.
                    minIncluded: false,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) {
                      if (value <= 0 || value > maxY) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(ProgressLabels.compact(value, r.currency), style: typo.caption),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.round();
                      if (value != i.toDouble() || i < 0 || i >= slots) return const SizedBox.shrink();
                      // Month: 1 · 8 · 15 · 22 · 29. Year: Jan · Apr · Jul · Oct.
                      final show = g == ProgressGranularity.month ? i % 7 == 0 : i % 3 == 0;
                      if (!show) return const SizedBox.shrink();
                      return SideTitleWidget(
                        meta: meta,
                        space: 6,
                        child: Text(
                          g == ProgressGranularity.month ? '${i + 1}' : slotLabel(i),
                          style: typo.caption,
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: bars,
              lineTouchData: LineTouchData(
                touchSpotThreshold: 24,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(10),
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tooltipMargin: 8,
                  maxContentWidth: 200,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (_) => colors.contentColor,
                  getTooltipItems: (spots) {
                    final style = typo.captionBold.copyWith(color: colors.bgColor);
                    // Bars past the reference (the forecast segment) get no row.
                    final lastBar = base == null ? _currentBar : _currentBar + 1;
                    final items = <LineTooltipItem?>[];
                    var headed = false;
                    for (final s in spots) {
                      if (s.barIndex > lastBar) {
                        items.add(null);
                        continue;
                      }
                      final money = Money((s.y * unit).round(), r.currency).format();
                      final name = s.barIndex == _currentBar ? ProgressLabels.periodShort(g, r.viewed) : baselineLabel;
                      // The slot ("Day 14") heads the first row only.
                      final head = headed ? '' : '${slotLabel(s.x.round())}\n';
                      headed = true;
                      items.add(LineTooltipItem('$head$name   $money', style));
                    }
                    return items;
                  },
                ),
                getTouchedSpotIndicator: (bar, indexes) => [
                  for (final _ in indexes)
                    TouchedSpotIndicatorData(
                      FlLine(color: colors.dividerColor, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                          radius: 4,
                          color: colors.bgColor,
                          strokeWidth: 2.5,
                          strokeColor: b.color ?? lineColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const UISpace.vert(10),
        // Legend: two series → always a key, the reference drawn dashed.
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _LegendLine(color: lineColor, label: ProgressLabels.period(g, r.viewed)),
            if (base != null) _LegendLine(color: refColor, label: baselineLabel, dashed: true),
          ],
        ),
      ],
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.color, required this.label, this.dashed = false});

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        SizedBox(
          width: 16,
          height: 2,
          child: dashed
              ? Row(
                  spacing: 2,
                  children: [for (var i = 0; i < 3; i++) Expanded(child: ColoredBox(color: color))],
                )
              : ColoredBox(color: color),
        ),
        Text(label, style: context.typo.inter.caption),
      ],
    );
  }
}
