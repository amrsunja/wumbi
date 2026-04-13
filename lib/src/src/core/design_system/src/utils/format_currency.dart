  import 'package:fiin/src/src/core/utils/enums/currency_type.dart';
import 'package:intl/intl.dart';

String formatCurrency(num value, CurrencyType currency) {
  final digits = currency == CurrencyType.jpy ? 0 : 2;
  return NumberFormat.currency(
    symbol: currency.symbol,
    decimalDigits: digits,
  ).format(value);
}
