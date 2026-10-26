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
  String get transaction_edit_title => 'Edit transaction';

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
  String get progress_by_day => 'Day by day';

  @override
  String get progress_by_month => 'Month by month';

  @override
  String get progress_other => 'Other';

  @override
  String get progress_month => 'Month';

  @override
  String get progress_year => 'Year';

  @override
  String get progress_income => 'Income';

  @override
  String get progress_all_wallets => 'All wallets';

  @override
  String get progress_scope_title => 'Show data for';

  @override
  String progress_not_included(String codes) {
    return '$codes not included';
  }

  @override
  String get progress_empty_title => 'Nothing to analyse yet';

  @override
  String get progress_untagged => 'Untagged';

  @override
  String get progress_no_expenses => 'No spending in this period';

  @override
  String get progress_empty_subtitle =>
      'Add a few transactions and your progress shows up here.';

  @override
  String get progress_spent => 'Spent';

  @override
  String get progress_spending => 'Spending';

  @override
  String get progress_saved => 'Saved';

  @override
  String get progress_overspent => 'Overspent';

  @override
  String progress_vs(String label) {
    return 'vs $label';
  }

  @override
  String progress_kept_share(int percent) {
    return 'You kept $percent% of what you earned';
  }

  @override
  String progress_overspent_by(String amount) {
    return 'You spent $amount more than you earned';
  }

  @override
  String progress_nothing_in(String period) {
    return 'No transactions in $period';
  }

  @override
  String get progress_compare_title => 'Compare with';

  @override
  String get progress_baseline_previous_month => 'Previous month';

  @override
  String get progress_baseline_previous_year => 'Previous year';

  @override
  String get progress_baseline_last_year => 'Same month last year';

  @override
  String progress_baseline_average_months(int count) {
    return 'Average of the last $count months';
  }

  @override
  String progress_baseline_average_years(int count) {
    return 'Average of the last $count years';
  }

  @override
  String get progress_baseline_pick_month => 'Pick a month';

  @override
  String get progress_baseline_pick_year => 'Pick a year';

  @override
  String progress_average_months(int count) {
    return 'the $count-month average';
  }

  @override
  String progress_average_years(int count) {
    return 'the $count-year average';
  }

  @override
  String get progress_pace_title => 'Spending pace';

  @override
  String progress_pace_less(String amount, String baseline) {
    return '$amount less than $baseline at this point';
  }

  @override
  String progress_pace_more(String amount, String baseline) {
    return '$amount more than $baseline at this point';
  }

  @override
  String progress_pace_same(String baseline) {
    return 'Same pace as $baseline';
  }

  @override
  String progress_total_less(String amount, String baseline) {
    return '$amount less than $baseline';
  }

  @override
  String progress_total_more(String amount, String baseline) {
    return '$amount more than $baseline';
  }

  @override
  String progress_total_same(String baseline) {
    return 'About the same as $baseline';
  }

  @override
  String progress_forecast_month(String amount) {
    return 'At this pace ≈ $amount by the end of the month';
  }

  @override
  String progress_forecast_year(String amount) {
    return 'At this pace ≈ $amount by the end of the year';
  }

  @override
  String progress_day(int day) {
    return 'Day $day';
  }

  @override
  String get progress_changes_title => 'What changed';

  @override
  String progress_now_was(String now, String was) {
    return '$now now · was $was';
  }

  @override
  String get progress_new => 'New';

  @override
  String get progress_breakdown_title => 'By tag';

  @override
  String get progress_no_income => 'No income in this period';

  @override
  String progress_show_all(int count) {
    return 'Show all ($count)';
  }

  @override
  String get progress_show_less => 'Show less';

  @override
  String get progress_overlap_hint =>
      'A transaction with tags from several families counts in each.';

  @override
  String get progress_habits_title => 'Habits';

  @override
  String get progress_daily_average => 'Daily average';

  @override
  String get progress_biggest_expense => 'Biggest expense';

  @override
  String get progress_recurring => 'Recurring payments';

  @override
  String progress_recurring_share(int percent) {
    return '$percent% of your spending';
  }

  @override
  String get progress_average_expense => 'Average expense';

  @override
  String progress_peak_weekday(String weekday) {
    return 'You spend the most on $weekday';
  }

  @override
  String get progress_weekday_hint => 'Average spending per day of the week';

  @override
  String progress_history_months(int count) {
    return 'Last $count months';
  }

  @override
  String progress_history_years(int count) {
    return 'Last $count years';
  }

  @override
  String progress_average_per_month(String amount) {
    return 'Average $amount per month';
  }

  @override
  String progress_average_per_year(String amount) {
    return 'Average $amount per year';
  }

  @override
  String progress_to_date_hint(String baseline) {
    return 'Compared with the same days of $baseline';
  }

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
  String budget_name_hint(String name) {
    return 'Budget name: $name';
  }

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
      'Tap “New debt”, or use Transfer → Debts on the transaction screen';

  @override
  String get debt_new => 'New debt';

  @override
  String get debt_edit_title => 'Edit debt';

  @override
  String get debts_all => 'All debts';

  @override
  String get debts_empty_hint => 'Keep track of money you lent or borrowed';

  @override
  String get dashboard_reorder_hint => 'Hold to reorder';

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
  String get debt_person => 'Who';

  @override
  String get debt_person_chip => 'Who';

  @override
  String get debt_person_title => 'Who\'s it with?';

  @override
  String get debt_person_search => 'Name — person, bank, shop…';

  @override
  String get debt_person_empty => 'No one yet — type a name';

  @override
  String get debt_person_none => 'No one';

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
  String get debt_error_person => 'Choose who it\'s with';

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
  String get debt_rename_person => 'Rename';

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
      other: '$count Debts',
      one: '1 Debt',
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
  String get dashboard_wallets_not_counted => 'Not counted in total';

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
  String get budget_planned_title => 'Planned payments';

  @override
  String get budget_planned_exclude => 'Don\'t count planned';

  @override
  String get budget_planned_exclude_desc =>
      'Only payments already made count against the limit. Upcoming payments and subscriptions count once they\'re paid.';

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
  String get subscriptions_monthly_spend => 'Monthly spend';

  @override
  String get subscriptions_active_empty => 'No active subscriptions';

  @override
  String get subscriptions_paused_empty => 'No paused subscriptions';

  @override
  String budgets_summary_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You\'re over $count budgets',
      one: 'You\'re over 1 budget',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_close(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets are close to their limits',
      one: '1 budget is close to its limit',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_ok(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You\'re within your budgets',
      one: 'You\'re within your budget',
    );
    return '$_temp0';
  }

  @override
  String get budget_edit_title => 'Edit budget';

  @override
  String get wallet_edit_title => 'Edit wallet';

  @override
  String get budget_tab_overview => 'Overview';

  @override
  String get budget_back_to_current => 'Back to today';

  @override
  String get budget_row_starts => 'Starts on';

  @override
  String debt_story_lent_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return '$name still owes you $left of the $total you lent on $date.';
  }

  @override
  String debt_story_borrowed_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return 'You still owe $name $left of the $total you borrowed on $date.';
  }

  @override
  String debt_story_lent_settled(String name, String total, String date) {
    return '$name paid back all $total you lent on $date.';
  }

  @override
  String debt_story_borrowed_settled(String name, String total, String date) {
    return 'You paid back all $total you borrowed from $name on $date.';
  }

  @override
  String debt_story_forgiven(String total, String date) {
    return 'Closed on $date — the rest of the $total was forgiven.';
  }

  @override
  String get debt_stat_lent => 'Lent';

  @override
  String get debt_stat_borrowed => 'Borrowed';

  @override
  String get debt_stat_paid_back => 'Paid back';

  @override
  String get debt_stat_date => 'Date';

  @override
  String get debt_stat_due => 'Due';

  @override
  String get debt_note => 'Note';

  @override
  String get debt_add_note => 'Add a note';

  @override
  String get debt_got_part_back => 'Got part back';

  @override
  String get debt_paid_part => 'Paid part';

  @override
  String get debt_section_details => 'Details';

  @override
  String get debts_to_receive => 'To receive';

  @override
  String get debts_to_pay => 'To pay back';

  @override
  String get debts_settled_empty => 'No settled debts yet';

  @override
  String get transfer_debt_pay_back => 'Pay back';

  @override
  String get transfer_debt_lend => 'Lend';

  @override
  String get transfer_debt_lend_someone => 'Lend to…';

  @override
  String transfer_debt_lend_to(String name) {
    return 'Lend to $name';
  }

  @override
  String transfer_debt_only_left(String amount) {
    return 'Only $amount left';
  }

  @override
  String get transfer_debt_locked =>
      'A debt can’t repeat or be dated in the future';

  @override
  String transfer_debt_summary_repay(
    String wallet,
    String amount,
    String name,
  ) {
    return '$wallet −$amount → pays back $name';
  }

  @override
  String transfer_debt_summary_lend(String wallet, String amount, String name) {
    return '$wallet −$amount → lent to $name';
  }

  @override
  String get debt_wallet_title_in => 'Where did the money land?';

  @override
  String get debt_wallet_title_out => 'Where did you pay from?';

  @override
  String debt_wallet_explain_in(String name, String amount) {
    return '$name paid you back $amount. Which wallet did it go into? We\'ll add it there. If it was cash you don\'t keep track of, pick “Not in a wallet”.';
  }

  @override
  String debt_wallet_explain_out(String name, String amount) {
    return 'You\'re paying $name back $amount. Which wallet is it coming from? We\'ll take it out of that one. If you paid in cash you don\'t keep track of, pick “Not in a wallet”.';
  }

  @override
  String get debt_wallet_only_debt => 'No wallet changes, only the debt';

  @override
  String debt_wallet_confirm_in(String wallet) {
    return 'Add to $wallet';
  }

  @override
  String debt_wallet_confirm_out(String wallet) {
    return 'Pay from $wallet';
  }

  @override
  String get debt_wallet_confirm_none => 'Save without a wallet';

  @override
  String get debt_history_swipe_hint => 'Swipe a payment left to delete it';

  @override
  String get debt_form_person => 'Person';

  @override
  String get debt_form_wallet => 'Wallet';

  @override
  String get menu_open => 'Open menu';

  @override
  String get menu_close => 'Close menu';

  @override
  String get settings_mascot_talks => 'Wumbi talks';

  @override
  String get mascot_label => 'Wumbi the hamster. Tap to chat';

  @override
  String get mascot_dismiss => 'Let Wumbi go back to his corner';

  @override
  String get mascot_action_view => 'Show me';

  @override
  String get mascot_action_add => 'Add';

  @override
  String mascot_month_flow(String month, String income, String expense) {
    return '$month: +$income · −$expense';
  }

  @override
  String get mascot_greeting_morning => 'Morning, boss!';

  @override
  String get mascot_greeting_afternoon => 'Hey there, boss!';

  @override
  String get mascot_greeting_evening => 'Evening, boss!';

  @override
  String get mascot_all_calm =>
      'All quiet. The seeds are right where they should be';

  @override
  String get mascot_all_for_now => 'That’s all I’ve got for now 🙂';

  @override
  String get mascot_quiet_today => 'Got it, boss. Quiet as a mouse today';

  @override
  String mascot_flow_up(String amount, String month) {
    return '$month so far: the stash grew by $amount. Keep it up!';
  }

  @override
  String mascot_flow_down(String amount, String month) {
    return '$month so far: $amount more went out than came in. We’ll catch up';
  }

  @override
  String mascot_reserve_full(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Cheeks are full! Enough seeds for $months months',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Boss, the debt with $name was due $days days ago',
      one: 'Boss, the debt with $name was due yesterday',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue_nudge(String name) {
    return 'That debt with $name is still hanging around, boss. Take a look?';
  }

  @override
  String mascot_budget_over(String name) {
    return 'Boss, “$name” went over the limit. Let’s see where the seeds leaked';
  }

  @override
  String mascot_budget_over_by(String name, String amount) {
    return '“$name” is $amount over. Want to figure it out together, boss?';
  }

  @override
  String mascot_budget_near_left(String name, String amount) {
    return 'Only $amount left in “$name” this period, boss';
  }

  @override
  String mascot_budget_near_percent(String name, int percent) {
    return '“$name” is already at $percent%. Maybe ease off a little?';
  }

  @override
  String mascot_sleep_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'I dozed off, boss… $days days without a single entry. Shall we catch up?',
    );
    return '$_temp0';
  }

  @override
  String get mascot_sleep_quiet =>
      'It’s awfully quiet here. Forgot to log something, boss?';

  @override
  String get mascot_sigh_month =>
      'Boss, more seeds are going out than coming in this month. Let’s find the leak?';

  @override
  String get mascot_sigh_ahead =>
      'Spending is outrunning income. Let’s see what we can trim together';

  @override
  String mascot_welcome_back(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You’re back, boss! $count new entries since last time',
      one: 'You’re back, boss! One new entry since last time',
      zero: 'You’re back, boss! It was quiet without you',
    );
    return '$_temp0';
  }

  @override
  String get mascot_evening_waited =>
      'Boss! I’ve been waiting for you all day!';

  @override
  String get mascot_evening_missed => 'I missed you…';

  @override
  String get mascot_evening_log =>
      'Let’s log today’s spending before it slips our minds?';

  @override
  String get mascot_evening_count => 'Help me count today’s seeds?';

  @override
  String get mascot_event_reserve =>
      'Boss, we’ve got three months of seeds stashed! Now we can sleep easy';

  @override
  String mascot_event_best_month(String amount) {
    return 'Best month in half a year! $amount went into the stash. Proud of you, boss';
  }

  @override
  String mascot_event_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days of counting seeds together. Thank you, boss!',
    );
    return '$_temp0';
  }

  @override
  String get mascot_event_records =>
      'That’s the 100th entry! Counting is way more fun together, boss';

  @override
  String mascot_event_streak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days in a row without missing one, boss! That’s discipline',
    );
    return '$_temp0';
  }

  @override
  String mascot_charge_today(String name, String amount) {
    return 'Heads up, boss: $name takes $amount today';
  }

  @override
  String mascot_charge_tomorrow(String name, String amount) {
    return 'Tomorrow $name takes $amount, boss';
  }

  @override
  String mascot_charge_soon(String name, String amount) {
    return 'In a couple of days $name takes $amount';
  }

  @override
  String get mascot_charge_unnamed => 'a subscription';

  @override
  String mascot_debt_due_today(String name) {
    return 'Boss, the debt with $name is due today';
  }

  @override
  String mascot_debt_due_tomorrow(String name) {
    return 'The debt with $name is due tomorrow. Let’s not forget?';
  }

  @override
  String mascot_debt_due_soon(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left on the debt with $name',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_mover(String name, int percent) {
    return 'Boss, “$name” is eating $percent% more seeds than last month. Take a look?';
  }

  @override
  String mascot_insight_untagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses this month have no tag. Let’s sort them out?',
      one: 'One expense this month has no tag. Let’s sort it out?',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_peak_day(String weekday) {
    return '$weekday is your hungriest day, boss';
  }

  @override
  String mascot_insight_reserve(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Cheeks look good: about $months months of seeds stashed',
      one: 'Cheeks look good: about a month of seeds stashed',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_top_expense(String name, String amount) {
    return 'Biggest bite this month: “$name”, $amount';
  }

  @override
  String mascot_insight_top_expense_amount(String amount) {
    return 'Biggest single bite this month: $amount';
  }

  @override
  String mascot_insight_daily_average(String amount) {
    return 'Boss, about $amount goes out every day this month';
  }

  @override
  String mascot_insight_daily_below(int percent) {
    return '$percent% fewer seeds a day than usual. Nice work, boss!';
  }

  @override
  String mascot_insight_daily_above(int percent) {
    return 'Boss, $percent% more seeds a day than usual. Want to see where they go?';
  }

  @override
  String mascot_insight_weekend(int percent) {
    return 'On weekends the seeds fly out $percent% faster than on weekdays';
  }

  @override
  String mascot_insight_frequent_tag(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips to “$name” this month. Becoming a habit, boss?',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_small_spends(String amount) {
    return 'Little purchases added up to $amount this month. Seed by seed, boss';
  }

  @override
  String mascot_insight_savings_rate(int percent) {
    return 'Boss, $percent% of this month’s income is staying in the stash. Happy cheeks!';
  }

  @override
  String get mascot_insight_no_income =>
      'Not a single seed has come in this month, boss. Did you forget to log your pay?';

  @override
  String mascot_insight_forecast_over(String amount) {
    return 'At this rate the month will cost about $amount. That’s more than usual, boss';
  }

  @override
  String mascot_insight_forecast_under(String amount) {
    return 'This month is shaping up light: about $amount. The stash says thanks';
  }

  @override
  String mascot_insight_owed_to_me(String amount) {
    return 'Boss, people owe you $amount. Maybe time for a gentle nudge?';
  }

  @override
  String mascot_insight_negative_wallet(String name) {
    return '“$name” dipped below zero, boss. Move a few seeds over?';
  }

  @override
  String mascot_insight_no_rate(String codes) {
    return 'Can’t convert $codes yet, no rate. I’ll finish counting once we’re online';
  }

  @override
  String mascot_insight_income_up(int percent) {
    return 'Boss, $percent% more seeds came in than usual! Stash half of the extra right away?';
  }

  @override
  String mascot_insight_tag_yearly(String name, String amount) {
    return 'At this pace, “$name” will eat about $amount a year';
  }

  @override
  String get mascot_insight_no_spend_yesterday =>
      'Not a single expense yesterday! My cheeks are proud of you, boss';

  @override
  String get mascot_tip_budget =>
      'Boss, a budget is just a little fence around the seeds. Put up the first one?';

  @override
  String get mascot_tip_subscriptions =>
      'Got regular payments? Add them once and I’ll keep an eye on them';

  @override
  String mascot_tip_subs_yearly(String amount) {
    return 'Boss, subscriptions eat $amount a year. Any you don’t really use?';
  }

  @override
  String mascot_tip_recurring_share(int percent) {
    return '$percent% of this month’s spending is regular payments. Round and round, like my wheel';
  }

  @override
  String get mascot_tip_new_month =>
      'New month, boss! Fresh pouch. Set up some budgets?';

  @override
  String mascot_tip_monday_recap(String amount) {
    return 'Last week $amount went out. Let’s see how we do this week, boss';
  }

  @override
  String mascot_tip_month_end(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days to go this month. You’re doing great, boss',
      one: 'One day to go this month. You’re doing great, boss',
    );
    return '$_temp0';
  }

  @override
  String get mascot_tip_tags =>
      'Tags help me see where the seeds go, boss. Try #food or #home';

  @override
  String mascot_tip_debt_due_date(String name) {
    return 'Give the debt with $name a due date and I’ll remind you in time';
  }

  @override
  String mascot_tip_budget_for(String name, int percent) {
    return 'Boss, “$name” takes $percent% of all spending. Give it a budget?';
  }

  @override
  String get mascot_tip_rainy_day =>
      'Boss, start a separate rainy-day wallet. Then surprises won’t catch us off guard';

  @override
  String get mascot_tip_pay_yourself_first =>
      'Seeds just came in! Put some aside right away, boss, before they scatter';

  @override
  String get mascot_tip_treat =>
      'The stash is in good shape, boss. It’s okay to treat yourself now and then, no guilt';

  @override
  String mascot_tip_future_self(String amount, String amount2) {
    return 'Just $amount a day adds up to $amount2 a year. Imagine those cheeks, boss!';
  }

  @override
  String get mascot_joke_friday =>
      'It’s Friday, boss! Go have fun, I’ll guard the seeds';

  @override
  String get mascot_joke_late_night =>
      'It’s late, boss… Log it and off to bed? I’m yawning already';

  @override
  String get mascot_joke_cheeks =>
      'Fun fact, boss: hamsters carry seeds in their cheeks. I carry your budget';

  @override
  String get mascot_joke_trees =>
      'Even if seeds grew on trees, I’d still hide them in my cheeks';

  @override
  String get mascot_joke_twice =>
      'I counted your seeds twice. Same number, boss. Good sign';

  @override
  String get mascot_joke_secret =>
      'Psst, boss… Round every expense up in your head. The difference is your secret stash';

  @override
  String mascot_reaction_income(String amount) {
    return 'Caught $amount! Into the stash, boss';
  }

  @override
  String mascot_reaction_big_income(String amount) {
    return 'Whoa, boss! +$amount. My cheeks might burst!';
  }

  @override
  String mascot_reaction_transfer(String amount) {
    return 'Moved $amount over';
  }

  @override
  String mascot_reaction_lent(String amount) {
    return 'Lent $amount. I’ll remember, boss';
  }

  @override
  String get mascot_reaction_debt_closed => 'Debt closed! Clean paws, boss';

  @override
  String get mascot_reaction_forgiven =>
      'You forgave it… You’ve got a kind heart, boss';

  @override
  String get mascot_reaction_first_wallet =>
      'First wallet, boss! Let the stashing begin';

  @override
  String get mascot_reaction_budget => 'Budget’s set. I’ll stand guard, boss';

  @override
  String get mascot_wallet_negative => 'Boss, this wallet went below zero';

  @override
  String mascot_wallet_down(int percent) {
    return '$percent% of the seeds here are gone since the 1st';
  }

  @override
  String mascot_wallet_up(String amount) {
    return 'Up $amount since the 1st. Lovely, boss!';
  }

  @override
  String get mascot_wallet_sleeping =>
      'This wallet’s been asleep for a month. Shh…';

  @override
  String get mascot_wallet_calm => 'All quiet in this one, boss';

  @override
  String mascot_budgets_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Boss, $count budgets went over the limit',
      one: 'Boss, one budget went over the limit',
    );
    return '$_temp0';
  }

  @override
  String mascot_budgets_near(String name) {
    return '“$name” is almost tapped out, boss';
  }

  @override
  String get mascot_budgets_calm =>
      'All fences holding, boss. Budgets look good';

  @override
  String mascot_budget_detail_over(String amount) {
    return '$amount over. Maybe raise the limit next time, boss?';
  }

  @override
  String mascot_budget_detail_pace(String date) {
    return 'At this pace the limit runs out on $date';
  }

  @override
  String get mascot_budget_detail_within =>
      'Stayed within the limit! Proud of you, boss';

  @override
  String get mascot_budget_detail_calm => 'Right on track, boss';

  @override
  String mascot_debts_overdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Boss, $count debts are overdue',
      one: 'Boss, one debt is overdue',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debts_all_closed =>
      'Every debt is closed! Clean paws, boss';

  @override
  String get mascot_debts_tracking => 'I keep track of who owes whom seeds';

  @override
  String mascot_debt_detail_overdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'This was due $days days ago, boss',
      one: 'This was due yesterday, boss',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debt_detail_lent =>
      'I remember who borrowed our seeds, boss';

  @override
  String mascot_debt_detail_due(String date) {
    return 'Due by $date';
  }

  @override
  String mascot_subs_spinning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions take their share of seeds every month',
      one: 'One subscription takes its share of seeds every month',
    );
    return '$_temp0';
  }

  @override
  String mascot_tags_top(String name) {
    return 'Most seeds this month went to “$name”';
  }

  @override
  String mascot_tag_up(int percent) {
    return '$percent% more than last month here';
  }

  @override
  String mascot_tag_down(int percent) {
    return '$percent% less than last month. Nice, boss!';
  }

  @override
  String mascot_progress_saved(String amount) {
    return '$amount went into the stash. Great job, boss!';
  }

  @override
  String mascot_progress_over(String amount) {
    return '$amount more seeds went out than came in';
  }

  @override
  String mascot_progress_over_tag(String amount, String name) {
    return '$amount more seeds went out than came in, mostly on “$name”';
  }

  @override
  String mascot_progress_forecast(String amount) {
    return 'At this pace, about $amount will go out this period';
  }

  @override
  String get mascot_progress_counting => 'Still counting this one, boss';

  @override
  String get mascot_screen_wallet_filter =>
      'Filter by tag and you’ll see where this wallet’s seeds go';

  @override
  String get mascot_screen_wallet_switch =>
      'Tap the wallet name up top to hop to another one';

  @override
  String get mascot_screen_wallet_limit =>
      'In the Budgets tab you can put a limit on this wallet';

  @override
  String get mascot_screen_budgets_rollover =>
      'Budgets can carry leftovers into the next period. Not a seed wasted';

  @override
  String get mascot_screen_budgets_tags =>
      'A budget can watch just the tags you pick. Say, #cafe';

  @override
  String get mascot_screen_budget_periods =>
      'Flip through periods to compare with earlier ones';

  @override
  String get mascot_screen_debts_due =>
      'Add a due date and I’ll remind you in time, boss';

  @override
  String get mascot_screen_debts_quick =>
      'Quickest way to repay: Transfer → Debts on the transaction screen';

  @override
  String get mascot_screen_subs_pause =>
      'You can pause a subscription instead of deleting it. The history stays';

  @override
  String get mascot_screen_tags_nest => 'Nest tags with a slash: food/coffee';

  @override
  String get mascot_screen_tags_map =>
      'Open the map and you’ll see how your tags connect, boss';

  @override
  String get mascot_screen_tag_rename =>
      'Rename or move a tag and the nested ones follow along';

  @override
  String get mascot_screen_progress_baseline =>
      'Tap “vs …” to compare with last year or a 3-month average';

  @override
  String mascot_ans_spent_today(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today: $amount across $count expenses',
      one: 'Today: $amount, just one expense',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_today =>
      'Not a single expense today, boss. Seeds intact!';

  @override
  String mascot_ans_spent_yesterday(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yesterday: $amount across $count expenses',
      one: 'Yesterday: $amount, just one expense',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_yesterday =>
      'Yesterday you didn’t spend a single seed. Hooray!';

  @override
  String mascot_ans_spent_week(String amount) {
    return 'This week so far: $amount';
  }

  @override
  String mascot_ans_spent_month(String expense, String income) {
    return 'This month $expense went out and $income came in';
  }

  @override
  String get mascot_ans_no_expenses =>
      'No expenses this month yet. Lovely, boss';

  @override
  String mascot_ans_upcoming(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments in the next 7 days: $amount',
      one: 'One payment in the next 7 days: $amount',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_upcoming => 'Nothing to pay for the next week';

  @override
  String mascot_ans_owed(String amount, String name) {
    return 'People owe you $amount, mostly $name';
  }

  @override
  String get mascot_ans_nobody_owes => 'Nobody owes you anything right now';

  @override
  String get mascot_ans_reserve_low =>
      'Less than a month of seeds, boss. Let’s fill those cheeks together';

  @override
  String get mascot_ans_reserve_unknown =>
      'I need about a month of entries to answer that properly';

  @override
  String mascot_ans_where(String name, int percent, String name2) {
    return 'Most seeds went to “$name” ($percent%), then “$name2”';
  }

  @override
  String mascot_ans_where_one(String name, int percent) {
    return 'Nearly all the seeds went to “$name”, $percent%';
  }

  @override
  String mascot_ans_where_untagged(int percent) {
    return 'Boss, $percent% of spending has no tags, so I can’t see where it went. Sort it out?';
  }

  @override
  String get mascot_q_today => 'Spent today?';

  @override
  String get mascot_q_yesterday => 'And yesterday?';

  @override
  String get mascot_q_week => 'This week?';

  @override
  String get mascot_q_month => 'This month?';

  @override
  String get mascot_q_where => 'Where did the seeds go?';

  @override
  String get mascot_q_biggest => 'Biggest expense?';

  @override
  String get mascot_q_budgets => 'Am I within budget?';

  @override
  String get mascot_q_upcoming => 'What’s due soon?';

  @override
  String get mascot_q_owed => 'Who owes me?';

  @override
  String get mascot_q_reserve => 'How long will it last?';

  @override
  String get mascot_q_tip => 'Any advice?';

  @override
  String get mascot_q_joke => 'Make me smile';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
