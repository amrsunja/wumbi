import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/progress_stats.dart';
import '../progress_labels.dart';

/// "Compare with" — the presets (previous, same month last year, average)
/// then any single month / year up to the running one.
abstract class ProgressBaselineSheet {
  static Future<ProgressBaseline?> show(
    BuildContext context, {
    required ProgressGranularity granularity,
    required DateTime viewed,
    required ProgressBaseline selected,
  }) {
    final l10n = context.l10n;
    final g = granularity;
    final now = g.startOf(DateTime.now());
    final month = g == ProgressGranularity.month;

    final presets = <(ProgressBaseline, String, String)>[
      (
        const ProgressBaseline.previous(),
        month ? l10n.progress_baseline_previous_month : l10n.progress_baseline_previous_year,
        ProgressLabels.period(g, g.shift(viewed, -1)),
      ),
      if (month)
        (
          const ProgressBaseline.lastYear(),
          l10n.progress_baseline_last_year,
          ProgressLabels.period(g, g.shift(viewed, -12)),
        ),
      (
        const ProgressBaseline.average(),
        month
            ? l10n.progress_baseline_average_months(ProgressBaseline.averageSpan)
            : l10n.progress_baseline_average_years(ProgressBaseline.averageSpan),
        '${ProgressLabels.period(g, g.shift(viewed, -ProgressBaseline.averageSpan))} – '
            '${ProgressLabels.period(g, g.shift(viewed, -1))}',
      ),
    ];

    // Newest first, the viewed period itself left out.
    final picks = [
      for (var i = 0; i < g.pickerLength; i++)
        if (g.shift(now, -i) != viewed) g.shift(now, -i),
    ];

    return UIModalSheet.modalSheet<ProgressBaseline>(
      context: context,
      title: l10n.progress_compare_title,
      height: 0.75,
      // The sheet's own context pops the sheet, never the page behind it.
      child: Builder(
        builder: (context) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (var i = 0; i < presets.length; i++) ...[
              if (i > 0) const UIDivider(),
              UiListRow(
                title: presets[i].$2,
                subtitle: presets[i].$3,
                selected: selected == presets[i].$1,
                onTap: () => Navigator.of(context).pop(presets[i].$1),
              ),
            ],
            UiSectionLabel(
              text: month ? l10n.progress_baseline_pick_month : l10n.progress_baseline_pick_year,
              padding: const EdgeInsets.fromLTRB(4, 24, 4, 4),
            ),
            for (var i = 0; i < picks.length; i++) ...[
              if (i > 0) const UIDivider(),
              UiListRow(
                title: ProgressLabels.period(g, picks[i]),
                selected: selected.kind == ProgressBaselineKind.custom && selected.start == picks[i],
                onTap: () => Navigator.of(context).pop(ProgressBaseline.custom(picks[i])),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
