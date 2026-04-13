import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/design_system/src/utils/format_currency.dart';
import 'package:fiin/src/src/core/utils/enums/currency_type.dart';
import 'package:flutter/material.dart';

class UiWalletCard extends StatelessWidget {
  const UiWalletCard({
    super.key,
    required this.title,
    required this.currency,
    required this.totalAmount,
    required this.color,
    this.onTap
  });

  final String title;
  final CurrencyType currency;
  final num totalAmount;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
    mainAxisAlignment: .spaceBetween,
      children: [
        Flexible(
          child: Row(
            spacing: 18,
            children: [
              UiCircleColorBadge(color: color),
              Flexible(
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
                      currency.dbValue,
                      style: UITextStyleToken.interBold.copyWith(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: UIColorToken.casper
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        Text(
          formatCurrency(totalAmount, currency),
          style: UITextStyleToken.interSemiBold.copyWith(
            fontSize: 16,
            letterSpacing: -0.43,
            color: UIColorToken.bismark
          ),
        )
      ],
    );
  }
}
