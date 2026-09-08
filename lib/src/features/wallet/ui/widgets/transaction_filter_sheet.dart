import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/enums/transaction_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../tag/data/models/tag_model.dart';
import '../../../tag/data/tag_repository.dart';
import '../../../transaction/data/models/transaction_filter.dart';
import '../../../transaction/ui/widgets/date_picker_sheet.dart';

/// Filter sheet for a wallet's transaction list. Pops with the new
/// [TransactionFilter] on Apply, [TransactionFilter.none] on "Clear filters",
/// null when dismissed.
abstract class TransactionFilterSheet {
  static Future<TransactionFilter?> show(BuildContext context, {required TransactionFilter initial}) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<TransactionFilter>(
      context: context,
      title: l10n.wallet_filter_title,
      height: 0.85,
      child: _FilterBody(initial: initial),
    );
  }
}

/// Date presets; `custom` keeps whatever bounds the user picks by hand.
enum _DatePreset {
  any,
  thisMonth,
  lastMonth,
  last30Days,
  thisYear,
  custom;

  /// Inclusive day bounds of a preset, or null for [any] / [custom].
  ({DateTime from, DateTime to})? range(DateTime now) {
    final today = now.onlyDate();
    return switch (this) {
      _DatePreset.any || _DatePreset.custom => null,
      _DatePreset.thisMonth => (
          from: DateTime(today.year, today.month, 1),
          to: DateTime(today.year, today.month + 1, 0),
        ),
      _DatePreset.lastMonth => (
          from: DateTime(today.year, today.month - 1, 1),
          to: DateTime(today.year, today.month, 0),
        ),
      _DatePreset.last30Days => (from: today.subtract(const Duration(days: 29)), to: today),
      _DatePreset.thisYear => (from: DateTime(today.year, 1, 1), to: DateTime(today.year, 12, 31)),
    };
  }

  /// Which preset reproduces [filter]'s bounds (custom when none does).
  static _DatePreset of(TransactionFilter filter, DateTime now) {
    if (filter.from == null && filter.to == null) return _DatePreset.any;
    final from = filter.from?.onlyDate();
    final to = filter.to?.onlyDate();
    for (final preset in _DatePreset.values) {
      final r = preset.range(now);
      if (r != null && r.from == from && r.to == to) return preset;
    }
    return _DatePreset.custom;
  }
}

class _FilterBody extends HookConsumerWidget {
  const _FilterBody({required this.initial});

  final TransactionFilter initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;

    final filter = useState<TransactionFilter>(initial);
    final preset = useState<_DatePreset>(_DatePreset.of(initial, DateTime.now()));

    final tagsFuture = useMemoized(() => ref.read(tagRepositoryProvider).listAll());
    final tagsSnapshot = useFuture(tagsFuture);
    final List<TagModel>? tags = tagsSnapshot.hasData
        ? tagsSnapshot.data!.when((list) => list, (_) => const <TagModel>[])
        : null;

    void toggleType(TransactionType type) {
      final next = Set<TransactionType>.of(filter.value.types);
      if (!next.remove(type)) next.add(type);
      filter.value = filter.value.copyWith(types: next);
    }

    void toggleTag(String id) {
      final next = Set<String>.of(filter.value.tagIds);
      if (!next.remove(id)) next.add(id);
      filter.value = filter.value.copyWith(tagIds: next);
    }

    void selectPreset(_DatePreset p) {
      preset.value = p;
      final r = p.range(DateTime.now());
      if (r != null) {
        filter.value = filter.value.copyWith(from: r.from, to: r.to);
      } else if (p == _DatePreset.any) {
        filter.value = filter.value.copyWith(clearFrom: true, clearTo: true);
      }
      // custom: keep the current bounds, the user edits them below.
    }

    Future<void> pickFrom() async {
      final current = filter.value;
      final picked = await DatePickerSheet.show(context, initial: current.from ?? current.to ?? DateTime.now());
      if (picked == null) return;
      final from = picked.onlyDate();
      final to = current.to != null && current.to!.onlyDate().isBefore(from) ? from : current.to;
      filter.value = current.copyWith(from: from, to: to);
    }

    Future<void> pickTo() async {
      final current = filter.value;
      final picked = await DatePickerSheet.show(context, initial: current.to ?? current.from ?? DateTime.now());
      if (picked == null) return;
      final to = picked.onlyDate();
      final from = current.from != null && current.from!.onlyDate().isAfter(to) ? to : current.from;
      filter.value = current.copyWith(from: from, to: to);
    }

