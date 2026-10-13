import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/tag_stats.dart';
import '../../data/tag_normalizer.dart';

/// `#food/coffee` pill in the app's tag style (blue tint, like the chips
/// under a transaction). [selected] = solid outline for pickers.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.path, this.selected = false, this.trailing});

  final String path;
  final bool selected;

  /// Extra text after the name (an amount on the tag page).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: UIColorToken.blue.withValues(alpha: selected ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? UIColorToken.blue : Colors.transparent, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '#$path',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.semiBold.copyWith(fontSize: 13, color: UIColorToken.blue),
            ),
          ),
          if (trailing != null) ...[const UISpace.horz(8), trailing!],
        ],
      ),
    );
  }
}

/// `food/` dimmed + `coffee` strong — a nested tag's full path on one line.
class TagPathText extends StatelessWidget {
  const TagPathText({
    super.key,
    required this.path,
    required this.style,
    this.showHash = true,
    this.showParents = true,
  });

  final String path;
  final TextStyle style;
  final bool showHash;

  /// False → only the last level (`coffee`).
  final bool showParents;

  @override
  Widget build(BuildContext context) {
    final leaf = TagNormalizer.leaf(path);
    final parent = TagNormalizer.parentOf(path);
    final hash = showHash ? '#' : '';
    return Text.rich(
      TextSpan(
        children: [
          if (showParents && parent != null)
            TextSpan(
              text: '$hash$parent${TagNormalizer.separator}',
              style: style.copyWith(color: context.colors.secondContentColor, fontWeight: FontWeight.w500),
            ),
          TextSpan(text: showParents && parent != null ? leaf : '$hash$leaf'),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Thin bar: how much money this tag moved compared to [relativeTo] (its
/// family's top-level tag; 1.0 = same), split into spending (expense colour)
/// and income (blue).
class TagFlowBar extends StatelessWidget {
  const TagFlowBar({super.key, required this.stats, this.relativeTo, this.height = 4});

  final TagStats stats;
  final TagStats? relativeTo;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final volume = stats.volumeMinor;
    final whole = math.max(relativeTo?.volumeMinor ?? volume, 1);
    final share = volume <= 0 ? 0.0 : (volume / whole).clamp(0.04, 1.0).toDouble();
    final expenseShare = volume <= 0 ? 0.0 : stats.expense.minor / volume;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * share;
        final radius = BorderRadius.circular(height);
        return Container(
          height: height,
          decoration: BoxDecoration(color: colors.dividerColor.withValues(alpha: 0.5), borderRadius: radius),
          alignment: AlignmentDirectional.centerStart,
          child: ClipRRect(
            borderRadius: radius,
            child: SizedBox(
              width: width,
              height: height,
              child: Row(
                children: [
                  if (expenseShare > 0)
                    Expanded(
                      flex: math.max((expenseShare * 1000).round(), 1),
                      child: ColoredBox(color: colors.expenseColor.withValues(alpha: colors.isDark ? 0.85 : 0.75)),
                    ),
                  if (expenseShare < 1)
                    Expanded(
                      flex: math.max(((1 - expenseShare) * 1000).round(), 1),
                      child: const ColoredBox(color: UIColorToken.blue),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small neutral count pill ("3 nested") — same look as the badge on a
/// transaction row.
class TagCountPill extends StatelessWidget {
  const TagCountPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.secondContentColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        style: context.typo.inter.micro.copyWith(fontSize: 9, color: colors.secondContentColor),
      ),
    );
  }
}

/// Expense on the main line, income below in blue; an income-only tag shows
/// the earned amount on the main line instead of a meaningless "-0.00".
class TagAmounts extends StatelessWidget {
  const TagAmounts({super.key, required this.stats, this.compact = false});

  final TagStats stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;
    final hasExpense = stats.expense.minor > 0;
    final hasIncome = stats.income.minor > 0;
    final main = compact ? typo.listTitle : typo.rowTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        if (hasExpense || !hasIncome)
          Text('-${stats.expense.format()}', maxLines: 1, style: main.copyWith(color: colors.expenseColor)),
        if (hasIncome)
          Text(
            '+${stats.income.format()}',
            maxLines: 1,
            style: (hasExpense ? typo.captionBold : main).copyWith(color: UIColorToken.blue),
          ),
      ],
    );
  }
}
