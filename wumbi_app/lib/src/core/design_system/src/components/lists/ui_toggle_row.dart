import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Title + short explanation on the left, switch vertically centred on the
/// right; the whole row toggles. A changing [description] cross-fades.
class UiToggleRow extends StatelessWidget {
  const UiToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    final description = this.description;
    return UITap(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: padding,
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Text(title, style: typo.label),
                  if (description != null)
                    AnimatedSize(
                      duration: UIAnim.fast,
                      alignment: AlignmentDirectional.topStart,
                      child: AnimatedSwitcher(
                        duration: UIAnim.fast,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: AlignmentDirectional.topStart,
                          children: [...previous, ?current],
                        ),
                        child: Text(description, key: ValueKey(description), style: typo.caption),
                      ),
                    ),
                ],
              ),
            ),
            UISwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
