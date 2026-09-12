import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/design_system/app_ui.dart';
import '../core/money/currency_type.dart';
import '../core/money/money.dart';
import '../core/utils/enums/wallet_color.dart';

/// Design-system showcase (debug only, not routed). Push it manually from a
/// debug build: `Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryPage()))`.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    assert(kDebugMode, 'GalleryPage is a debug-only tool');
    return Scaffold(
      appBar: UIAppbar(title: 'gallery', backTap: () => Navigator.of(context).maybePop()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const UiTotalAmount(money: Money(1234567, CurrencyType.usd)),
          const UISpace.vert(16),
          UiWalletCard(title: 'Checking', balance: const Money(567890, CurrencyType.eur), color: WalletColor.blue.color),
          const UISpace.vert(16),
          const UiTransactionCard(
            title: 'Salary Payment',
            subtitle: 'Oct 28, 09:00 AM',
            amount: Money(150000, CurrencyType.usd),
            direction: UiTransactionDirection.income,
          ),
          const UiTransactionCard(
            title: 'Whole Foods Market',
            subtitle: 'Oct 27, 06:45 PM',
            amount: Money(12000, CurrencyType.usd),
            direction: UiTransactionDirection.expense,
            secondaryText: '110.00 EUR @ 1.0909',
          ),
          const UISpace.vert(16),
          UiNumpad(onDigit: (_) {}, onDot: () {}, onBackspace: () {}, onClear: () {}),
          const UISpace.vert(16),
          Row(
            children: [
              Expanded(
                child: UiTypeActionButton(
                  label: 'transfer',
                  style: UiTypeActionStyle.transfer,
                ),
              ),
              Expanded(
                child: UiTypeActionButton(
                  label: 'income',
                  style: UiTypeActionStyle.income,
                ),
              ),
              Expanded(
                child: UiTypeActionButton(
                  label: 'expense',
                  style: UiTypeActionStyle.expense,
                ),
              ),
            ],
          ),
          const UISpace.vert(16),
          UiColorPicker<WalletColor>(
            options: WalletColor.values,
            colorOf: (c) => c.color,
            selected: WalletColor.blue,
            onSelect: (_) {},
          ),
        ],
      ),
    );
  }
}
