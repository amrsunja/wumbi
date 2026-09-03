import 'package:flutter/material.dart';

import '../../app_ui.dart';

/// 1 px hairline; `colors.dividerColor` (casper 30 % light / #191524 dark)
/// unless [color] is given.
class UIDivider extends StatelessWidget {
  const UIDivider({super.key, this.indent = 0, this.color});

  final double indent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Divider(height: 1, thickness: 1, indent: indent, color: color ?? colors.dividerColor);
  }
}
