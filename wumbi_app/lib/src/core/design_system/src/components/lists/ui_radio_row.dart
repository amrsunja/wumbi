import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Radio-style row for the Repeat picker. An optional [description] explains
/// the option in a caption under the label.
class UiRadioRow extends StatelessWidget {
  const UiRadioRow({super.key, required this.label, required this.selected, required this.onTap, this.description});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    final typo = AppTheme.of(context).typo.inter;
    final description = this.description;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          crossAxisAlignment: description == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? UIColorToken.blue : colors.secondContentColor,
                  width: selected ? 6 : 1.5,
                ),
              ),
            ),
            const UISpace.horz(14),
            Expanded(
              child: description == null
                  ? Text(label, style: typo.body)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(label, style: typo.body),
                        Text(description, style: typo.caption.copyWith(height: 1.35)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
