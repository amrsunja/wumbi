import 'package:flutter/material.dart';

import '../../../app_ui.dart';

/// `#food #work` pills under a row caption (transaction / subscription rows).
/// Renders nothing when [tags] is empty.
class UiTagChips extends StatelessWidget {
  const UiTagChips({super.key, required this.tags, this.color = UIColorToken.blue});

  final List<String> tags;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    final typo = AppTheme.of(context).typo.inter;
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final t in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('#$t', style: typo.semiBold.copyWith(fontSize: 10, color: color)),
          ),
      ],
    );
  }
}
