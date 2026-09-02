import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Radio-style row for the Repeat picker.
class UiRadioRow extends StatelessWidget {
  const UiRadioRow({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
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
              child: Text(
                label,
                style: UITextStyleToken.interMedium.copyWith(fontSize: 16, color: colors.contentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
