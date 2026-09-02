/// Table and column names. Keep every raw SQL string keyed off these constants.
abstract class SQLiteConfig {
  static const String dbFileName = 'fiin.db';
  static const int dbVersion = 1;

  // ---------------------------------------------------------------- tables
  static const String settingsTable = 'settings';
  static const String walletsTable = 'wallets';
  static const String transactionsTable = 'transactions';
  static const String tagsTable = 'tags';
  static const String transactionTagsTable = 'transaction_tags';
  static const String recurringRulesTable = 'recurring_rules';
  static const String recurringRuleTagsTable = 'recurring_rule_tags';
  static const String exchangeRatesTable = 'exchange_rates';
  static const String walletBalancesView = 'wallet_balances';

  /// Kept for existing call sites.
  static const String settingsTableName = settingsTable;

  // -------------------------------------------------------------- common
  static const String id = 'id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String deletedAt = 'deleted_at';
  static const String syncStatus = 'sync_status';

  // ------------------------------------------------------------ settings
  static const String languageCodeKey = 'language_code';
  static const String countryCodeKey = 'country_code';
  static const String themeModeKey = 'theme_mode';
  static const String showOnboarding = 'show_onboarding';
  static const String baseCurrency = 'base_currency';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String lastRecurringRunAt = 'last_recurring_run_at';

  // ------------------------------------------------------------- wallets
  static const String walletName = 'name';
  static const String walletCurrency = 'currency';
  static const String walletInitialBalanceMinor = 'initial_balance_minor';
  static const String walletColor = 'color';
  static const String walletIsPrimary = 'is_primary';
  static const String walletSortOrder = 'sort_order';

  // -------------------------------------------------------- wallet_balances
  static const String balanceWalletId = 'wallet_id';
  static const String balanceMinor = 'balance_minor';

  // -------------------------------------------------------- transactions
  static const String txType = 'type';
  static const String txWalletId = 'wallet_id';
  static const String txAmountMinor = 'amount_minor';
  static const String txCurrency = 'currency';
  static const String txFromWalletId = 'from_wallet_id';
  static const String txToWalletId = 'to_wallet_id';
  static const String txFromAmountMinor = 'from_amount_minor';
  static const String txToAmountMinor = 'to_amount_minor';
  static const String txOriginalAmountMinor = 'original_amount_minor';
  static const String txOriginalCurrency = 'original_currency';
  static const String txExchangeRate = 'exchange_rate';
  static const String txDescription = 'description';
  static const String txDate = 'transaction_date';
  static const String txRecurringRuleId = 'recurring_rule_id';

  // ---------------------------------------------------------------- tags
  static const String tagNormalizedName = 'normalized_name';
  static const String tagDisplayName = 'display_name';
  static const String tagUsageCount = 'usage_count';
  static const String tagLastUsedAt = 'last_used_at';

  // ------------------------------------------------------ transaction_tags
  static const String ttTransactionId = 'transaction_id';
  static const String ttTagId = 'tag_id';

  // ------------------------------------------------------ recurring_rules
  static const String ruleFrequency = 'frequency';
  static const String ruleInterval = 'interval';
  static const String ruleStartDate = 'start_date';
  static const String ruleNextOccurrence = 'next_occurrence';
  static const String ruleOccurrenceCount = 'occurrence_count';
  static const String ruleEndDate = 'end_date';
  static const String ruleIsActive = 'is_active';

  // -------------------------------------------------- recurring_rule_tags
  static const String rrtRuleId = 'recurring_rule_id';
  static const String rrtTagId = 'tag_id';

  // ------------------------------------------------------ exchange_rates
  static const String fxBase = 'base_currency';
  static const String fxQuote = 'quote_currency';
  static const String fxRate = 'rate';
  static const String fxFetchedAt = 'fetched_at';
}
