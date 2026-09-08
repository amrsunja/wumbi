/// Supported currencies. `scale` = number of decimals stored in minor units.
///
/// Order = default order in the pickers (majors first, then by region, crypto
/// last). Codes map 1:1 onto `currency_converter`'s `Currency` enum (TRY is
/// the one exception, see `FxServiceImpl._toPackageCurrency`).
enum CurrencyType {
  // ---------------------------------------------------------------- majors
  usd(code: 'USD', symbol: r'$', scale: 2, displayName: 'US Dollar'),
  eur(code: 'EUR', symbol: '€', scale: 2, displayName: 'Euro'),
  gbp(code: 'GBP', symbol: '£', scale: 2, displayName: 'British Pound'),
  jpy(code: 'JPY', symbol: '¥', scale: 0, displayName: 'Japanese Yen'),
  chf(code: 'CHF', symbol: 'CHF', scale: 2, displayName: 'Swiss Franc'),
  cad(code: 'CAD', symbol: r'CA$', scale: 2, displayName: 'Canadian Dollar'),
  aud(code: 'AUD', symbol: r'A$', scale: 2, displayName: 'Australian Dollar'),
  cny(code: 'CNY', symbol: '¥', scale: 2, displayName: 'Chinese Yuan'),
  rub(code: 'RUB', symbol: '₽', scale: 2, displayName: 'Russian Ruble'),
  tryLira(code: 'TRY', symbol: '₺', scale: 2, displayName: 'Turkish Lira'),
  inr(code: 'INR', symbol: '₹', scale: 2, displayName: 'Indian Rupee'),

  // ---------------------------------------------------------------- europe
  sek(code: 'SEK', symbol: 'kr', scale: 2, displayName: 'Swedish Krona'),
  nok(code: 'NOK', symbol: 'kr', scale: 2, displayName: 'Norwegian Krone'),
  dkk(code: 'DKK', symbol: 'kr', scale: 2, displayName: 'Danish Krone'),
  pln(code: 'PLN', symbol: 'zł', scale: 2, displayName: 'Polish Złoty'),
  czk(code: 'CZK', symbol: 'Kč', scale: 2, displayName: 'Czech Koruna'),
  huf(code: 'HUF', symbol: 'Ft', scale: 2, displayName: 'Hungarian Forint'),
  ron(code: 'RON', symbol: 'lei', scale: 2, displayName: 'Romanian Leu'),
  bgn(code: 'BGN', symbol: 'лв', scale: 2, displayName: 'Bulgarian Lev'),
  uah(code: 'UAH', symbol: '₴', scale: 2, displayName: 'Ukrainian Hryvnia'),
  isk(code: 'ISK', symbol: 'kr', scale: 0, displayName: 'Icelandic Króna'),
  rsd(code: 'RSD', symbol: 'din', scale: 2, displayName: 'Serbian Dinar'),
  gel(code: 'GEL', symbol: '₾', scale: 2, displayName: 'Georgian Lari'),
  kzt(code: 'KZT', symbol: '₸', scale: 2, displayName: 'Kazakhstani Tenge'),
  byn(code: 'BYN', symbol: 'Br', scale: 2, displayName: 'Belarusian Ruble'),
  uzs(code: 'UZS', symbol: 'soʻm', scale: 2, displayName: 'Uzbekistani Som'),
  amd(code: 'AMD', symbol: '֏', scale: 2, displayName: 'Armenian Dram'),
  azn(code: 'AZN', symbol: '₼', scale: 2, displayName: 'Azerbaijani Manat'),

  // -------------------------------------------------------------- americas
  mxn(code: 'MXN', symbol: r'MX$', scale: 2, displayName: 'Mexican Peso'),
  brl(code: 'BRL', symbol: r'R$', scale: 2, displayName: 'Brazilian Real'),
  ars(code: 'ARS', symbol: r'AR$', scale: 2, displayName: 'Argentine Peso'),
  clp(code: 'CLP', symbol: r'CL$', scale: 0, displayName: 'Chilean Peso'),
  cop(code: 'COP', symbol: r'CO$', scale: 2, displayName: 'Colombian Peso'),
  pen(code: 'PEN', symbol: 'S/', scale: 2, displayName: 'Peruvian Sol'),

