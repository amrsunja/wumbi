import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Grid of 34 px rounded swatches (radius 6), [perRow] per line; selected =
/// 2 px blue ring with 3 px gap.
class UiColorPicker<T> extends StatelessWidget {
  const UiColorPicker({
    super.key,
    required this.options,
    required this.colorOf,
    required this.selected,
    required this.onSelect,
    this.perRow = 5,
    this.spacing = 16,
  });

  final List<T> options;
  final Color Function(T option) colorOf;
  final T selected;
  final ValueChanged<T> onSelect;
  final int perRow;
  final double spacing;

  static const double swatchSize = 34;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final rows = <List<T>>[];
    for (var i = 0; i < options.length; i += perRow) {
      rows.add(options.sublist(i, i + perRow > options.length ? options.length : i + perRow));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing * 0.75,
      children: [
        for (final row in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: spacing,
            children: [
              for (final option in row)
                UITap(
                  onTap: () => onSelect(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: swatchSize,
                    height: swatchSize,
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
              // Keep the last row left-aligned with the grid when it is short.
              for (var i = row.length; i < perRow; i++) const SizedBox(width: swatchSize, height: swatchSize),
            ],
          ),
      ],
    );
  }
}
