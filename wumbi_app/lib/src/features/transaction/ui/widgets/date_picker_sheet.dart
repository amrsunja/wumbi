import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/app_vibrations.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';

/// `UICalendarPicker` (Syncfusion) inside a sheet. Min 2000-01-01 (or
/// [minDate]), max today + 5 years (or [maxDate]) — future days are allowed so
/// a transaction can be scheduled as *upcoming*. No buttons: tapping a day
/// picks it and closes the sheet; dismissing it keeps the current date.
abstract class DatePickerSheet {
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initial,
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<DateTime>(
      context: context,
      title: l10n.date_pick_title,
      height: 0.62,
      child: _DatePickerBody(initial: initial, minDate: minDate, maxDate: maxDate),
    );
  }
}

class _DatePickerBody extends StatefulWidget {
  const _DatePickerBody({required this.initial, this.minDate, this.maxDate});

  final DateTime initial;
  final DateTime? minDate;
  final DateTime? maxDate;

  @override
  State<_DatePickerBody> createState() => _DatePickerBodyState();
}

class _DatePickerBodyState extends State<_DatePickerBody> {
  bool _closing = false;

  /// Tap a day → it highlights → the sheet closes with it.
  Future<void> _pick(DateTime date) async {
    if (_closing) return;
    _closing = true;
    AppVibrations.selection();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (mounted) Navigator.of(context).pop(date);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: UICalendarPicker(
        initialDate: widget.initial,
        minDate: widget.minDate ?? DateTime(2000, 1, 1),
        maxDate: widget.maxDate ?? DateTime(now.year + 5, now.month, now.day),
        onChanged: _pick,
      ),
    );
  }
}
