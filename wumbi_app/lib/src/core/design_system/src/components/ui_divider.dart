import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// 1 px hairline between list rows: `colors.dividerColor` (athens gray
/// #F3F4F6 light / #191524 dark) at [opacity], unless [color] is given, with
/// [spacing] of air above and below so the rows don't touch it.
///
/// Pass `spacing: 0` for a line that isn't a row separator — a month header
/// ([MonthDivider]) or a rule between sections.
class UIDivider extends StatelessWidget {
  const UIDivider({super.key, this.indent = 0, this.color, this.spacing = listSpacing});

  /// Default room above and below the line between list rows.
  static const double listSpacing = 4;

  /// How much of `colors.dividerColor` shows: a faint line, not a rule.
  static const double opacity = 0.8;

  final double indent;
  final Color? color;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Divider(
      height: 1 + spacing * 2,
      thickness: 1,
      indent: indent,
      color: color ?? colors.dividerColor.withValues(alpha: colors.dividerColor.a * opacity),
    );
  }
}
