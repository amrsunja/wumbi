import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/enums/repeat_frequency.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import 'repeat_labels.dart';

/// 5 radio rows: Never, Every day, Every week, Every month, Every year.
/// `excludeNever` drops the first one — a subscription always repeats.
abstract class RepeatPickerSheet {
  static Future<RepeatFrequency?> show(
    BuildContext context, {
    required RepeatFrequency selected,
    bool excludeNever = false,
    String? title,
  }) {
    final l10n = context.l10n;
    final options = excludeNever
        ? RepeatFrequency.values.where((f) => !f.isNever).toList()
        : RepeatFrequency.values.toList();
    return UIModalSheet.modalSheet<RepeatFrequency>(
      context: context,
      title: title ?? l10n.transaction_repeat,
      fitContent: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in options) ...[
              UiRadioRow(
                label: repeatLongLabel(l10n, f),
                selected: f == selected,
                onTap: () => Navigator.of(context).pop(f),
              ),
              if (f != options.last) const UIDivider(),
            ],
          ],
        ),
      ),
    );
  }
}
