import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Generic picker row: optional leading, title, subtitle, trailing text and a
/// check mark when [selected]. `disabledReason` greys the row out.
class UiListRow extends StatelessWidget {
  const UiListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailingText,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.disabledReason,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? trailingText;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    final disabled = disabledReason != null;

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: UITap(
        onTap: disabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const UISpace.horz(14)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.listTitle,
                    ),
                    if (subtitle != null || disabled)
                      Text(
                        disabled ? disabledReason! : subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.caption,
                      ),
                  ],
                ),
              ),
              const UISpace.horz(12),
              if (trailing != null)
                trailing!
              else if (trailingText != null)
                Text(
                  trailingText!,
                  style: typo.listTitle,
                ),
              if (selected) ...[
                const UISpace.horz(10),
                UIIcon(UIIconToken.icons.general.check, size: 20, color: UIColorToken.blue),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
