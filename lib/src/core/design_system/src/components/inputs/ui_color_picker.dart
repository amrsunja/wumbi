import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// 5 × 24 px rounded squares (radius 6); selected = 2 px blue ring with 3 px gap.
class UiColorPicker<T> extends StatelessWidget {
  const UiColorPicker({
    super.key,
    required this.options,
    required this.colorOf,
    required this.selected,
    required this.onSelect,
  });

  final List<T> options;
  final Color Function(T option) colorOf;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        for (final option in options)
          UITap(
            onTap: () => onSelect(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(theme.borders.swatchRadius + 4),
                border: Border.all(
                  color: option == selected ? UIColorToken.blue : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorOf(option),
                  borderRadius: BorderRadius.circular(theme.borders.swatchRadius),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
