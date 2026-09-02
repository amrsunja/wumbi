import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// `UICalendarPicker` (Syncfusion) inside a sheet. Min 2000-01-01, max today + 1 year.
abstract class DatePickerSheet {
  static Future<DateTime?> show(BuildContext context, {required DateTime initial}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<DateTime>(
      context: context,
      title: l10n.date_pick_title,
      height: 0.62,
      child: _DatePickerBody(initial: initial),
    );
  }
}

class _DatePickerBody extends StatefulWidget {
  const _DatePickerBody({required this.initial});

  final DateTime initial;

  @override
  State<_DatePickerBody> createState() => _DatePickerBodyState();
}

class _DatePickerBodyState extends State<_DatePickerBody> {
  late DateTime _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    return Column(
      children: [
        Expanded(
          child: UICalendarPicker(
            initialDate: widget.initial,
            minDate: DateTime(2000, 1, 1),
            maxDate: DateTime(now.year + 1, now.month, now.day),
            onChanged: (date) => setState(() => _selected = date),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: UiTextButton(
                  label: l10n.common_today,
                  style: UiTextButtonStyle.secondary,
                  fontSize: 16,
                  onTap: () => Navigator.of(context).pop(DateTime(now.year, now.month, now.day)),
                ),
              ),
              Expanded(
                flex: 2,
                child: UiPrimaryButton(
                  label: l10n.common_confirm,
                  onTap: () => Navigator.of(context).pop(_selected),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
