import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../progress_labels.dart';

/// One donut slice: a tag family, "Other" or "Untagged".
class ProgressSlice {
  const ProgressSlice({required this.label, required this.minor, required this.share, required this.color});

  final String label;
  final int minor;

  /// Of the period's total (rows show the same figure).
  final double share;
  final Color color;
}

/// Where the money went, at a glance: shades of one colour (expense or
/// income), biggest first. The centre names one slice — the biggest until
/// another is tapped — so the donut never repeats the rows under it.
class ProgressDonut extends StatefulWidget {
  const ProgressDonut({super.key, required this.slices});

  final List<ProgressSlice> slices;

  /// Shades for the top families, darkest = biggest. "Other" and "Untagged"
  /// use [otherColor] / [untaggedColor].
  static List<Color> shades(Color base) => [
        base,
        base.withValues(alpha: 0.72),
        base.withValues(alpha: 0.52),
        base.withValues(alpha: 0.36),
        base.withValues(alpha: 0.24),
      ];

  static Color otherColor(Color base) => base.withValues(alpha: 0.14);
  static Color untaggedColor(UIColorToken colors) => colors.secondContentColor.withValues(alpha: 0.45);

  @override
  State<ProgressDonut> createState() => _ProgressDonutState();
}

class _ProgressDonutState extends State<ProgressDonut> {
  int _selected = 0;

  @override
  void didUpdateWidget(ProgressDonut old) {
    super.didUpdateWidget(old);
    if (_selected >= widget.slices.length) _selected = 0;
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    final slices = widget.slices;
    if (slices.isEmpty) return const SizedBox.shrink();
    final s = slices[_selected.clamp(0, slices.length - 1)];

    return SizedBox(
      height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 2,
              centerSpaceRadius: 56,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event is! FlTapUpEvent) return;
                  final i = response?.touchedSection?.touchedSectionIndex ?? -1;
                  if (i < 0 || i >= slices.length || i == _selected) return;
                  AppVibrations.selection();
                  setState(() => _selected = i);
                },
              ),
              sections: [
                for (var i = 0; i < slices.length; i++)
                  PieChartSectionData(
                    value: slices[i].minor.toDouble(),
                    color: slices[i].color,
                    radius: i == _selected ? 24 : 18,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          // Centre: the selected slice's share and name.
          SizedBox(
            width: 96,
            child: AnimatedSwitcher(
              duration: UIAnim.fast,
              child: Column(
                key: ValueKey(s.label),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ProgressLabels.percent(s.share), style: typo.headline),
                  Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: typo.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
