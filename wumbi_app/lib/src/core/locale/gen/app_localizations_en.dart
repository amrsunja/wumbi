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
  String get common_edit => 'Edit';

  @override
  String get common_all => 'All';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_apply => 'Apply';

  @override
  String get common_done => 'Done';

  @override
  String get common_close => 'Close';

  @override
  String get common_search => 'Search';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Meet Wumbi';

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
      'Your first wallet is ready. Wumbi will keep the rest simple.';

  @override
  String get onboarding_final_button => 'Let\'s go';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'My Money';

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
      'Wumbi needs a wallet to keep your money in.';

  @override
  String get dashboard_tags => 'Tags';

  @override
  String get dashboard_subscriptions => 'Subscriptions';

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
  String get wallet_tab_transactions => 'Transactions';

  @override
  String get wallet_tab_budgets => 'Budgets';

  @override
  String get wallet_tab_subscriptions => 'Subscriptions';

  @override
  String get wallet_budgets_empty => 'No spending limits for this wallet yet';

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
  String get wallet_filter => 'Filter';

  @override
  String get wallet_sort => 'Sort';

  @override
  String get wallet_filter_title => 'Filter transactions';

  @override
  String get wallet_filter_type => 'Type';

  @override
  String get wallet_filter_date => 'Date';

  @override
  String get wallet_filter_tags => 'Tags';

  @override
  String get wallet_filter_from => 'From';

  @override
  String get wallet_filter_to => 'To';

  @override
  String get wallet_filter_any_date => 'Any date';

  @override
  String get wallet_filter_this_month => 'This month';

  @override
  String get wallet_filter_last_month => 'Last month';

  @override
  String get wallet_filter_last_30_days => 'Last 30 days';

  @override
  String get wallet_filter_this_year => 'This year';

  @override
  String get wallet_filter_custom_range => 'Custom range';

  @override
  String get wallet_filter_upcoming_only => 'Upcoming only';

  @override
  String get wallet_filter_clear => 'Clear filters';

  @override
  String get wallet_filter_no_tags => 'No tags in this wallet yet';

  @override
  String get wallet_filter_no_results_title => 'Nothing matches';

  @override
  String get wallet_filter_no_results_subtitle => 'Try removing a filter.';

  @override
  String wallet_filter_active(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filters',
      one: '1 filter',
    );
    return '$_temp0';
  }

  @override
  String get wallet_sort_title => 'Sort by';

  @override
  String get sort_date_newest => 'Newest first';

  @override
  String get sort_date_oldest => 'Oldest first';

  @override
  String get sort_amount_high => 'Largest amount';

  @override
  String get sort_amount_low => 'Smallest amount';

  @override
  String get wallet_upcoming_section => 'Upcoming';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count upcoming transactions are not counted yet',
      one: '1 upcoming transaction is not counted yet',
    );
    return '$_temp0';
  }

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
  String get transaction_upcoming_badge => 'Upcoming';

  @override
  String transaction_upcoming_hint(String date) {
    return 'Counted on $date';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return 'Scheduled $amount for $date';
  }

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
  String get repeat_rules_title => 'Subscriptions';

  @override
  String get repeat_rules_hint =>
      'Tap a subscription to edit it. Existing transactions never change.';

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
  String get date_pick_from => 'From';

  @override
  String get date_pick_to => 'To';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'Search';

  @override
  String get search_placeholder => 'Description, amount, wallet or tag';

  @override
  String get search_hint =>
      'Search every wallet by description, amount, wallet name or tag.';

  @override
  String get search_no_results_title => 'Nothing found';

  @override
  String get search_no_results_subtitle => 'Try another word, amount or tag.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get l10nTags =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TAGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get tags_title => 'Tags';

  @override
  String get tags_view_list => 'List';

  @override
  String get tags_view_graph => 'Map';

  @override
  String get tags_search_placeholder => 'Search tags';

  @override
  String get tags_empty_title => 'No tags yet';

  @override
  String get tags_empty_subtitle =>
      'Add #tags to a transaction and they will show up here.';

  @override
  String get tags_search_no_results => 'No tags match your search';

  @override
  String tags_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

  @override
  String tags_usage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: 'Not used yet',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'Spent';

  @override
  String get tags_earned => 'Earned';

  @override
  String get tags_net => 'Net';

  @override
  String tags_not_included(String codes) {
    return '$codes not included';
  }

  @override
  String get tags_graph_hint =>
      'Bigger circles moved more money. Lines connect tags used together.';

  @override
  String get tags_graph_empty =>
      'Add tags to a few transactions to see the map.';

  @override
  String get tag_wallets => 'Wallets';

  @override
  String get tag_transactions => 'Transactions';

  @override
  String get tag_no_transactions => 'No transactions with this tag';

  @override
  String get tag_rename => 'Rename tag';

  @override
  String get tag_name_placeholder => 'Tag name';

  @override
  String get tag_delete => 'Delete tag';

  @override
  String tag_delete_title(String name) {
    return 'Delete #$name?';
  }

  @override
  String get tag_delete_message =>
      'It will be removed from every transaction. The transactions themselves stay.';

  @override
  String get tag_deleted => 'Tag deleted';

  @override
  String get tag_renamed => 'Tag renamed';

  @override
  String tag_merged(String name) {
    return 'Merged into #$name';
  }

  @override
  String get tag_not_found => 'This tag no longer exists';

  @override
  String get tag_wallet_deleted => '(deleted)';

  @override
  String get tags_new => 'New tag';

  @override
  String get tags_create => 'Create tag';

  @override
  String tags_created(String name) {
    return '#$name created';
  }

  @override
  String tags_exists(String name) {
    return '#$name already exists';
  }

  @override
  String get tags_parent => 'Parent tag';

  @override
  String get tags_parent_none => 'No parent';

  @override
  String get tags_name_hint => 'e.g. coffee';

  @override
  String get tags_create_tip =>
      'Tip: type food/coffee to nest a tag in one go.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nested',
      one: '1 nested',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'How to use tags?';

  @override
  String get tags_graph_mode_all => 'All';

  @override
  String get tags_graph_mode_spending => 'Spending';

  @override
  String get tags_graph_mode_income => 'Income';

  @override
  String get tags_graph_legend_size => 'Bigger = more money';

  @override
  String get tags_graph_legend_nested => 'Nested';

  @override
  String get tags_graph_legend_together => 'Used together';

  @override
  String get tags_graph_tap_hint => 'Tap a circle to see its numbers';

  @override
  String get tags_graph_open => 'Open';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Linked to $count tags',
      one: 'Linked to 1 tag',
      zero: 'No links yet',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'Move';

  @override
  String tag_move_title(String name) {
    return 'Move #$name';
  }

  @override
  String get tag_moved => 'Tag moved';

  @override
  String get tag_add_nested => 'Add nested tag';

  @override
  String get tag_nested_tags => 'Nested tags';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Includes $count nested tags',
      one: 'Includes 1 nested tag',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'It and its $count nested tags will be removed from every transaction. The transactions themselves stay.',
      one:
          'It and its nested tag will be removed from every transaction. The transactions themselves stay.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'Nested tags are renamed too. Use / to move it under another tag.';

  @override
  String get tag_top_level => 'Top level';

  @override
  String get tag_nested_empty => 'No nested tags yet';

  @override
  String get settings_help => 'Need help?';

  @override
  String get help_title => 'Need help?';

  @override
  String get help_subtitle => 'Short guides to get the most out of Wumbi.';

  @override
  String get help_tags_title => 'How to use tags?';

  @override
  String get help_tags_subtitle => 'Labels, nested tags and the map';

  @override
  String get help_tags_intro =>
      'Tags are short labels like #coffee that you add to transactions. A transaction can carry several tags, so you can look at your money from any angle — not only by wallet.';

  @override
  String get help_tags_add_title => 'Add a tag';

  @override
  String get help_tags_add_body =>
      'When you enter a transaction, type a name in the tags field, then pick a suggestion or create a new one. Tags have no spaces — write coffee-shop or coffee_shop. Upper and lower case give the same tag.';

  @override
  String get help_tags_nested_title => 'Nested tags';

  @override
  String get help_tags_nested_body =>
      'Use a slash / to put a tag inside another one, like folders: food/coffee and food/groceries both live inside food. The parent tag is created for you.';

  @override
  String get help_tags_parent_title => 'A parent includes its nested tags';

  @override
  String get help_tags_parent_body =>
      'Opening #food shows every transaction tagged #food, #food/coffee or #food/groceries. Totals, filters and budgets on a parent count its nested tags too. A transaction with both tags is counted only once.';

  @override
  String get help_tags_multi_title => 'Several tags on one transaction';

  @override
  String get help_tags_multi_body =>
      'A dinner on holiday can be #travel and #food/restaurant at the same time. It then counts in both, and the two tags get linked on the map.';

  @override
  String get help_tags_manage_title => 'Create, rename, move';

  @override
  String get help_tags_manage_body =>
      'On the Tags page, tap + to create a tag and pick a parent to nest it. Open a tag to rename it, move it under another parent, add a nested tag or delete it. Renaming a parent renames its nested tags; renaming into an existing tag merges the two.';

  @override
  String get help_tags_map_title => 'Read the map';

  @override
  String get help_tags_map_body =>
      'Every circle is a tag: the bigger it is, the more money it moved. Its ring shows the share of spending and income. Solid lines join a parent to its nested tags, faint lines join tags used on the same transaction. Tap a circle to see its numbers.';

  @override
  String get help_tags_tips_title => 'Tips';

  @override
  String get help_tags_tip1 =>
      'Start broad — food, home, transport — and nest only when you want more detail.';

  @override
  String get help_tags_tip2 =>
      'Use tags for what cuts across wallets: #vacation, #gifts, #car.';

  @override
  String get help_tags_tip3 =>
      'Keep names short; two or three levels are plenty.';

  @override
  String get help_tags_example => 'Example';

  @override
  String get help_tags_example_total => 'Total for #food';

  @override
  String get help_tags_ex_parent => 'food';

  @override
  String get help_tags_ex_child1 => 'coffee';

  @override
  String get help_tags_ex_child2 => 'groceries';

  @override
  String get help_tags_ex_travel => 'travel';

  @override
  String get help_tags_ex_restaurant => 'restaurant';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'Subscriptions';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Subscriptions',
      one: '1 Subscription',
      zero: 'No subscriptions',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'No subscriptions yet';

  @override
  String get subscriptions_empty_subtitle =>
      'Set Repeat on a transaction and it will appear here.';

  @override
  String get subscriptions_all_wallets => 'All wallets';

  @override
  String get subscriptions_active => 'Active';

  @override
  String get subscriptions_paused => 'Paused';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / month';
  }

  @override
  String get subscriptions_edit_title => 'Edit subscription';

  @override
  String get subscriptions_amount => 'Amount';

  @override
  String get subscriptions_wallet => 'Wallet';

  @override
  String get subscriptions_from_wallet => 'From wallet';

  @override
  String get subscriptions_to_wallet => 'To wallet';

  @override
  String get subscriptions_frequency => 'Frequency';

  @override
  String get subscriptions_description => 'Description';

  @override
  String get subscriptions_tags => 'Tags';

  @override
  String get subscriptions_pause => 'Pause';

  @override
  String get subscriptions_resume => 'Resume';

  @override
  String get subscriptions_stop => 'Stop subscription';

  @override
  String get subscriptions_saved => 'Subscription updated';

  @override
  String get subscriptions_stopped => 'Subscription stopped';

  @override
  String get subscriptions_type_hint =>
      'The type of a subscription can\'t change.';

  @override
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'Progress';

  @override
  String get progress_month => 'Month';

  @override
  String get progress_year => 'Year';

  @override
  String get progress_income => 'Income';

  @override
  String get progress_expense => 'Expense';

  @override
  String get progress_net => 'Net';

  @override
  String get progress_vs_last_month => 'vs last month';

  @override
  String get progress_vs_last_year => 'vs last year';

  @override
  String get progress_all_wallets => 'All wallets';

  @override
  String get progress_scope_title => 'Show data for';

  @override
  String get progress_chart_title => 'Income vs Expense';

  @override
  String progress_not_included(String codes) {
    return '$codes not included';
  }

  @override
  String get progress_empty_title => 'Nothing to analyse yet';

  @override
  String get progress_trend_title => 'Trend';

  @override
  String get progress_tags_title => 'Spending by tag';

  @override
  String get progress_untagged => 'Untagged';

  @override
  String get progress_other_tags => 'Other';

  @override
  String get progress_no_expenses => 'No spending in this period';

  @override
  String get progress_empty_subtitle =>
      'Add a few transactions and your progress shows up here.';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Currency';

  @override
  String get currency_no_results => 'No currency matches';

  @override
  String get currency_base_title => 'Base currency';

  @override
  String get currency_base_hint =>
      'Your total balance is converted into this currency.';

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
  String get settings_show_mascot => 'Show Mascot';

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
  String get settings_manage => 'Manage';

  @override
  String get settings_tags => 'Tags';

  @override
  String get settings_subscriptions => 'Subscriptions';

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
  String get about => 'About Wumbi';

  @override
  String get about_project => 'About the Project';

  @override
  String get about_text =>
      'Wumbi keeps your money on your phone. Type the amount, tap Income or Expense, done. No account needed, and nothing is uploaded unless you turn it on.';

  @override
  String get about_support => 'Contact Support';

  @override
  String get about_read_more => 'Read more on wumbi.app';

  @override
  String get settings_about_section => 'About';

  @override
  String get settings_privacy_policy => 'Privacy Policy';

  @override
  String get settings_terms => 'Terms of Use';

  @override
  String get settings_press => 'Press Kit';

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
  String debt_error_owes_you_only(String name, String amount) {
    return '$name owes you only $amount';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return 'You owe $name only $amount';
  }

  @override
  String get person_error_has_debts =>
      'Settle or delete this person\'s debts first.';

  @override
  String get debt_error_closed => 'This debt is already settled.';

  @override
  String get error_tag_name => 'Enter a tag name (up to 30 characters).';

  @override
  String get error_open_db_title => 'Couldn\'t open your data';

  @override
  String get error_open_db_message =>
      'Wumbi couldn\'t unlock the database on this device.';

  @override
  String get error_reset_app => 'Reset app';

  @override
  String get dashboard_budgets => 'Budgets';

  @override
  String get budget_new => 'New Budget';

  @override
  String get budget_empty_hint => 'Set a spending limit for a wallet or a #tag';

  @override
  String get budgets_all => 'All budgets';

  @override
  String get budgets_title => 'Budgets';

  @override
  String budget_left(String amount) {
    return '$amount left';
  }

  @override
  String budget_over(String amount) {
    return '$amount over';
  }

  @override
  String budget_starts(String date) {
    return 'Starts $date';
  }

  @override
  String get budget_ended => 'Ended';

  @override
  String budget_per_day(String amount) {
    return '$amount/day';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return 'Spent $spent of $limit';
  }

  @override
  String get budget_this_week => 'This week';

  @override
  String get budget_set_limit => 'Set a spending limit';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name: $amount left';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name: $amount over';
  }

  @override
  String get budget_all_spending => 'All spending';

  @override
  String get budget_name => 'Name';

  @override
  String get budget_name_placeholder => 'name';

  @override
  String get budget_what_counts => 'What counts';

  @override
  String get budget_wallets => 'Wallets';

  @override
  String get budget_all_wallets => 'All wallets';

  @override
  String get budget_tags => 'Tags';

  @override
  String get budget_any_tag => 'Any tag';

  @override
  String get budget_scope_all => 'Counts every expense.';

  @override
  String budget_scope_wallets(String wallets) {
    return 'Counts expenses from $wallets.';
  }

  @override
  String budget_scope_tags(String tags) {
    return 'Counts expenses tagged $tags.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return 'Counts expenses from $wallets tagged $tags.';
  }

  @override
  String get budget_scope_or => 'or';

  @override
  String get budget_period_section => 'Period';

  @override
  String get budget_repeats => 'Repeats';

  @override
  String get budget_period_weekly => 'Weekly';

  @override
  String get budget_period_monthly => 'Monthly';

  @override
  String get budget_period_yearly => 'Yearly';

  @override
  String get budget_period_custom => 'One-time';

  @override
  String get budget_starts_on => 'Starts on';

  @override
  String get budget_first_day => 'First day';

  @override
  String get budget_last_day => 'Last day';

  @override
  String budget_day_of_month(int day) {
    return 'Day $day';
  }

  @override
  String get budget_start_day_title => 'Start day';

  @override
  String get budget_start_day_hint => 'Short months start on their last day.';

  @override
  String get budget_start_weekday_title => 'First day of the week';

  @override
  String get budget_carry_over => 'Carry over';

  @override
  String get budget_rollover_none => 'Don\'t carry over';

  @override
  String get budget_rollover_surplus => 'Carry what\'s left';

  @override
  String get budget_rollover_both => 'Carry what\'s left and overspending';

  @override
  String get budget_count_planned => 'Count planned';

  @override
  String get budget_count_planned_hint => 'Include upcoming and subscriptions';

  @override
  String get budget_count_planned_desc =>
      'Upcoming payments and subscriptions count against the limit before they\'re paid.';

  @override
  String budget_suggested_months(String amount) {
    return 'Suggested: $amount · avg. of last 3 months';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'Suggested: $amount · avg. of last 3 weeks';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'Suggested: $amount · avg. of last 3 years';
  }

  @override
  String get budget_deleted => 'Budget deleted';

  @override
  String budget_delete_title(String name) {
    return 'Delete $name?';
  }

  @override
  String get budget_delete_message => 'Your transactions stay as they are.';

  @override
  String get budget_error_name => 'Name up to 40 characters';

  @override
  String get budget_error_dates => 'The last day must come after the first';

  @override
  String get budget_left_caption => 'left';

  @override
  String get budget_over_caption => 'over';

  @override
  String get budget_under_caption => 'under';

  @override
  String budget_spent(String amount) {
    return 'Spent $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'Planned $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'Limit $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount carried';
  }

  @override
  String get budget_on_track => 'On track';

  @override
  String budget_ahead_of_pace(String amount) {
    return '$amount ahead of pace';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return '$amount faster than planned';
  }

  @override
  String budget_forecast(String amount) {
    return 'forecast $amount';
  }

  @override
  String get budget_no_spending => 'No spending yet this period';

  @override
  String get budgets_active => 'Active';

  @override
  String get budgets_upcoming => 'Upcoming';

  @override
  String get budgets_empty_title => 'No budgets yet';

  @override
  String get budgets_empty_subtitle => 'Set a limit and watch what\'s left';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more budgets',
      one: '+1 more budget',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$amount/day for $_temp0';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Finished ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets removed',
      one: '1 budget removed',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'Debts';

  @override
  String get debts_owed_to_me => 'Owed to me';

  @override
  String get debts_i_owe => 'I owe';

  @override
  String get debts_empty_owed_title => 'Nobody owes you';

  @override
  String get debts_empty_owe_title => 'You owe nobody';

  @override
  String get debts_empty_subtitle =>
      'Pick a person on the transaction screen when you lend money';

  @override
  String get debt_new => 'New debt';

  @override
  String get debts_all => 'All debts';

  @override
  String get debts_empty_hint => 'Keep track of money you lent or borrowed';

  @override
  String get dashboard_reorder_hint => 'Hold to reorder';

  @override
  String dashboard_budgets_over(int count) {
    return '$count over limit';
  }

  @override
  String dashboard_budgets_at_risk(int count) {
    return '$count at risk';
  }

  @override
  String get dashboard_budgets_on_track => 'All on track';

  @override
  String dashboard_debts_to_receive(String amount) {
    return '$amount to receive';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return '$amount to pay back';
  }

  @override
  String get dashboard_new => 'New';

  @override
  String get debt_they_owe_me => 'They owe me';

  @override
  String get debt_i_owe_them => 'I owe them';

  @override
  String get debt_person => 'Person';

  @override
  String get debt_person_chip => 'Person';

  @override
  String get debt_person_title => 'Person';

  @override
  String get debt_person_search => 'Name';

  @override
  String get debt_person_empty => 'No people yet — type a name';

  @override
  String get debt_person_none => 'No person';

  @override
  String get debt_choose => 'Choose';

  @override
  String get debt_amount => 'Amount';

  @override
  String get debt_note_hint => 'Note (optional)';

  @override
  String get debt_note_placeholder => 'note';

  @override
  String get debt_due_date => 'Due date';

  @override
  String get debt_due_title => 'Due date';

  @override
  String get debt_add_due => 'Due date';

  @override
  String get debt_due_change => 'Change date';

  @override
  String get debt_due_remove => 'Remove due date';

  @override
  String get debt_none => 'None';

  @override
  String get debt_money_moved => 'Money moved';

  @override
  String get debt_not_in_wallet => 'Not in a wallet';

  @override
  String get debt_error_person => 'Choose a person';

  @override
  String get debt_gave => 'Gave';

  @override
  String get debt_got => 'Got';

  @override
  String get debt_badge_loan => 'Loan';

  @override
  String get debt_badge_return => 'Return';

  @override
  String get debt_overdue => 'overdue';

  @override
  String get debt_settled_label => 'Settled';

  @override
  String get debt_forgiven_label => 'Forgiven';

  @override
  String get debt_returned_in_full => 'Returned in full';

  @override
  String get debt_paid_in_full => 'Paid in full';

  @override
  String get debt_part => 'Part';

  @override
  String get debt_forgive => 'Forgive';

  @override
  String get debt_remind => 'Remind';

  @override
  String get debt_history => 'History';

  @override
  String get debt_edit_note => 'Edit note';

  @override
  String get debt_rename_person => 'Rename person';

  @override
  String get debt_delete => 'Delete debt';

  @override
  String get debt_delete_title => 'Delete this debt?';

  @override
  String get debt_deleted => 'Debt deleted';

  @override
  String get debt_payment_deleted => 'Payment deleted';

  @override
  String get debt_return_deleted => 'Return deleted';

  @override
  String debt_due(String date) {
    return 'due $date';
  }

  @override
  String debt_left(String amount) {
    return '$amount left';
  }

  @override
  String debt_left_of(String amount) {
    return 'left of $amount';
  }

  @override
  String debt_of(String amount) {
    return 'of $amount';
  }

  @override
  String debt_to_wallet(String wallet) {
    return 'to $wallet';
  }

  @override
  String debt_from_wallet(String wallet) {
    return 'from $wallet';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name owes you $amount';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return 'You owe $name $amount';
  }

  @override
  String debt_overall(String text) {
    return 'Overall: $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'Overall: $name owes you $owed · you owe $owe';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name owes you $amount · GOT counts as a return';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return 'You owe $name $amount · GAVE counts as paying back';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name owes you $owed · you owe $owe';
  }

  @override
  String debt_hint_none(String name) {
    return 'No open debts with $name · GAVE lends, GOT borrows';
  }

  @override
  String debt_person_add(String name) {
    return 'Add “$name”';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'owes you $amount';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'you owe $amount';
  }

  @override
  String debt_title_lent_to(String name) {
    return 'Lent to $name';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return 'Borrowed from $name';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name paid back';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return 'Paid back $name';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return 'Lent $amount to $name';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return 'Borrowed $amount from $name';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name returned $amount · $left left';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name returned $amount · all settled';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return 'Paid back $amount to $name · $left left';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return 'Paid back $amount to $name · all settled';
  }

  @override
  String debt_forgive_title(String name) {
    return 'Forgive $name?';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'The remaining $amount will be written off. No money moves.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'Debt forgiven · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'Hi $name! Just a reminder about $amount for $note ($date). Thanks!';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'Hi $name! Just a reminder about $amount ($date). Thanks!';
  }

  @override
  String debt_history_lent(String amount) {
    return 'Lent $amount';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return 'Lent $amount from $wallet';
  }

  @override
  String debt_history_borrowed(String amount) {
    return 'Borrowed $amount';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return 'Borrowed $amount into $wallet';
  }

  @override
  String debt_history_returned(String amount) {
    return 'Returned $amount';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return 'Returned $amount → $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return 'Paid back $amount';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return 'Paid back $amount from $wallet';
  }

  @override
  String debt_history_forgiven(String amount) {
    return 'Forgave $amount';
  }

  @override
  String debts_overdue_count(int count) {
    return '$count overdue';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count debts',
      one: '1 debt',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
      zero: 'No one',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Settled ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Loan deleted with $count returns',
      one: 'Loan deleted with 1 return',
      zero: 'Loan deleted',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallet transactions will be deleted too.',
      one: '1 wallet transaction will be deleted too.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'New Subscription';

  @override
  String subscriptions_active_count(int count) {
    return '$count active';
  }

  @override
  String subscriptions_paused_count(int count) {
    return '$count paused';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'Set a spending limit to keep this wallet in check.';

  @override
  String get wallet_include_in_total => 'Count in total balance';

  @override
  String get wallet_include_in_total_on =>
      'This wallet\'s balance is added to the total on the Dashboard.';

  @override
  String get wallet_include_in_total_off =>
      'Left out of the Dashboard total — handy for savings, shared or tracking-only wallets.';

  @override
  String dashboard_wallets_excluded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count not counted',
      one: '1 not counted',
    );
    return '$_temp0';
  }

  @override
  String get budget_rollover_none_desc =>
      'Every period starts fresh with the same limit. Leftovers and overspending don\'t move on.';

  @override
  String get budget_rollover_surplus_desc =>
      'What you didn\'t spend is added to the next period\'s limit.';

  @override
  String get budget_rollover_both_desc =>
      'Leftovers raise the next period\'s limit, overspending lowers it.';

  @override
  String budget_used_percent(int percent) {
    return '$percent% used';
  }

  @override
  String get budget_stat_spent => 'Spent';

  @override
  String get budget_stat_limit => 'Limit';

  @override
  String get budget_stat_planned => 'Planned';

  @override
  String get budget_stat_per_day => 'Per day';

  @override
  String get budget_stat_forecast => 'Forecast';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
