import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Uppercase 11 px casper label with tracking 1.2 (settings sections).
class UiSectionLabel extends StatelessWidget {
  const UiSectionLabel({super.key, required this.text, this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8)});

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Padding(
      padding: padding,
      child: Text(text.toUpperCase(), style: UITextStyleToken.sectionLabel(colors)),
    );
  }
}
