import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// Group header inside a transaction list: uppercase overline label with a
/// hairline filling the rest of the row (`SEPTEMBER ───────`), optionally a
/// caption under it (the upcoming hint).
class MonthDivider extends StatelessWidget {
  const MonthDivider({super.key, required this.label, this.caption});

  final String label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo.inter;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label.toUpperCase(), style: typo.overline),
              const UISpace.horz(12),
              const Expanded(child: UIDivider()),
            ],
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(caption!, style: typo.caption, textAlign: TextAlign.start),
            ),
        ],
      ),
    );
  }
}
