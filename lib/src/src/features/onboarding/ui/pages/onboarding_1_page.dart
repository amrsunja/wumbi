import 'package:auto_route/auto_route.dart';
import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/utils/enums/currency_type.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


@RoutePage()
class Onboarding1Page extends HookConsumerWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: UIAppbar(
        title: 'dashboard',
        backTap: () {},
        action: UIIcon(
          UIIconToken.icons.general.settings01
        ),
      ),
      body: ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          UIFiinLooksFromLeft(),
          UIFiinLooksFromRight(),
          UIFiinLook(),
          UiTotalAmount(
            netWorth: 12234.3445,
            currency: CurrencyType.eur
          ),
          UiIconTextButton(
            icon: UIIconToken.icons.general.plusCircle,
            title: 'New Wallet'
          ),

          UiWalletCard(title: 'Checking', currency: .eur, totalAmount: 4255, color: UIColorToken.blue),

          // Transactions
          Column(
            spacing: 10,
            children: [
              UiTransactionCard(title: 'Salary Payment', amount: 1500, date: DateTime.now(), currencyType: .eur, type: .income),
              UiTransactionCard(title: 'Whole Foods Market', amount: 120, date: DateTime.now(), currencyType: .eur, type: .expense),
              UiTransactionCard(title: 'Tranfer from Wallet', amount: 2400, date: DateTime.now(), currencyType: .eur, type: .transfer),
            ],
          ),
          UiSelectWalletButton(name: 'Saving Wallet', color: UIColorToken.blue, onTap: () {}),
          UiSelectButton(title: 'USD', onTap: () {}),
          UiWalletInfoMenu(
            name: 'Saving wallet', color: Colors.green,
            currencyType: .usd,
            onSelectWallet: () {},
            onSelectCurrency: () {},
          )
        ],
      ),
    );
  }
}
