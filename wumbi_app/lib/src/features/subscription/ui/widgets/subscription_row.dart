import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/money.dart';
import '../../../../core/utils/enums/transaction_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../../core/utils/extensions/date_time_extensions.dart';
import '../../../transaction/data/models/recurring_rule_model.dart';
import '../../../transaction/ui/widgets/repeat_labels.dart';
import '../../../wallet/data/models/wallet_model.dart';

/// List row with up to two caption lines (schedule, wallet names), the rule's tag
/// chips (like a transaction row) and a trailing amount · switch. Stopping a
/// subscription lives on its edit page. Mirrors `UiListRow` spacing.
class SubscriptionRow extends StatelessWidget {
  const SubscriptionRow({
    super.key,
    required this.rule,
    required this.walletsById,
    required this.onTap,
    required this.onToggle,
    this.tags = const [],
    this.showWallet = true,
  });

  final RecurringRuleModel rule;
  final Map<String, WalletSummary> walletsById;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final List<String> tags;

  /// False when the list is already scoped to one wallet: the wallet line is
  /// dropped (transfers keep their `from → to` line).
  final bool showWallet;

  String _walletName(BuildContext context, String? id) =>
      (id == null ? null : walletsById[id]?.name) ?? context.l10n.wallet_deleted_suffix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typo = context.typo.inter;
    final r = rule;

    final title = r.description.isNotEmpty
        ? r.description
        : switch (r.type) {
            TransactionType.income => l10n.common_income,
            TransactionType.expense => l10n.common_expense,
            TransactionType.transfer => l10n.common_transfer,
          };

    final schedule = r.isActive
        ? '${repeatShortLabel(l10n, r.frequency)} · ${l10n.repeat_next(r.nextOccurrence.formatShortDate())}'
        : '${repeatShortLabel(l10n, r.frequency)} · ${l10n.repeat_paused}';

    final walletLine = r.isTransfer
        ? '${_walletName(context, r.fromWalletId)} → ${_walletName(context, r.toWalletId)}'
        : _walletName(context, r.walletId);

    final Money amount;
    final Color? amountColor;
    switch (r.type) {
      case TransactionType.income:
        amount = Money(r.amountMinor ?? 0, r.currency);
        amountColor = UIColorToken.blue;
      case TransactionType.expense:
        amount = Money(-(r.amountMinor ?? 0), r.currency);
        amountColor = colors.expenseColor;
      case TransactionType.transfer:
        amount = Money(r.fromAmountMinor ?? 0, r.currency);
        amountColor = null;
    }
    final amountText = r.isTransfer ? amount.format() : amount.format(signed: true, positiveSign: true);

    return UITap(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.listTitle),
                  Text(schedule, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
                  if (showWallet || r.isTransfer)
                    Text(walletLine, maxLines: 1, overflow: TextOverflow.ellipsis, style: typo.caption),
                  if (tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: UiTagChips(tags: tags),
                    ),
                ],
              ),
            ),
            const UISpace.horz(12),
            Text(
              amountText,
              style: amountColor == null ? typo.label : typo.label.copyWith(color: amountColor),
            ),
            const UISpace.horz(8),
            UISwitch(value: r.isActive, onChanged: onToggle),
          ],
        ),
      ),
    );
  }
}
