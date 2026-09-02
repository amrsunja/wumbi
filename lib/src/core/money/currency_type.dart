/// Supported currencies. `scale` = number of decimals stored in minor units.
enum CurrencyType {
  usd(code: 'USD', symbol: r'$', scale: 2, displayName: 'US Dollar'),
  eur(code: 'EUR', symbol: '€', scale: 2, displayName: 'Euro'),
  gbp(code: 'GBP', symbol: '£', scale: 2, displayName: 'British Pound'),
  chf(code: 'CHF', symbol: 'CHF', scale: 2, displayName: 'Swiss Franc'),
  cad(code: 'CAD', symbol: r'CA$', scale: 2, displayName: 'Canadian Dollar'),
  jpy(code: 'JPY', symbol: '¥', scale: 0, displayName: 'Japanese Yen'),
  aud(code: 'AUD', symbol: r'A$', scale: 2, displayName: 'Australian Dollar'),
  sek(code: 'SEK', symbol: 'kr', scale: 2, displayName: 'Swedish Krona'),
  nok(code: 'NOK', symbol: 'kr', scale: 2, displayName: 'Norwegian Krone'),
  dkk(code: 'DKK', symbol: 'kr', scale: 2, displayName: 'Danish Krone'),
  cny(code: 'CNY', symbol: '¥', scale: 2, displayName: 'Chinese Yuan'),
  tryLira(code: 'TRY', symbol: '₺', scale: 2, displayName: 'Turkish Lira'),
  btc(code: 'BTC', symbol: '₿', scale: 8, displayName: 'Bitcoin');

  const CurrencyType({
    required this.code,
    required this.symbol,
    required this.scale,
    required this.displayName,
  });

  /// ISO-4217 code (BTC for bitcoin). Stored in DB.
  final String code;
  final String symbol;
  final int scale;
  final String displayName;

  bool get isCrypto => this == btc;

  /// Backwards compatible alias used by older widgets.
  String get dbValue => code;

  /// Symbols made of letters get a trailing space: `CHF 1,234.00`, `kr 1,234.00`.
  String get formatSymbol =>
      RegExp(r'^[A-Za-z]+$').hasMatch(symbol) ? '$symbol ' : symbol;

  static CurrencyType fromCode(String? code) {
    if (code == null) return usd;
    final upper = code.toUpperCase();
    for (final c in values) {
      if (c.code == upper) return c;
    }
    return usd;
  }

  static CurrencyType? tryFromCode(String? code) {
    if (code == null) return null;
    final upper = code.toUpperCase();
    for (final c in values) {
      if (c.code == upper) return c;
    }
    return null;
  }

  /// Kept for call sites written against the previous enum.
  static CurrencyType fromString(String value) => fromCode(value);
}
