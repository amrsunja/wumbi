import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/design_system/src/utils/format_currency.dart';
import 'package:fiin/src/src/core/utils/enums/currency_type.dart';
import 'package:fiin/src/src/core/utils/enums/transaction_type.dart';
import 'package:flutter/material.dart';

class UiTransactionCard extends StatelessWidget {
  const UiTransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.currencyType,
    required this.type,
    this.onTap
  });

  final String title;
  final num amount;
  final DateTime date;
  final CurrencyType currencyType;
  final TransactionType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return UITap(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: UITextStyleToken.interSemiBold.copyWith(
                    fontSize: 16,
                    color: UIColorToken.bismark
                  ),
                ),
                Text(
                  '${date.day}.${date.month}.${date.year}, ${date.hour}:${date.minute}',
                  style: UITextStyleToken.interMedium.copyWith(
                    color: UIColorToken.casper,
                    fontSize: 12
                  ),
                )
              ],
            ),
          ),
          Text(
            '${type.symbol}${formatCurrency(amount, currencyType)}',
            style: UITextStyleToken.interSemiBold.copyWith(
              fontSize: 16,
              color: type.color
            ),
          )
        ],
      ),
    );
  }
}
