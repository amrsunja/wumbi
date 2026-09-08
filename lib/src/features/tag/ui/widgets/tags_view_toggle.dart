import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Small text pill toggle: the active option is blue with a 2 px underline,
/// the other one casper. No Material `SegmentedButton`.
class TagsViewToggle extends StatelessWidget {
  const TagsViewToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo.inter;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          UITap(
            onTap: () => onChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: typo.label.copyWith(
                      color: i == selectedIndex ? UIColorToken.blue : colors.secondContentColor,
                    ),
                    child: Text(labels[i]),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: i == selectedIndex ? 22 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: UIColorToken.blue,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
