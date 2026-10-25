import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Mascot-driven empty state.
class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    required this.mood,
    required this.title,
    this.subtitle,
    this.action,
  });

  final WumbiMood mood;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final typo = AppTheme.of(context).typo.inter;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UIWumbi(mood),
            const UISpace.vert(20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: typo.rowTitle,
            ),
            if (subtitle != null) ...[
              const UISpace.vert(6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: typo.hint,
              ),
            ],
            if (action != null) ...[const UISpace.vert(16), action!],
          ],
        ),
      ),
    );
  }
}
