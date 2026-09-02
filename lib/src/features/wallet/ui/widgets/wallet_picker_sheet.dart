import 'package:flutter/material.dart';

import '../../../../core/design_system/app_ui.dart';
import '../../../../core/money/currency_type.dart';
import '../../../../core/utils/extensions/build_context_extensions.dart';
import '../../data/models/wallet_model.dart';

/// Bottom sheet listing wallets (badge, name, currency, balance).
abstract class WalletPickerSheet {
  static Future<WalletSummary?> show(
    BuildContext context, {
    required List<WalletSummary> wallets,
    required String title,
    String? excludeId,
    String? selectedId,

    /// Wallets with a different currency are greyed out with this reason.
    CurrencyType? requireCurrency,
    String? differentCurrencyReason,
  }) {
    final items = wallets.where((w) => w.id != excludeId).toList();
    return UIModalSheet.modalSheet<WalletSummary>(
      context: context,
      title: title,
      fitContent: items.length <= 6,
      height: 0.6,
      child: ListView.separated(
        shrinkWrap: items.length <= 6,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const UIDivider(),
        itemBuilder: (context, index) {
          final w = items[index];
          final locked = requireCurrency != null && w.currency != requireCurrency;
          return UiListRow(
            leading: UiCircleColorBadge(color: w.color.color),
            title: w.name,
            subtitle: w.currency.code,
            trailingText: w.balance.format(signed: true),
            selected: w.id == selectedId,
            disabledReason: locked ? (differentCurrencyReason ?? context.l10n.transaction_different_currency) : null,
            onTap: () => Navigator.of(context).pop(w),
          );
        },
      ),
    );
  }
}
