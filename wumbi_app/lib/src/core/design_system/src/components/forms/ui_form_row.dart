import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// One line of a simple form (Wallet, Debt, Budget): label on the left, value
/// on the right, chevron when tappable. 48 px tall.
class UiFormRow extends StatelessWidget {
  const UiFormRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.onTap,
    this.muted = false,
  });

  final String label;

  /// Shown on the right (ignored when [valueWidget] is set).
  final String? value;

  /// Custom right side (replaces [value] and the chevron).
  final Widget? valueWidget;
  final VoidCallback? onTap;

  /// Secondary colour for placeholder values ("None", "Add a note").
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final typo = theme.typo.inter;
    final colors = theme.colors;
    final trailing = valueWidget ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: typo.subtitle.copyWith(color: muted ? colors.secondContentColor : null),
              ),
            ),
            if (onTap != null) ...[
              const UISpace.horz(6),
              UIIcon(UIIconToken.icons.arrows.chevronRight, size: 18),
            ],
          ],
        );
    return UITap(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Expanded(child: Text(label, style: typo.body)),
            const UISpace.horz(12),
            Flexible(child: Align(alignment: Alignment.centerRight, child: trailing)),
          ],
        ),
      ),
    );
  }
}
