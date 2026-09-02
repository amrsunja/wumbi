import 'package:fiin/src/core/money/amount_input.dart';
import 'package:fiin/src/core/money/currency_type.dart';
import 'package:fiin/src/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.parse', () {
    test('parses decimals without double', () {
      expect(Money.parse('123.45', CurrencyType.usd).minor, 12345);
      expect(Money.parse('123', CurrencyType.usd).minor, 12300);
      expect(Money.parse('.5', CurrencyType.usd).minor, 50);
      expect(Money.parse('0.5', CurrencyType.usd).minor, 50);
      expect(Money.parse('', CurrencyType.usd).minor, 0);
    });

    test('BTC keeps 8 decimals exactly', () {
      expect(Money.parse('0.00012345', CurrencyType.btc).minor, 12345);
      expect(Money.parse('1', CurrencyType.btc).minor, 100000000);
    });

    test('JPY has no decimals', () {
      expect(Money.parse('1500', CurrencyType.jpy).minor, 1500);
      expect(Money.parse('1500.9', CurrencyType.jpy).minor, 1500);
    });

    test('truncates extra fraction digits', () {
      expect(Money.parse('1.999', CurrencyType.usd).minor, 199);
    });

    test('negative', () {
      expect(Money.parse('-12.34', CurrencyType.eur).minor, -1234);
    });
  });

  group('Money.format', () {
    test('formats per currency', () {
      expect(const Money(1234567, CurrencyType.usd).format(), r'$12,345.67');
      expect(const Money(567890, CurrencyType.eur).format(), '€5,678.90');
      expect(const Money(1500, CurrencyType.jpy).format(), '¥1,500');
      expect(const Money(420000, CurrencyType.btc).format(), '₿0.00420000');
      expect(const Money(123400, CurrencyType.chf).format(), 'CHF 1,234.00');
      expect(const Money(123400, CurrencyType.sek).format(), 'kr 1,234.00');
    });

    test('signs', () {
      expect(const Money(150000, CurrencyType.usd).format(positiveSign: true), r'+$1,500.00');
      expect(const Money(-12000, CurrencyType.usd).format(signed: true), r'-$120.00');
      expect(const Money(-12000, CurrencyType.usd).format(), r'$120.00');
    });

    test('formatWithCode / toPlainString', () {
      expect(const Money(12000, CurrencyType.eur).formatWithCode(), '120.00 EUR');
      expect(const Money(12345, CurrencyType.usd).toPlainString(), '123.45');
      expect(const Money(5, CurrencyType.usd).toPlainString(), '0.05');
      expect(const Money(1500, CurrencyType.jpy).toPlainString(), '1500');
      expect(const Money(-1234, CurrencyType.usd).toPlainString(), '-12.34');
    });
  });

  group('convertMinor', () {
    test('same currency is identity', () {
      expect(convertMinor(12345, CurrencyType.usd, CurrencyType.usd, 0.5), 12345);
    });

    test('rounds half away from zero', () {
      expect(convertMinor(12300, CurrencyType.usd, CurrencyType.eur, 0.9203), 11320);
      expect(convertMinor(100, CurrencyType.usd, CurrencyType.jpy, 149.5), 150);
      expect(convertMinor(100000000, CurrencyType.btc, CurrencyType.usd, 61234.5), 6123450);
    });
  });

  group('formatRate', () {
    test('4 decimals, trailing zeros trimmed', () {
      expect(formatRate(0.9203, CurrencyType.usd, CurrencyType.eur), '1 USD = 0.9203 EUR');
      expect(formatRate(61234.5, CurrencyType.btc, CurrencyType.usd), '1 BTC = 61,234.5 USD');
      expect(formatRate(1, CurrencyType.usd, CurrencyType.usd), '1 USD = 1 USD');
    });
  });

  group('AmountInput (numpad rules)', () {
    test('leading zero replaced by digit', () {
      expect(AmountInput.digit('0', '5', CurrencyType.usd).value, '5');
      expect(AmountInput.digit('0.', '5', CurrencyType.usd).value, '0.5');
    });

    test('dot rules', () {
      expect(AmountInput.dot('', CurrencyType.usd).value, '0.');
      expect(AmountInput.dot('12', CurrencyType.usd).value, '12.');
      expect(AmountInput.dot('12.', CurrencyType.usd).rejected, isTrue);
      expect(AmountInput.dot('12', CurrencyType.jpy).rejected, isTrue);
    });

    test('fraction limited to scale', () {
      expect(AmountInput.digit('1.23', '4', CurrencyType.usd).rejected, isTrue);
      expect(AmountInput.digit('1.2345678', '9', CurrencyType.btc).value, '1.23456789');
      expect(AmountInput.digit('1.23456789', '9', CurrencyType.btc).rejected, isTrue);
    });

    test('max 12 integer digits', () {
      expect(AmountInput.digit('123456789012', '3', CurrencyType.usd).rejected, isTrue);
      expect(AmountInput.digit('12345678901', '2', CurrencyType.usd).value, '123456789012');
    });

    test('backspace / clear / rescale', () {
      expect(AmountInput.backspace('12.3'), '12.');
      expect(AmountInput.backspace(''), '');
      expect(AmountInput.reScale('12.34', CurrencyType.jpy), '12');
      expect(AmountInput.reScale('12.34', CurrencyType.btc), '12.34');
      expect(AmountInput.reScale('1.23456789', CurrencyType.usd), '1.23');
    });

    test('toMoney', () {
      expect(AmountInput.toMoney('', CurrencyType.usd), isNull);
      expect(AmountInput.toMoney('0.', CurrencyType.usd), isNull);
      expect(AmountInput.toMoney('0.00', CurrencyType.usd), isNull);
      expect(AmountInput.toMoney('12.5', CurrencyType.usd), const Money(1250, CurrencyType.usd));
    });
  });
}
