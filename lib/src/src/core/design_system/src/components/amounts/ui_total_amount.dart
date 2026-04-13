import 'package:fiin/src/src/core/design_system/app_ui.dart';
import 'package:fiin/src/src/core/design_system/src/utils/format_currency.dart';
import 'package:fiin/src/src/core/utils/enums/currency_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class UiTotalAmount extends StatelessWidget {
  const UiTotalAmount({
    super.key,
    required this.netWorth,
    required this.currency,
    this.textAlign = TextAlign.center,
  });

  final num netWorth;
  final CurrencyType currency;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final formatted = formatCurrency(netWorth, currency);
    return Text(
      formatted,
      textAlign: textAlign,
      style: GoogleFonts.montserrat(
        fontSize: 44,
        fontWeight: .w300,
        color: UIColorToken.bismark
      ),
    );
  }
}


