import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../wallet/data/models/wallet_model.dart';

/// Where the money of a debt movement goes: a wallet, or "Not in a wallet"
/// (settled in cash outside Wumbi). Resolves with `(wallet: …)` — a null
/// wallet means "Not in a wallet" — or null when dismissed.
abstract class DebtWalletSheet {
  static Future<({WalletSummary? wallet})?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required String? selectedId,
  }) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<({WalletSummary? wallet})>(
      context: context,
      title: l10n.debt_money_moved,
      fitContent: wallets.length <= 6,
      height: 0.6,
      child: ListView(
        shrinkWrap: wallets.length <= 6,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          UiListRow(
            leading: UIIcon(UIIconToken.icons.financeEcommerce.coinsHand, size: 18),
            title: l10n.debt_not_in_wallet,
            selected: selectedId == null,
            onTap: () => Navigator.of(context).pop((wallet: null)),
          ),
          for (final w in wallets) ...[
            const UIDivider(),
            UiListRow(
              leading: UiCircleColorBadge(color: w.color.color),
              title: w.name,
              subtitle: w.currency.code,
              trailingText: w.balance.format(signed: true),
              selected: w.id == selectedId,
              onTap: () => Navigator.of(context).pop((wallet: w)),
            ),
          ],
        ],
      ),
    );
  }
}
