// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appLanguage => 'English';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_undo => 'Undo';

  @override
  String get common_ok => 'OK';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_today => 'Today';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String get common_income => 'Income';

  @override
  String get common_expense => 'Expense';

  @override
  String get common_transfer => 'Transfer';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Meet Fiin';

  @override
  String get onboarding_welcome_subtitle =>
      'Track money in seconds. No categories, just tags.';

  @override
  String get onboarding_currency_title => 'Your main currency';

  @override
  String get onboarding_currency_subtitle =>
      'Totals are shown in this currency. You can change it later in Settings.';

  @override
  String get onboarding_wallet_title => 'Your first wallet';

  @override
  String get onboarding_wallet_subtitle =>
      'Every wallet has one currency. You can add more wallets later.';

  @override
  String get onboarding_create_wallet => 'Create wallet';

  @override
  String get common_skip => 'Skip';

  @override
  String get onboarding_welcome_start => 'Get started';

  @override
  String get onboarding_benefit_wallets_title => 'Wallets in any currency';

  @override
  String get onboarding_benefit_wallets_body =>
      'Dollars, euros, bitcoin — every wallet keeps its own currency. Your total shows up in the one you choose.';

  @override
  String get onboarding_benefit_tags_title => 'Tags, not categories';

  @override
  String get onboarding_benefit_tags_body =>
      'Forget rigid categories. Add any tags you like — #coffee, #trip, #work — and find anything later.';

  @override
  String get onboarding_benefit_one_tap_title => 'Log it in one tap';

  @override
  String get onboarding_benefit_one_tap_body =>
      'Type the amount, tap Income or Expense. Done. The screen stays open for the next one.';

  @override
  String get onboarding_how_title => 'How it works';

  @override
  String get onboarding_how_body =>
      'Create a wallet, log money as it moves, and watch your totals update instantly.';

  @override
  String get onboarding_how_step_wallet => 'Add a wallet';

  @override
  String get onboarding_how_step_tap => 'Tap to log';

  @override
  String get onboarding_how_step_totals => 'See totals';

  @override
  String get onboarding_wallet_hero_prefix => 'Create your first';

  @override
  String get onboarding_wallet_hero_accent => 'Wallet';

  @override
  String get onboarding_final_title => 'You\'re all set!';

  @override
  String get onboarding_final_body =>
      'Your first wallet is ready. Fiin will keep the rest simple.';

  @override
  String get onboarding_final_button => 'Go to dashboard';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Across $count wallets',
      one: 'Across 1 wallet',
      zero: 'No wallets yet',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes not included';
  }

  @override
  String get dashboard_wallets => 'Wallets';

  @override
  String get dashboard_new_wallet => 'New Wallet';

  @override
  String get dashboard_empty_title => 'Create your first wallet';

  @override
  String get dashboard_empty_subtitle =>
      'Fiin needs a wallet to keep your money in.';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'Wallet Name';

  @override
  String get wallet_currency => 'Currency';

  @override
  String get wallet_primary => 'Primary Wallet';

  @override
  String get wallet_has_transactions => 'Has transactions';

  @override
  String get wallet_pick_another_primary => 'Pick another wallet as primary';

  @override
  String wallet_delete_title(String name) {
    return 'Delete $name?';
  }

  @override
  String get wallet_delete_message =>
      'Its transactions will be removed. Transfers with other wallets stay visible.';

  @override
  String get wallet_deleted => 'Wallet deleted';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wallet deleted · $count repeats paused',
      one: 'Wallet deleted · 1 repeat paused',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'No transactions yet';

  @override
  String get wallet_empty_subtitle => 'Tap + to add your first one';

  @override
  String get wallet_switch_title => 'Switch wallet';

  @override
  String wallet_transfer_to(String name) {
    return 'Transfer to $name';
  }

  @override
  String wallet_transfer_from(String name) {
    return 'Transfer from $name';
  }

  @override
  String get wallet_deleted_suffix => '(deleted)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repeating',
      one: '1 repeating',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'This wallet no longer exists';

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'Edit';

  @override
  String get transaction_description_placeholder => 'description';

  @override
  String get transaction_tags_placeholder => '#tags';

  @override
  String get transaction_repeat => 'Repeat';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · part of a repeat';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount will be added to $wallet';
  }

  @override
  String transaction_hint_stale(String date) {
    return 'rate from $date';
  }

  @override
  String get transaction_rate_unavailable =>
      'Rate unavailable — connect to update';

  @override
  String transaction_saved(String amount, String wallet) {
    return 'Saved $amount to $wallet';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return 'Moved $amount to $wallet';
  }

  @override
  String get transaction_deleted => 'Transaction deleted';

  @override
  String get transaction_delete_title => 'Delete this transaction?';

  @override
  String get transaction_delete_this_one => 'Delete this one';

  @override
  String get transaction_delete_and_stop => 'Delete and stop repeating';

  @override
  String get transaction_need_second_wallet_title =>
      'Create a second wallet to transfer';

  @override
  String get transaction_need_second_wallet_message =>
      'Transfers move money between two of your wallets.';

  @override
  String get transaction_different_currency => 'Different currency';

  @override
  String transaction_counterpart_to(String wallet, String amount) {
    return '→ $wallet +$amount';
  }

  @override
  String transaction_counterpart_from(String wallet, String amount) {
    return '← $wallet -$amount';
  }

  @override
  String get l10nTransfer =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSFER ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String transfer_title(String amount, String wallet) {
    return 'Transfer $amount from $wallet';
  }

  @override
  String get transfer_amount_received => 'Amount received';

  @override
  String get transfer_confirm => 'Confirm transfer';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'Never';

  @override
  String get repeat_every_day => 'Every day';

  @override
  String get repeat_every_week => 'Every week';

  @override
  String get repeat_every_month => 'Every month';

  @override
  String get repeat_every_year => 'Every year';

  @override
  String get repeat_daily => 'Daily';

  @override
  String get repeat_weekly => 'Weekly';

  @override
  String get repeat_monthly => 'Monthly';

  @override
  String get repeat_yearly => 'Yearly';

  @override
  String get repeat_rules_title => 'Repeating transactions';

  @override
  String get repeat_rules_hint =>
      'To change an amount or description, delete the rule and create it again.';

  @override
  String repeat_next(String date) {
    return 'Next: $date';
  }

  @override
  String get repeat_paused => 'Paused';

  @override
  String get repeat_delete_title => 'Stop this repeat?';

  @override
  String get repeat_delete_message =>
      'Existing transactions stay. No new ones will be created.';

  @override
  String get repeat_stop => 'Stop';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'Pick a date';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Currency';

  @override
  String get currency_base_title => 'Base currency';

  @override
  String get currency_base_hint =>
      'Your dashboard total is converted into this currency.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_preferences => 'Preferences';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_currency => 'Currency';

  @override
  String get settings_dark_mode => 'Dark Mode';

  @override
  String get settings_data_privacy => 'Data & Privacy';

  @override
  String get settings_export_transactions => 'Export Transactions';

  @override
  String get settings_reset_all_data => 'Reset All Data';

  @override
  String get settings_reset_title => 'Reset all data?';

  @override
  String get settings_reset_message =>
      'Every wallet, transaction and setting on this device will be erased. This cannot be undone.';

  @override
  String get settings_reset_action => 'Reset';

  @override
  String get settings_reset_done => 'All data removed';

  @override
  String settings_version(String version, String build) {
    return 'Version: $version ($build)';
  }

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_info =>
      'Select your preferred language for the application interface.';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'About Fiin';

  @override
  String get about_project => 'About the Project';

  @override
  String get about_text =>
      'Fiin is a minimalist, local-first budgeting app. Your data is encrypted and never leaves your device.';

  @override
  String get about_support => 'Contact Support';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'Enter an amount';

  @override
  String validation_up_to_tags(int count) {
    return 'Up to $count tags';
  }

  @override
  String get validation_rate_unavailable => 'Rate unavailable';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'Database error, try again.';

  @override
  String get error_unknown => 'Something went wrong. Please try again.';

  @override
  String get error_rate_unavailable =>
      'No exchange rate available. Connect to the internet and try again.';

  @override
  String get error_validation => 'Please check the entered values.';

  @override
  String get error_wallet_has_transactions =>
      'The currency can\'t change once a wallet has transactions.';

  @override
  String get error_not_found => 'This item no longer exists.';

  @override
  String get error_open_db_title => 'Couldn\'t open your data';

  @override
  String get error_open_db_message =>
      'Fiin couldn\'t unlock the database on this device.';

  @override
  String get error_reset_app => 'Reset app';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
