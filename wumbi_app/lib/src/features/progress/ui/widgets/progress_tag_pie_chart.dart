import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../tag/ui/tag_palette.dart';
import '../../data/models/progress_stats.dart';

/// Where the running period's spending went, by tag: a donut plus a legend.
///
/// Tag colours come from [TagPalette], the same lookup the tag map uses, so a
/// tag keeps its swatch across screens. "Untagged" and "Other" fall back to
/// casper, which stays legible in both themes.
class ProgressTagPieChart extends HookWidget {
  const ProgressTagPieChart({
    super.key,
    required this.stats,
    required this.onTagTap,
  });

  final ProgressStats stats;

  /// Called with a tag id when a real tag slice (or its legend row) is tapped.
  final ValueChanged<String> onTagTap;

  static const double _size = 150;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final slices = stats.expenseByTag;
    // The pie double-counts a transaction carrying two tags, so shares are a
    // fraction of the pie's own total, never of the period's expense.
    final total = stats.taggedExpenseMinor;
    final touched = useState(-1);

    void handleTap(int index) {
      if (index < 0 || index >= slices.length) return;
      final slice = slices[index];
      if (slice.kind != TagSliceKind.tag || slice.tagId == null) return;
      AppVibrations.light();
      onTagTap(slice.tagId!);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 34,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final index = response?.touchedSection?.touchedSectionIndex ?? -1;
                      touched.value = event.isInterestedForInteractions ? index : -1;
                      if (event is FlTapUpEvent) handleTap(index);
                    },
                  ),
                  sections: [
                    for (var i = 0; i < slices.length; i++)
                      _section(context, slices[i], total, expanded: touched.value == i),
                  ],
                ),
              ),
              // The donut hole carries the period's own expense, which is the
              // honest total even when the slices overlap.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    stats.current.expense.format(),
                    style: context.typo.inter.captionBold.copyWith(color: colors.contentColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        const UISpace.horz(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              for (var i = 0; i < slices.length; i++)
                _LegendRow(
                  slice: slices[i],
                  color: colorOf(slices[i]),
                  share: total == 0 ? 0.0 : slices[i].amount.minor / total,
                  onTap: slices[i].kind == TagSliceKind.tag ? () => handleTap(i) : null,
                ),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _section(
    BuildContext context,
    TagSlice slice,
    int total, {
    required bool expanded,
  }) {
    final color = colorOf(slice);
    final share = total == 0 ? 0.0 : slice.amount.minor / total;
    // Below ~9 % the printed share no longer fits inside the ring.
    final showTitle = share >= 0.09;
    return PieChartSectionData(
      value: slice.amount.minor.toDouble(),
      color: color,
      radius: expanded ? 40 : 34,
      showTitle: showTitle,
      title: '${(share * 100).round()}%',
      titleStyle: context.typo.inter.micro.copyWith(
        color: color.computeLuminance() > 0.5 ? UIColorToken.neu700 : UIColorToken.white,
      ),
    );
  }

  /// Casper carries the two non-tag buckets: readable on both themes
  /// without borrowing a swatch a real tag could also get.
  static Color colorOf(TagSlice slice) => switch (slice.kind) {
        TagSliceKind.tag => TagPalette.of(slice.normalizedName),
        TagSliceKind.untagged => UIColorToken.casper,
        TagSliceKind.other => UIColorToken.casper.withValues(alpha: 0.5),
      };
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.slice,
    required this.color,
    required this.share,
    required this.onTap,
  });

  final TagSlice slice;
  final Color color;
  final double share;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;

    final label = switch (slice.kind) {
      TagSliceKind.tag => '#${slice.label}',
      TagSliceKind.untagged => l10n.progress_untagged,
      TagSliceKind.other => l10n.progress_other_tags,
    };

    return UITap(
      onTap: onTap,
      child: Row(
        spacing: 8,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.caption.copyWith(color: colors.contentColor),
            ),
          ),
          Text('${(share * 100).round()}%', style: typo.caption),
        ],
      ),
    );
  }
}