    String presetLabel(_DatePreset p) => switch (p) {
          _DatePreset.any => l10n.wallet_filter_any_date,
          _DatePreset.thisMonth => l10n.wallet_filter_this_month,
          _DatePreset.lastMonth => l10n.wallet_filter_last_month,
          _DatePreset.last30Days => l10n.wallet_filter_last_30_days,
          _DatePreset.thisYear => l10n.wallet_filter_this_year,
          _DatePreset.custom => l10n.wallet_filter_custom_range,
        };

    const sectionPadding = EdgeInsets.only(top: 20, bottom: 10);
    final f = filter.value;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Type ----
                UiSectionLabel(text: l10n.wallet_filter_type, padding: sectionPadding),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    UiTypePill(
                      label: l10n.common_income,
                      color: UIColorToken.blue,
                      selected: f.types.contains(TransactionType.income),
                      onTap: () => toggleType(TransactionType.income),
                    ),
                    UiTypePill(
                      label: l10n.common_expense,
                      color: colors.expenseColor,
                      selected: f.types.contains(TransactionType.expense),
                      onTap: () => toggleType(TransactionType.expense),
                    ),
                    UiTypePill(
                      label: l10n.common_transfer,
                      color: colors.secondContentColor,
                      selected: f.types.contains(TransactionType.transfer),
                      onTap: () => toggleType(TransactionType.transfer),
                    ),
                  ],
                ),

                // ---- Date ----
                UiSectionLabel(text: l10n.wallet_filter_date, padding: sectionPadding),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _DatePreset.values)
                      _SelectChip(
                        label: presetLabel(p),
                        selected: preset.value == p,
                        onTap: () => selectPreset(p),
                      ),
                  ],
                ),
                if (preset.value == _DatePreset.custom) ...[
                  const UISpace.vert(6),
                  UiListRow(
                    leading: UIIcon(UIIconToken.icons.time.calendar, size: 20),
                    title: l10n.wallet_filter_from,
                    trailingText: f.from?.formatMediumDate() ?? l10n.wallet_filter_any_date,
                    onTap: pickFrom,
                  ),
                  const UIDivider(),
                  UiListRow(
                    leading: UIIcon(UIIconToken.icons.time.calendar, size: 20),
                    title: l10n.wallet_filter_to,
                    trailingText: f.to?.formatMediumDate() ?? l10n.wallet_filter_any_date,
                    onTap: pickTo,
                  ),
                ],

                // ---- Tags ----
                UiSectionLabel(text: l10n.wallet_filter_tags, padding: sectionPadding),
                if (tags == null)
                  const SizedBox(height: 28)
                else if (tags.isEmpty)
                  Text(l10n.wallet_filter_no_tags, style: typo.hint)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in tags)
                        _SelectChip(
                          label: '#${tag.displayName}',
                          selected: f.tagIds.contains(tag.id),
                          onTap: () => toggleTag(tag.id),
                        ),
                    ],
                  ),

                // ---- Upcoming only ----
                const UISpace.vert(20),
                Row(
                  children: [
                    Expanded(child: Text(l10n.wallet_filter_upcoming_only, style: typo.body)),
                    const UISpace.horz(12),
                    UISwitch(
                      value: f.upcomingOnly,
                      onChanged: (v) => filter.value = f.copyWith(upcomingOnly: v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: UiTextButton(
                  label: l10n.wallet_filter_clear,
                  style: UiTextButtonStyle.secondary,
                  fontSize: 16,
                  onTap: () => Navigator.of(context).pop(TransactionFilter.none),
                ),
              ),
              Expanded(
                flex: 2,
                child: UiPrimaryButton(
                  label: l10n.common_apply,
                  onTap: () => Navigator.of(context).pop(filter.value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Selectable pill (date presets, tags): blue 12 % fill + blue text when
/// selected, outlined and muted otherwise — same look as the card's tag pills.
class _SelectChip extends StatelessWidget {
  const _SelectChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return UITap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? UIColorToken.blue.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: selected ? Colors.transparent : colors.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: context.typo.inter.chip.copyWith(color: selected ? UIColorToken.blue : colors.secondContentColor),
        ),
      ),
    );
  }
}