  // ----------------------------------------------------------- asia-pacific
  krw(code: 'KRW', symbol: '₩', scale: 0, displayName: 'South Korean Won'),
  hkd(code: 'HKD', symbol: r'HK$', scale: 2, displayName: 'Hong Kong Dollar'),
  sgd(code: 'SGD', symbol: r'S$', scale: 2, displayName: 'Singapore Dollar'),
  nzd(code: 'NZD', symbol: r'NZ$', scale: 2, displayName: 'New Zealand Dollar'),
  twd(code: 'TWD', symbol: r'NT$', scale: 2, displayName: 'New Taiwan Dollar'),
  thb(code: 'THB', symbol: '฿', scale: 2, displayName: 'Thai Baht'),
  idr(code: 'IDR', symbol: 'Rp', scale: 2, displayName: 'Indonesian Rupiah'),
  myr(code: 'MYR', symbol: 'RM', scale: 2, displayName: 'Malaysian Ringgit'),
  php(code: 'PHP', symbol: '₱', scale: 2, displayName: 'Philippine Peso'),
  vnd(code: 'VND', symbol: '₫', scale: 0, displayName: 'Vietnamese Dong'),
  pkr(code: 'PKR', symbol: 'Rs', scale: 2, displayName: 'Pakistani Rupee'),
  bdt(code: 'BDT', symbol: '৳', scale: 2, displayName: 'Bangladeshi Taka'),
  lkr(code: 'LKR', symbol: 'Rs', scale: 2, displayName: 'Sri Lankan Rupee'),

  // -------------------------------------------------- middle east & africa
  aed(code: 'AED', symbol: 'د.إ', scale: 2, displayName: 'UAE Dirham'),
  sar(code: 'SAR', symbol: '﷼', scale: 2, displayName: 'Saudi Riyal'),
  qar(code: 'QAR', symbol: 'ر.ق', scale: 2, displayName: 'Qatari Riyal'),
  kwd(code: 'KWD', symbol: 'د.ك', scale: 3, displayName: 'Kuwaiti Dinar'),
  bhd(code: 'BHD', symbol: 'د.ب', scale: 3, displayName: 'Bahraini Dinar'),
  omr(code: 'OMR', symbol: 'ر.ع.', scale: 3, displayName: 'Omani Rial'),
  jod(code: 'JOD', symbol: 'د.أ', scale: 3, displayName: 'Jordanian Dinar'),
  ils(code: 'ILS', symbol: '₪', scale: 2, displayName: 'Israeli New Shekel'),
  egp(code: 'EGP', symbol: 'E£', scale: 2, displayName: 'Egyptian Pound'),
  mad(code: 'MAD', symbol: 'د.م.', scale: 2, displayName: 'Moroccan Dirham'),
  dzd(code: 'DZD', symbol: 'د.ج', scale: 2, displayName: 'Algerian Dinar'),
  tnd(code: 'TND', symbol: 'د.ت', scale: 3, displayName: 'Tunisian Dinar'),
  ngn(code: 'NGN', symbol: '₦', scale: 2, displayName: 'Nigerian Naira'),
  zar(code: 'ZAR', symbol: 'R', scale: 2, displayName: 'South African Rand'),
  kes(code: 'KES', symbol: 'KSh', scale: 2, displayName: 'Kenyan Shilling'),
  ghs(code: 'GHS', symbol: '₵', scale: 2, displayName: 'Ghanaian Cedi'),

  // ---------------------------------------------------------------- crypto
  btc(code: 'BTC', symbol: '₿', scale: 8, displayName: 'Bitcoin'),
  eth(code: 'ETH', symbol: 'Ξ', scale: 8, displayName: 'Ethereum'),
  usdt(code: 'USDT', symbol: '₮', scale: 2, displayName: 'Tether');

  const CurrencyType({
    required this.code,
    required this.symbol,
    required this.scale,
    required this.displayName,
  });

  /// ISO-4217 code (BTC / ETH / USDT for crypto). Stored in DB.
  final String code;
  final String symbol;
  final int scale;
  final String displayName;

  static const Set<CurrencyType> _crypto = {btc, eth, usdt};

  bool get isCrypto => _crypto.contains(this);

  /// Backwards compatible alias used by older widgets.
  String get dbValue => code;

  /// Symbols made only of letters (any script) get a trailing space:
  /// `CHF 1,234.00`, `kr 1,234.00`, `zł 1,234.00`, `د.إ 1,234.00`;
  /// `CA$1,234.00` and `E£1,234.00` stay glued.
  String get formatSymbol => _lettersOnly.hasMatch(symbol) ? '$symbol ' : symbol;

  static final RegExp _lettersOnly = RegExp(r'^[\p{L}.ʻʼ]+$', unicode: true);

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
