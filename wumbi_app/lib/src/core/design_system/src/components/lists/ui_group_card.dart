import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Grouped card: rows separated by hairlines on a tinted surface (budget and
/// debt details: stats, settings, history).
class UiGroupCard extends StatelessWidget {
  const UiGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.secondContentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const UIDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Plain 64 px row, no box and no icon: optional leading widget, label,
/// optional trailing value, chevron when tappable.
class UiValueRow extends StatelessWidget {
  const UiValueRow({
    super.key,
    required this.label,
    this.value,
    this.valueColor,
    this.leading,
    this.onTap,
  });

  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    return UITap(
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const UISpace.horz(12)],
            Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.body)),
            const UISpace.horz(12),
            // Value and chevron pinned to the row's right edge.
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (value != null)
                      Flexible(
                        child: Text(
                          value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: typo.subtitle.copyWith(color: valueColor),
                        ),
                      ),
                    if (onTap != null) ...[
                      const UISpace.horz(6),
                      UIIcon(UIIconToken.icons.arrows.chevronRight, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
