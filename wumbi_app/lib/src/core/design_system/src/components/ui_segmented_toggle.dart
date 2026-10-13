import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// Small text pill toggle: the active option is blue with a 2 px underline,
/// the other one casper. No Material `SegmentedButton`. (Moved from the tags
/// feature so the Debts page can share it.)
///
/// [expanded]: every option takes an equal share of the available width (the
/// whole cell is tappable) — the Dashboard tab bar.
class UiSegmentedToggle extends StatelessWidget {
  const UiSegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.expanded = false,
    this.dots = const [],
    this.counts = const [],
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool expanded;

  /// Per-option 6 px red dot after the label (e.g. an overdue debt). Shorter
  /// than [labels] = no dot for the remaining options.
  final List<bool> dots;

  /// Per-option item count after the label ("Budgets 2"); null / 0 = none.
  /// Shorter than [labels] = no count for the remaining options.
  final List<int?> counts;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final typo = theme.typo.inter;

    Widget option(int i) {
      final selected = i == selectedIndex;
      final dot = i < dots.length && dots[i];
      //final count = i < counts.length ? counts[i] : null;
      final label = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: typo.medium.copyWith(
          color: selected ? UIColorToken.blue : colors.secondContentColor,
        ),
        child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis),
      );
      return UITap(
        onTap: () => onChanged(i),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 3,
                children: [
                  // Flexible only under a bounded width (expanded cells); the
                  // compact toggle sits in an unbounded Row.
                  if (expanded) Flexible(child: label) else label,
                  if (dot)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: UIColorToken.neg500, shape: BoxShape.circle),
                    ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: selected ? 22 : 0,
                height: 2,
                decoration: BoxDecoration(
                  color: UIColorToken.blue,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: expanded ? 0 : 8,
      children: [
        for (var i = 0; i < labels.length; i++) expanded ? Expanded(child: option(i)) : option(i),
      ],
    );
  }
}
