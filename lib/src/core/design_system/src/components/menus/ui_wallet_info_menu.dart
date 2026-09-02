import 'package:flutter/material.dart';

import '../../../../money/currency_type.dart';
import '../../../app_ui.dart';

/// Header row: "USD ⌄  |  • Savings Vault ⌄". Either side becomes static
/// (no chevron, no tap) when its callback is null.
class UiWalletInfoMenu extends StatelessWidget {
  const UiWalletInfoMenu({
    super.key,
    required this.name,
    required this.color,
    required this.currencyType,
    this.onSelectWallet,
    this.onSelectCurrency,
    this.showSymbol = false,
    this.walletHeroTag,
  });

  final String name;
  final Color color;
  final CurrencyType currencyType;
  final VoidCallback? onSelectWallet;
  final VoidCallback? onSelectCurrency;

  /// "USD ($)" instead of "USD".
  final bool showSymbol;

  /// Hero target for the dashboard wallet row.
  final Object? walletHeroTag;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context).colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [
        UiSelectButton(
          title: showSymbol ? '${currencyType.code} (${currencyType.symbol})' : currencyType.code,
          onTap: onSelectCurrency,
          enabled: onSelectCurrency != null,
        ),
        SizedBox(
          height: 14,
          child: VerticalDivider(width: 1, thickness: 1, color: colors.dividerColor),
        ),
        Flexible(
          child: walletHeroTag == null
              ? UiSelectWalletButton(
                  name: name,
                  color: color,
                  onTap: onSelectWallet,
                  enabled: onSelectWallet != null,
                )
              : UiHero(
                  tag: walletHeroTag!,
                  alignment: Alignment.centerLeft,
                  child: UiSelectWalletButton(
                    name: name,
                    color: color,
                    onTap: onSelectWallet,
                    enabled: onSelectWallet != null,
                  ),
                ),
        ),
      ],
    );
  }
}
