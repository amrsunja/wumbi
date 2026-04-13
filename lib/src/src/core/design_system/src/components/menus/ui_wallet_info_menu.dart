import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/utils/enums/currency_type.dart';
import 'package:flutter/material.dart';

class UiWalletInfoMenu extends StatelessWidget {
  const UiWalletInfoMenu({
    super.key,
    required this.name,
    required this.color,
    required this.currencyType,
    this.onSelectWallet,
    this.onSelectCurrency,
  });

  final String name;
  final Color color;
  final CurrencyType currencyType;
  final VoidCallback? onSelectWallet;
  final VoidCallback? onSelectCurrency;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 6,
      children: [
        UiSelectButton(
          title: '${currencyType.dbValue} (${currencyType.symbol})',
          onTap: onSelectCurrency,
        ),
        SizedBox(
          height: 14,
          child: VerticalDivider(
            color: UIColorToken.casper.withValues(alpha: 0.5),
          ),
        ),
        UiSelectWalletButton(
          name: name,
          color: color,
          onTap: onSelectWallet,
        ),
      ],
    );
  }
}
