import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'currency_type.dart';

/// Money value object: integer minor units + currency. Never a double.
@immutable
class Money {
  const Money(this.minor, this.currency);

  const Money.zero(this.currency) : minor = 0;

  final int minor;
  final CurrencyType currency;

  bool get isZero => minor == 0;
  bool get isNegative => minor < 0;
  bool get isPositive => minor > 0;

  Money operator +(Money o) {
    assert(o.currency == currency, 'Currency mismatch');
    return Money(minor + o.minor, currency);
  }

  Money operator -(Money o) {
    assert(o.currency == currency, 'Currency mismatch');
    return Money(minor - o.minor, currency);
  }

  Money operator -() => Money(-minor, currency);

  Money abs() => Money(minor.abs(), currency);

  /// Parses user input ("123.45") into minor units without going through
  /// `double.parse` — the fraction is padded / truncated to `c.scale`.
  static Money parse(String input, CurrencyType c) {
    var s = input.trim().replaceAll(',', '');
    if (s.isEmpty) return Money(0, c);
    var negative = false;
    if (s.startsWith('-')) {
      negative = true;
      s = s.substring(1);
    }
    final parts = s.split('.');
    final intPart = parts[0].isEmpty ? '0' : parts[0];
    var frac = parts.length > 1 ? parts[1] : '';
    frac = frac.length > c.scale
        ? frac.substring(0, c.scale)
        : frac.padRight(c.scale, '0');
    final digits = '$intPart$frac'.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return Money(0, c);
    final value = int.parse(digits);
    return Money(negative ? -value : value, c);
  }

  /// Plain decimal string without separators or symbol: 12345 → "123.45".
  /// Used to pre-fill the numpad in edit mode.
  String toPlainString() {
    final abs = minor.abs();
    final s = abs.toString().padLeft(currency.scale + 1, '0');
    final intPart = s.substring(0, s.length - currency.scale);
    final frac = s.substring(s.length - currency.scale);
    final body = currency.scale == 0 ? intPart : '$intPart.$frac';
    return minor < 0 ? '-$body' : body;
  }

  /// Formatting only — never stored. `$12,345.67`, `€5,678.90`, `¥1,500`,
  /// `₿0.00420000`, `CHF 1,234.00`.
  String format({
    bool signed = false,
    bool positiveSign = false,
    bool withSymbol = true,
  }) {
    final f = NumberFormat.currency(
      locale: 'en_US',
      symbol: withSymbol ? currency.formatSymbol : '',
      decimalDigits: currency.scale,
    );
    final s = f.format(minor.abs() / math.pow(10, currency.scale)).trim();
    if (signed && minor < 0) return '-$s';
    if (positiveSign && minor > 0) return '+$s';
    return s;
  }

  /// `120.00 EUR` — used for the "original amount" caption in lists.
  String formatWithCode() => '${format(withSymbol: false)} ${currency.code}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() => 'Money(${format()})';
}

/// One multiplication, then rounding half away from zero. The rate is never summed.
int convertMinor(int fromMinor, CurrencyType from, CurrencyType to, double rate) {
  if (from == to) return fromMinor;
  final value = fromMinor / math.pow(10, from.scale);
  return (value * rate * math.pow(10, to.scale)).round();
}

Money convertMoney(Money money, CurrencyType to, double rate) =>
    Money(convertMinor(money.minor, money.currency, to, rate), to);

/// `1 USD = 0.9203 EUR`, `1 BTC = 61,234.5 USD` — 4 decimals, trailing zeros trimmed.
String formatRate(double rate, CurrencyType from, CurrencyType to) {
  final f = NumberFormat('#,##0.####', 'en_US');
  return '1 ${from.code} = ${f.format(rate)} ${to.code}';
}
