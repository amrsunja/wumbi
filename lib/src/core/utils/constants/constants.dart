const String kAppName = 'Fiin';
const String kSupportUrl = 'mailto:support@fiin.app';

const double kPageHorzPadding = 16;

/// Wider gutter for list blocks (dashboard wallets, wallet details rows).
const double kListHorzPadding = 24;

/// Extra inset applied to the numpad on top of [kPageHorzPadding].
const double kNumpadHorzPadding = 28;

/// Transaction screen limits (spec 8.5).
const int kMaxIntegerDigits = 12;
const int kMaxDescriptionLength = 80;
const int kMaxTagsPerTransaction = 10;
const int kMaxTagLength = 30;
const int kMaxWalletNameLength = 40;
const int kTransactionsPageSize = 50;

/// Hero tags shared between pages.
const String kHeroFab = 'hero-fab-transaction';
String heroWalletName(String walletId) => 'hero-wallet-name-$walletId';
String heroWalletBalance(String walletId) => 'hero-wallet-balance-$walletId';
