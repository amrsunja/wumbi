import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/enums/transaction_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../transaction/data/models/recurring_rule_model.dart';
import '../../../transaction/ui/widgets/repeat_labels.dart';

/// Active rules for a wallet: description (or type fallback), amount,
/// frequency, "Next: Nov 1"; switch = pause/resume, trash = stop.
abstract class RecurringRulesSheet {
  static Future<void> show(
    BuildContext context, {
    required String walletId,
    required CurrencyType walletCurrency,
    required List<RecurringRuleModel> rules,
    required Future<void> Function(String ruleId, bool active) onToggle,
    required Future<void> Function(String ruleId) onDelete,
  }) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<void>(
      context: context,
      title: l10n.repeat_rules_title,
      height: 0.6,
      child: _RulesList(
        walletId: walletId,
        walletCurrency: walletCurrency,
        rules: rules,
        onToggle: onToggle,
        onDelete: onDelete,
      ),
    );
  }
}

class _RulesList extends StatefulWidget {
  const _RulesList({
    required this.walletId,
    required this.walletCurrency,
    required this.rules,
    required this.onToggle,
    required this.onDelete,
  });

  final String walletId;
  final CurrencyType walletCurrency;
  final List<RecurringRuleModel> rules;
  final Future<void> Function(String ruleId, bool active) onToggle;
  final Future<void> Function(String ruleId) onDelete;

  @override
  State<_RulesList> createState() => _RulesListState();
}

class _RulesListState extends State<_RulesList> {
  late List<RecurringRuleModel> _rules = List.of(widget.rules);

  String _title(RecurringRuleModel r, BuildContext context) {
    if (r.description.isNotEmpty) return r.description;
    final l10n = context.l10n;
    return switch (r.type) {
      TransactionType.income => l10n.common_income,
      TransactionType.expense => l10n.common_expense,
      TransactionType.transfer => l10n.common_transfer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
          child: Text(
            l10n.repeat_rules_hint,
            textAlign: TextAlign.center,
            style: context.typo.inter.caption,
          ),
        ),
        Expanded(
          child: _rules.isEmpty
              ? Center(
                  child: Text(l10n.repeat_never, style: context.typo.inter.caption),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _rules.length,
                  separatorBuilder: (_, _) => const UIDivider(),
                  itemBuilder: (context, index) {
                    final r = _rules[index];
                    final amount = r.amountFor(widget.walletId, widget.walletCurrency);
                    final subtitle = r.isActive
                        ? '${repeatShortLabel(l10n, r.frequency)} · ${l10n.repeat_next(r.nextOccurrence.formatShortDate())}'
                        : '${repeatShortLabel(l10n, r.frequency)} · ${l10n.repeat_paused}';
                    return UiListRow(
                      title: _title(r, context),
                      subtitle: subtitle,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Text(
                            amount.format(signed: true, positiveSign: true),
                            style: context.typo.inter.label,
                          ),
                          UISwitch(
                            value: r.isActive,
                            onChanged: (v) async {
                              setState(() => _rules[index] = r.copyWith(isActive: v));
                              await widget.onToggle(r.id, v);
                            },
                          ),
                          UIIcon(
                            UIIconToken.icons.general.trash01,
                            size: 20,
                            color: UIColorToken.neg500,
                            onTap: () async {
                              final ok = await UIAlertDialog.confirm(
                                context,
                                title: l10n.repeat_delete_title,
                                message: l10n.repeat_delete_message,
                                confirmLabel: l10n.repeat_stop,
                                cancelLabel: l10n.common_cancel,
                                destructive: true,
                              );
                              if (!ok || !context.mounted) return;
                              setState(() => _rules.removeAt(index));
                              await widget.onDelete(r.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
