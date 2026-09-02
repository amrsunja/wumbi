import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// Mascot-driven empty state.
class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    required this.image,
    required this.title,
    this.subtitle,
    this.action,
  });

  /// Asset path (e.g. `Assets.images.fiinOo.path`).
  final String image;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image, height: 110),
            const UISpace.vert(20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: UITextStyleToken.interSemiBold.copyWith(fontSize: 16, color: colors.contentColor),
            ),
            if (subtitle != null) ...[
              const UISpace.vert(6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: UITextStyleToken.interMedium.copyWith(fontSize: 13, color: colors.secondContentColor),
              ),
            ],
            if (action != null) ...[const UISpace.vert(16), action!],
          ],
        ),
      ),
    );
  }
}
