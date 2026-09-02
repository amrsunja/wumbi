import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get appLanguage;

  /// No description provided for @l10nCommon.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nCommon;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get common_undo;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_yesterday;

  /// No description provided for @common_income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get common_income;

  /// No description provided for @common_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get common_expense;

  /// No description provided for @common_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get common_transfer;

  /// No description provided for @l10nOnboarding.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nOnboarding;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Meet Fiin'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track money in seconds. No categories, just tags.'**
  String get onboarding_welcome_subtitle;

  /// No description provided for @onboarding_currency_title.
  ///
  /// In en, this message translates to:
  /// **'Your main currency'**
  String get onboarding_currency_title;

  /// No description provided for @onboarding_currency_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Totals are shown in this currency. You can change it later in Settings.'**
  String get onboarding_currency_subtitle;

  /// No description provided for @onboarding_wallet_title.
  ///
  /// In en, this message translates to:
  /// **'Your first wallet'**
  String get onboarding_wallet_title;

  /// No description provided for @onboarding_wallet_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Every wallet has one currency. You can add more wallets later.'**
  String get onboarding_wallet_subtitle;

  /// No description provided for @onboarding_create_wallet.
  ///
  /// In en, this message translates to:
  /// **'Create wallet'**
  String get onboarding_create_wallet;

  /// No description provided for @l10nDashboard.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nDashboard;

  /// No description provided for @dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// No description provided for @dashboard_across_wallets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No wallets yet} =1{Across 1 wallet} other{Across {count} wallets}}'**
  String dashboard_across_wallets(int count);

  /// No description provided for @dashboard_not_included.
  ///
  /// In en, this message translates to:
  /// **'{codes} not included'**
  String dashboard_not_included(String codes);

  /// No description provided for @dashboard_wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get dashboard_wallets;

  /// No description provided for @dashboard_new_wallet.
  ///
  /// In en, this message translates to:
  /// **'New Wallet'**
  String get dashboard_new_wallet;

  /// No description provided for @dashboard_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Create your first wallet'**
  String get dashboard_empty_title;

  /// No description provided for @dashboard_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Fiin needs a wallet to keep your money in.'**
  String get dashboard_empty_subtitle;

  /// No description provided for @l10nWallet.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nWallet;

  /// No description provided for @wallet_name_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get wallet_name_placeholder;

  /// No description provided for @wallet_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get wallet_currency;

  /// No description provided for @wallet_primary.
  ///
  /// In en, this message translates to:
  /// **'Primary Wallet'**
  String get wallet_primary;

  /// No description provided for @wallet_has_transactions.
  ///
  /// In en, this message translates to:
  /// **'Has transactions'**
  String get wallet_has_transactions;

  /// No description provided for @wallet_pick_another_primary.
  ///
  /// In en, this message translates to:
  /// **'Pick another wallet as primary'**
  String get wallet_pick_another_primary;

  /// No description provided for @wallet_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String wallet_delete_title(String name);

  /// No description provided for @wallet_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Its transactions will be removed. Transfers with other wallets stay visible.'**
  String get wallet_delete_message;

  /// No description provided for @wallet_deleted.
  ///
  /// In en, this message translates to:
  /// **'Wallet deleted'**
  String get wallet_deleted;

  /// No description provided for @wallet_deleted_paused_rules.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Wallet deleted · 1 repeat paused} other{Wallet deleted · {count} repeats paused}}'**
  String wallet_deleted_paused_rules(int count);

  /// No description provided for @wallet_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get wallet_empty_title;

  /// No description provided for @wallet_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first one'**
  String get wallet_empty_subtitle;

  /// No description provided for @wallet_switch_title.
  ///
  /// In en, this message translates to:
  /// **'Switch wallet'**
  String get wallet_switch_title;

  /// No description provided for @wallet_transfer_to.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {name}'**
  String wallet_transfer_to(String name);

  /// No description provided for @wallet_transfer_from.
  ///
  /// In en, this message translates to:
  /// **'Transfer from {name}'**
  String wallet_transfer_from(String name);

  /// No description provided for @wallet_deleted_suffix.
  ///
  /// In en, this message translates to:
  /// **'(deleted)'**
  String get wallet_deleted_suffix;

  /// No description provided for @wallet_repeating_summary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 repeating} other{{count} repeating}}'**
  String wallet_repeating_summary(int count);

  /// No description provided for @wallet_not_found.
  ///
  /// In en, this message translates to:
  /// **'This wallet no longer exists'**
  String get wallet_not_found;

  /// No description provided for @l10nTransaction.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nTransaction;

  /// No description provided for @transaction_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get transaction_edit_title;

  /// No description provided for @transaction_description_placeholder.
  ///
  /// In en, this message translates to:
  /// **'description'**
  String get transaction_description_placeholder;

  /// No description provided for @transaction_tags_placeholder.
  ///
  /// In en, this message translates to:
  /// **'#tags'**
  String get transaction_tags_placeholder;

  /// No description provided for @transaction_repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get transaction_repeat;

  /// No description provided for @transaction_repeat_part_of.
  ///
  /// In en, this message translates to:
  /// **'{frequency} · part of a repeat'**
  String transaction_repeat_part_of(String frequency);

  /// No description provided for @transaction_hint_added.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} will be added to {wallet}'**
  String transaction_hint_added(String amount, String wallet);

  /// No description provided for @transaction_hint_stale.
  ///
  /// In en, this message translates to:
  /// **'rate from {date}'**
  String transaction_hint_stale(String date);

  /// No description provided for @transaction_rate_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Rate unavailable — connect to update'**
  String get transaction_rate_unavailable;

  /// No description provided for @transaction_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved {amount} to {wallet}'**
  String transaction_saved(String amount, String wallet);

  /// No description provided for @transaction_moved.
  ///
  /// In en, this message translates to:
  /// **'Moved {amount} to {wallet}'**
  String transaction_moved(String amount, String wallet);

  /// No description provided for @transaction_deleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transaction_deleted;

  /// No description provided for @transaction_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get transaction_delete_title;

  /// No description provided for @transaction_delete_this_one.
  ///
  /// In en, this message translates to:
  /// **'Delete this one'**
  String get transaction_delete_this_one;

  /// No description provided for @transaction_delete_and_stop.
  ///
  /// In en, this message translates to:
  /// **'Delete and stop repeating'**
  String get transaction_delete_and_stop;

  /// No description provided for @transaction_need_second_wallet_title.
  ///
  /// In en, this message translates to:
  /// **'Create a second wallet to transfer'**
  String get transaction_need_second_wallet_title;

  /// No description provided for @transaction_need_second_wallet_message.
  ///
  /// In en, this message translates to:
  /// **'Transfers move money between two of your wallets.'**
  String get transaction_need_second_wallet_message;

  /// No description provided for @transaction_different_currency.
  ///
  /// In en, this message translates to:
  /// **'Different currency'**
  String get transaction_different_currency;

  /// No description provided for @transaction_counterpart_to.
  ///
  /// In en, this message translates to:
  /// **'→ {wallet} +{amount}'**
  String transaction_counterpart_to(String wallet, String amount);

  /// No description provided for @transaction_counterpart_from.
  ///
  /// In en, this message translates to:
  /// **'← {wallet} -{amount}'**
  String transaction_counterpart_from(String wallet, String amount);

  /// No description provided for @l10nTransfer.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSFER ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nTransfer;

  /// No description provided for @transfer_title.
  ///
  /// In en, this message translates to:
  /// **'Transfer {amount} from {wallet}'**
  String transfer_title(String amount, String wallet);

  /// No description provided for @transfer_amount_received.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get transfer_amount_received;

  /// No description provided for @transfer_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm transfer'**
  String get transfer_confirm;

  /// No description provided for @l10nRepeat.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nRepeat;

  /// No description provided for @repeat_never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeat_never;

  /// No description provided for @repeat_every_day.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeat_every_day;

  /// No description provided for @repeat_every_week.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeat_every_week;

  /// No description provided for @repeat_every_month.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeat_every_month;

  /// No description provided for @repeat_every_year.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get repeat_every_year;

  /// No description provided for @repeat_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeat_daily;

  /// No description provided for @repeat_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeat_weekly;

  /// No description provided for @repeat_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeat_monthly;

  /// No description provided for @repeat_yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get repeat_yearly;

  /// No description provided for @repeat_rules_title.
  ///
  /// In en, this message translates to:
  /// **'Repeating transactions'**
  String get repeat_rules_title;

  /// No description provided for @repeat_rules_hint.
  ///
  /// In en, this message translates to:
  /// **'To change an amount or description, delete the rule and create it again.'**
  String get repeat_rules_hint;

  /// No description provided for @repeat_next.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String repeat_next(String date);

  /// No description provided for @repeat_paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get repeat_paused;

  /// No description provided for @repeat_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Stop this repeat?'**
  String get repeat_delete_title;

  /// No description provided for @repeat_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Existing transactions stay. No new ones will be created.'**
  String get repeat_delete_message;

  /// No description provided for @repeat_stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get repeat_stop;

  /// No description provided for @l10nDate.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nDate;

  /// No description provided for @date_pick_title.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get date_pick_title;

  /// No description provided for @l10nCurrency.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nCurrency;

  /// No description provided for @currency_pick_title.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency_pick_title;

  /// No description provided for @currency_base_title.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get currency_base_title;

  /// No description provided for @currency_base_hint.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard total is converted into this currency.'**
  String get currency_base_hint;

  /// No description provided for @l10nSettings.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nSettings;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings_preferences;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settings_currency;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_data_privacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get settings_data_privacy;

  /// No description provided for @settings_export_transactions.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions'**
  String get settings_export_transactions;

  /// No description provided for @settings_reset_all_data.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settings_reset_all_data;

  /// No description provided for @settings_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset all data?'**
  String get settings_reset_title;

  /// No description provided for @settings_reset_message.
  ///
  /// In en, this message translates to:
  /// **'Every wallet, transaction and setting on this device will be erased. This cannot be undone.'**
  String get settings_reset_message;

  /// No description provided for @settings_reset_action.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settings_reset_action;

  /// No description provided for @settings_reset_done.
  ///
  /// In en, this message translates to:
  /// **'All data removed'**
  String get settings_reset_done;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version} ({build})'**
  String settings_version(String version, String build);

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_info.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the application interface.'**
  String get settings_language_info;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @l10nAbout.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nAbout;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Fiin'**
  String get about;

  /// No description provided for @about_project.
  ///
  /// In en, this message translates to:
  /// **'About the Project'**
  String get about_project;

  /// No description provided for @about_text.
  ///
  /// In en, this message translates to:
  /// **'Fiin is a minimalist, local-first budgeting app. Your data is encrypted and never leaves your device.'**
  String get about_text;

  /// No description provided for @about_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get about_support;

  /// No description provided for @l10nValidation.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nValidation;

  /// No description provided for @validation_enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get validation_enter_amount;

  /// No description provided for @validation_up_to_tags.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} tags'**
  String validation_up_to_tags(int count);

  /// No description provided for @validation_rate_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Rate unavailable'**
  String get validation_rate_unavailable;

  /// No description provided for @l10nErrors.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nErrors;

  /// No description provided for @error_db_failure.
  ///
  /// In en, this message translates to:
  /// **'Database error, try again.'**
  String get error_db_failure;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_unknown;

  /// No description provided for @error_rate_unavailable.
  ///
  /// In en, this message translates to:
  /// **'No exchange rate available. Connect to the internet and try again.'**
  String get error_rate_unavailable;

  /// No description provided for @error_validation.
  ///
  /// In en, this message translates to:
  /// **'Please check the entered values.'**
  String get error_validation;

  /// No description provided for @error_wallet_has_transactions.
  ///
  /// In en, this message translates to:
  /// **'The currency can\'t change once a wallet has transactions.'**
  String get error_wallet_has_transactions;

  /// No description provided for @error_not_found.
  ///
  /// In en, this message translates to:
  /// **'This item no longer exists.'**
  String get error_not_found;

  /// No description provided for @error_open_db_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open your data'**
  String get error_open_db_title;

  /// No description provided for @error_open_db_message.
  ///
  /// In en, this message translates to:
  /// **'Fiin couldn\'t unlock the database on this device.'**
  String get error_open_db_message;

  /// No description provided for @error_reset_app.
  ///
  /// In en, this message translates to:
  /// **'Reset app'**
  String get error_reset_app;

  /// No description provided for @l10nStopLineDontTouch.
  ///
  /// In en, this message translates to:
  /// **'☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠'**
  String get l10nStopLineDontTouch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
