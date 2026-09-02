import '../utils/constants/constants.dart';
import 'currency_type.dart';
import 'money.dart';

/// Result of a numpad edit: the new raw string and whether the key was
/// rejected (too many digits → light error haptic).
class AmountInputResult {
  const AmountInputResult(this.value, {this.rejected = false});
  final String value;
  final bool rejected;
}

/// Pure amount-input rules for the numpad (spec 8.5.3). The raw string is
/// shown as typed (no thousands separators); `Money.parse` turns it into
/// minor units.
abstract class AmountInput {
  static AmountInputResult digit(String current, String d, CurrencyType c) {
    assert(d.length == 1 && int.tryParse(d) != null);
    // Leading "0" followed by a digit replaces the "0" ("0","5" → "5").
    if (current == '0') return AmountInputResult(d);
    final dot = current.indexOf('.');
    if (dot == -1) {
      if (current.length >= kMaxIntegerDigits) return AmountInputResult(current, rejected: true);
      return AmountInputResult('$current$d');
    }
    final fraction = current.length - dot - 1;
    if (fraction >= c.scale) return AmountInputResult(current, rejected: true);
    return AmountInputResult('$current$d');
  }

  static AmountInputResult dot(String current, CurrencyType c) {
    if (c.scale == 0 || current.contains('.')) return AmountInputResult(current, rejected: true);
    if (current.isEmpty) return const AmountInputResult('0.');
    return AmountInputResult('$current.');
  }

  static String backspace(String current) =>
      current.isEmpty ? current : current.substring(0, current.length - 1);

  static String clear() => '';

  /// Re-validate after a currency change: truncate the fraction to the new
  /// scale (USD → JPY drops the decimals).
  static String reScale(String current, CurrencyType c) {
    final dot = current.indexOf('.');
    if (dot == -1) return current;
    if (c.scale == 0) return current.substring(0, dot);
    final fraction = current.substring(dot + 1);
    if (fraction.length <= c.scale) return current;
    return '${current.substring(0, dot)}.${fraction.substring(0, c.scale)}';
  }

  /// `Money` for the raw string, or null when empty / zero.
  static Money? toMoney(String current, CurrencyType c) {
    if (current.isEmpty || current == '.' || current == '0.') return null;
    final m = Money.parse(current, c);
    return m.minor == 0 ? null : m;
  }

  /// Display text for the amount slot: "0" when empty.
  static String display(String current) => current.isEmpty ? '0' : current;
}
