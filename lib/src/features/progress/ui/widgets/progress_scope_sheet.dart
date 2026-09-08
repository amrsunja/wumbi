import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../../wallet/data/models/wallet_model.dart';

/// Result of [ProgressScopeSheet]: a null [walletId] means "all wallets".
/// Wrapping it is what lets the page tell "picked all wallets" apart from
/// "dismissed the sheet".
class ProgressScope {
  const ProgressScope(this.walletId);

  final String? walletId;
}

/// Bottom sheet choosing what the progress page aggregates: every wallet
/// (converted to the base currency) or one wallet in its own currency.
abstract class ProgressScopeSheet {
  static Future<ProgressScope?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required String? selectedId,
  }) {
    final l10n = context.l10n;
    return UIModalSheet.modalSheet<ProgressScope>(
      context: context,
      title: l10n.progress_scope_title,
      fitContent: wallets.length <= 5,
      height: 0.6,
      child: ListView.separated(
        shrinkWrap: wallets.length <= 5,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: wallets.length + 1,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return UiListRow(
              leading: UIIcon(UIIconToken.icons.financeEcommerce.wallet02, size: 20),
              title: l10n.progress_all_wallets,
              selected: selectedId == null,
              onTap: () => Navigator.of(context).pop(const ProgressScope(null)),
            );
          }
          final wallet = wallets[index - 1];
          return UiListRow(
            leading: UiCircleColorBadge(color: wallet.color.color),
            title: wallet.name,
            subtitle: wallet.currency.code,
            trailingText: wallet.balance.format(signed: true),
            selected: wallet.id == selectedId,
            onTap: () => Navigator.of(context).pop(ProgressScope(wallet.id)),
          );
        },
      ),
    );
  }
}
