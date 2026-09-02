import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/enums/repeat_frequency.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import 'repeat_labels.dart';

/// 5 radio rows: Never, Every day, Every week, Every month, Every year.
abstract class RepeatPickerSheet {
  static Future<RepeatFrequency?> show(BuildContext context, {required RepeatFrequency selected}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<RepeatFrequency>(
      context: context,
      title: l10n.transaction_repeat,
      fitContent: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in RepeatFrequency.values) ...[
              UiRadioRow(
                label: repeatLongLabel(l10n, f),
                selected: f == selected,
                onTap: () => Navigator.of(context).pop(f),
              ),
              if (f != RepeatFrequency.values.last) const UIDivider(),
            ],
          ],
        ),
      ),
    );
  }
}
