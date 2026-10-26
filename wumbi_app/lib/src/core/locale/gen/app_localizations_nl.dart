// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appLanguage => 'Nederlands';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'Doorgaan';

  @override
  String get common_cancel => 'Annuleren';

  @override
  String get common_save => 'Opslaan';

  @override
  String get common_delete => 'Verwijderen';

  @override
  String get common_confirm => 'Bevestigen';

  @override
  String get common_undo => 'Ongedaan maken';

  @override
  String get common_ok => 'OK';

  @override
  String get common_retry => 'Opnieuw';

  @override
  String get common_today => 'Vandaag';

  @override
  String get common_yesterday => 'Gisteren';

  @override
  String get common_income => 'Inkomsten';

  @override
  String get common_expense => 'Uitgave';

  @override
  String get common_transfer => 'Overboeking';

  @override
  String get common_edit => 'Bewerken';

  @override
  String get common_all => 'Alle';

  @override
  String get common_clear => 'Wissen';

  @override
  String get common_apply => 'Toepassen';

  @override
  String get common_done => 'Klaar';

  @override
  String get common_close => 'Sluiten';

  @override
  String get common_search => 'Zoeken';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Dit is Wumbi';

  @override
  String get onboarding_welcome_subtitle =>
      'Geld bijhouden in seconden. Geen categorieën, alleen tags.';

  @override
  String get onboarding_currency_title => 'Je hoofdvaluta';

  @override
  String get onboarding_currency_subtitle =>
      'Totalen zie je in deze valuta. Je kunt dit later wijzigen in Instellingen.';

  @override
  String get onboarding_wallet_title => 'Je eerste portemonnee';

  @override
  String get onboarding_wallet_subtitle =>
      'Elke portemonnee heeft één valuta. Je kunt er later meer toevoegen.';

  @override
  String get onboarding_create_wallet => 'Portemonnee maken';

  @override
  String get common_skip => 'Overslaan';

  @override
  String get onboarding_welcome_start => 'Beginnen';

  @override
  String get onboarding_benefit_wallets_title => 'Portemonnees in elke valuta';

  @override
  String get onboarding_benefit_wallets_body =>
      'Dollars, euro\'s, bitcoin — elke portemonnee houdt zijn eigen valuta. Je totaal zie je in de valuta die jij kiest.';

  @override
  String get onboarding_benefit_tags_title => 'Tags, geen categorieën';

  @override
  String get onboarding_benefit_tags_body =>
      'Vergeet starre categorieën. Voeg elke tag toe die je wilt — #coffee, #trip, #work — en vind later alles terug.';

  @override
  String get onboarding_benefit_one_tap_title => 'Vastleggen met één tik';

  @override
  String get onboarding_benefit_one_tap_body =>
      'Typ het bedrag, tik op Inkomsten of Uitgave. Klaar. Het scherm blijft open voor de volgende.';

  @override
  String get onboarding_how_title => 'Hoe het werkt';

  @override
  String get onboarding_how_body =>
      'Maak een portemonnee, leg geld vast zodra het beweegt, en zie je totalen direct bijwerken.';

  @override
  String get onboarding_how_step_wallet => 'Portemonnee toevoegen';

  @override
  String get onboarding_how_step_tap => 'Tik om vast te leggen';

  @override
  String get onboarding_how_step_totals => 'Zie je totalen';

  @override
  String get onboarding_wallet_hero_prefix => 'Maak je eerste';

  @override
  String get onboarding_wallet_hero_accent => 'Portemonnee';

  @override
  String get onboarding_final_title => 'Je bent er klaar voor!';

  @override
  String get onboarding_final_body =>
      'Je eerste portemonnee staat klaar. Wumbi houdt de rest simpel.';

  @override
  String get onboarding_final_button => 'Aan de slag';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'Mijn geld';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count portemonnees',
      one: 'In 1 portemonnee',
      zero: 'Nog geen portemonnees',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes niet meegerekend';
  }

  @override
  String get dashboard_wallets => 'Portemonnees';

  @override
  String get dashboard_new_wallet => 'Nieuwe portemonnee';

  @override
  String get dashboard_empty_title => 'Maak je eerste portemonnee';

  @override
  String get dashboard_empty_subtitle =>
      'Wumbi heeft een portemonnee nodig om je geld in te bewaren.';

  @override
  String get dashboard_tags => 'Tags';

  @override
  String get dashboard_subscriptions => 'Abonnementen';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'Naam portemonnee';

  @override
  String get wallet_currency => 'Valuta';

  @override
  String get wallet_primary => 'Hoofdportemonnee';

  @override
  String get wallet_has_transactions => 'Heeft transacties';

  @override
  String get wallet_tab_transactions => 'Transacties';

  @override
  String get wallet_tab_budgets => 'Budgetten';

  @override
  String get wallet_tab_subscriptions => 'Abonnementen';

  @override
  String get wallet_budgets_empty =>
      'Nog geen uitgavenlimieten voor deze wallet';

  @override
  String get wallet_pick_another_primary => 'Kies een andere hoofdportemonnee';

  @override
  String wallet_delete_title(String name) {
    return '$name verwijderen?';
  }

  @override
  String get wallet_delete_message =>
      'De transacties worden verwijderd. Overboekingen met andere portemonnees blijven zichtbaar.';

  @override
  String get wallet_deleted => 'Portemonnee verwijderd';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Portemonnee verwijderd · $count herhalingen gepauzeerd',
      one: 'Portemonnee verwijderd · 1 herhaling gepauzeerd',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'Nog geen transacties';

  @override
  String get wallet_empty_subtitle => 'Tik op + om je eerste toe te voegen';

  @override
  String get wallet_switch_title => 'Portemonnee wisselen';

  @override
  String wallet_transfer_to(String name) {
    return 'Overboeken naar $name';
  }

  @override
  String wallet_transfer_from(String name) {
    return 'Overboeken van $name';
  }

  @override
  String get wallet_deleted_suffix => '(verwijderd)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count herhalend',
      one: '1 herhalend',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'Deze portemonnee bestaat niet meer';

  @override
  String get wallet_filter => 'Filter';

  @override
  String get wallet_sort => 'Sorteren';

  @override
  String get wallet_filter_title => 'Transacties filteren';

  @override
  String get wallet_filter_type => 'Type';

  @override
  String get wallet_filter_date => 'Datum';

  @override
  String get wallet_filter_tags => 'Tags';

  @override
  String get wallet_filter_from => 'Van';

  @override
  String get wallet_filter_to => 'Tot';

  @override
  String get wallet_filter_any_date => 'Elke datum';

  @override
  String get wallet_filter_this_month => 'Deze maand';

  @override
  String get wallet_filter_last_month => 'Vorige maand';

  @override
  String get wallet_filter_last_30_days => 'Laatste 30 dagen';

  @override
  String get wallet_filter_this_year => 'Dit jaar';

  @override
  String get wallet_filter_custom_range => 'Eigen periode';

  @override
  String get wallet_filter_upcoming_only => 'Alleen gepland';

  @override
  String get wallet_filter_clear => 'Filters wissen';

  @override
  String get wallet_filter_no_tags => 'Nog geen tags in deze portemonnee';

  @override
  String get wallet_filter_no_results_title => 'Niets gevonden';

  @override
  String get wallet_filter_no_results_subtitle =>
      'Probeer een filter te verwijderen.';

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
  String get wallet_sort_title => 'Sorteren op';

  @override
  String get sort_date_newest => 'Nieuwste eerst';

  @override
  String get sort_date_oldest => 'Oudste eerst';

  @override
  String get sort_amount_high => 'Hoogste bedrag';

  @override
  String get sort_amount_low => 'Laagste bedrag';

  @override
  String get wallet_upcoming_section => 'Gepland';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geplande transacties tellen nog niet mee',
      one: '1 geplande transactie telt nog niet mee',
    );
    return '$_temp0';
  }

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'Transactie bewerken';

  @override
  String get transaction_description_placeholder => 'omschrijving';

  @override
  String get transaction_tags_placeholder => '#tags';

  @override
  String get transaction_repeat => 'Herhalen';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · deel van een herhaling';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount wordt toegevoegd aan $wallet';
  }

  @override
  String transaction_hint_stale(String date) {
    return 'koers van $date';
  }

  @override
  String get transaction_rate_unavailable =>
      'Koers niet beschikbaar — maak verbinding';

  @override
  String transaction_saved(String amount, String wallet) {
    return '$amount opgeslagen in $wallet';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return '$amount verplaatst naar $wallet';
  }

  @override
  String get transaction_deleted => 'Transactie verwijderd';

  @override
  String get transaction_upcoming_badge => 'Gepland';

  @override
  String transaction_upcoming_hint(String date) {
    return 'Telt mee op $date';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return '$amount gepland voor $date';
  }

  @override
  String get transaction_delete_title => 'Deze transactie verwijderen?';

  @override
  String get transaction_delete_this_one => 'Alleen deze verwijderen';

  @override
  String get transaction_delete_and_stop => 'Verwijderen en herhaling stoppen';

  @override
  String get transaction_need_second_wallet_title =>
      'Maak een tweede portemonnee om over te boeken';

  @override
  String get transaction_need_second_wallet_message =>
      'Overboekingen verplaatsen geld tussen twee van je portemonnees.';

  @override
  String get transaction_different_currency => 'Andere valuta';

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
    return '$amount overboeken van $wallet';
  }

  @override
  String get transfer_amount_received => 'Ontvangen bedrag';

  @override
  String get transfer_confirm => 'Overboeking bevestigen';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'Nooit';

  @override
  String get repeat_every_day => 'Elke dag';

  @override
  String get repeat_every_week => 'Elke week';

  @override
  String get repeat_every_month => 'Elke maand';

  @override
  String get repeat_every_year => 'Elk jaar';

  @override
  String get repeat_daily => 'Dagelijks';

  @override
  String get repeat_weekly => 'Wekelijks';

  @override
  String get repeat_monthly => 'Maandelijks';

  @override
  String get repeat_yearly => 'Jaarlijks';

  @override
  String get repeat_rules_title => 'Abonnementen';

  @override
  String get repeat_rules_hint =>
      'Tik op een abonnement om het te bewerken. Bestaande transacties veranderen nooit.';

  @override
  String repeat_next(String date) {
    return 'Volgende: $date';
  }

  @override
  String get repeat_paused => 'Gepauzeerd';

  @override
  String get repeat_delete_title => 'Deze herhaling stoppen?';

  @override
  String get repeat_delete_message =>
      'Bestaande transacties blijven. Er worden geen nieuwe aangemaakt.';

  @override
  String get repeat_stop => 'Stoppen';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'Kies een datum';

  @override
  String get date_pick_from => 'Van';

  @override
  String get date_pick_to => 'Tot';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'Zoeken';

  @override
  String get search_placeholder => 'Omschrijving, bedrag, portemonnee of tag';

  @override
  String get search_hint =>
      'Doorzoek alle portemonnees op omschrijving, bedrag, naam of tag.';

  @override
  String get search_no_results_title => 'Niets gevonden';

  @override
  String get search_no_results_subtitle =>
      'Probeer een ander woord, bedrag of tag.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultaten',
      one: '1 resultaat',
    );
    return '$_temp0';
  }

  @override
  String get l10nTags =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TAGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get tags_title => 'Tags';

  @override
  String get tags_view_list => 'Lijst';

  @override
  String get tags_view_graph => 'Kaart';

  @override
  String get tags_search_placeholder => 'Tags zoeken';

  @override
  String get tags_empty_title => 'Nog geen tags';

  @override
  String get tags_empty_subtitle =>
      'Voeg #tags toe aan een transactie en ze verschijnen hier.';

  @override
  String get tags_search_no_results => 'Geen tags gevonden';

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
      other: '$count transacties',
      one: '1 transactie',
      zero: 'Nog niet gebruikt',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'Uitgegeven';

  @override
  String get tags_earned => 'Verdiend';

  @override
  String get tags_net => 'Netto';

  @override
  String tags_not_included(String codes) {
    return '$codes niet meegerekend';
  }

  @override
  String get tags_graph_hint =>
      'Grotere cirkels verplaatsten meer geld. Lijnen verbinden tags die samen gebruikt zijn.';

  @override
  String get tags_graph_empty =>
      'Voeg tags toe aan een paar transacties om de kaart te zien.';

  @override
  String get tag_wallets => 'Portemonnees';

  @override
  String get tag_transactions => 'Transacties';

  @override
  String get tag_no_transactions => 'Geen transacties met deze tag';

  @override
  String get tag_rename => 'Tag hernoemen';

  @override
  String get tag_name_placeholder => 'Tagnaam';

  @override
  String get tag_delete => 'Tag verwijderen';

  @override
  String tag_delete_title(String name) {
    return '#$name verwijderen?';
  }

  @override
  String get tag_delete_message =>
      'De tag wordt uit elke transactie verwijderd. De transacties zelf blijven.';

  @override
  String get tag_deleted => 'Tag verwijderd';

  @override
  String get tag_renamed => 'Tag hernoemd';

  @override
  String tag_merged(String name) {
    return 'Samengevoegd met #$name';
  }

  @override
  String get tag_not_found => 'Deze tag bestaat niet meer';

  @override
  String get tag_wallet_deleted => '(verwijderd)';

  @override
  String get tags_new => 'Nieuwe tag';

  @override
  String get tags_create => 'Tag maken';

  @override
  String tags_created(String name) {
    return '#$name gemaakt';
  }

  @override
  String tags_exists(String name) {
    return '#$name bestaat al';
  }

  @override
  String get tags_parent => 'Bovenliggende tag';

  @override
  String get tags_parent_none => 'Geen';

  @override
  String get tags_name_hint => 'bijv. koffie';

  @override
  String get tags_create_tip =>
      'Tip: typ eten/koffie om een tag meteen te nesten.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genest',
      one: '1 genest',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'Hoe gebruik je tags?';

  @override
  String get tags_graph_mode_all => 'Alles';

  @override
  String get tags_graph_mode_spending => 'Uitgaven';

  @override
  String get tags_graph_mode_income => 'Inkomsten';

  @override
  String get tags_graph_legend_size => 'Groter = meer geld';

  @override
  String get tags_graph_legend_nested => 'Genest';

  @override
  String get tags_graph_legend_together => 'Samen gebruikt';

  @override
  String get tags_graph_tap_hint => 'Tik op een cirkel om de cijfers te zien';

  @override
  String get tags_graph_open => 'Openen';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gekoppeld aan $count tags',
      one: 'Gekoppeld aan 1 tag',
      zero: 'Nog geen koppelingen',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'Verplaatsen';

  @override
  String tag_move_title(String name) {
    return '#$name verplaatsen';
  }

  @override
  String get tag_moved => 'Tag verplaatst';

  @override
  String get tag_add_nested => 'Geneste tag toevoegen';

  @override
  String get tag_nested_tags => 'Geneste tags';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bevat $count geneste tags',
      one: 'Bevat 1 geneste tag',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Deze tag en zijn $count geneste tags worden van alle transacties verwijderd. De transacties zelf blijven.',
      one:
          'Deze tag en zijn geneste tag worden van alle transacties verwijderd. De transacties zelf blijven.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'Geneste tags worden ook hernoemd. Gebruik / om hem onder een andere tag te zetten.';

  @override
  String get tag_top_level => 'Hoogste niveau';

  @override
  String get tag_nested_empty => 'Nog geen geneste tags';

  @override
  String get settings_help => 'Hulp nodig?';

  @override
  String get help_title => 'Hulp nodig?';

  @override
  String get help_subtitle => 'Korte gidsen om alles uit Wumbi te halen.';

  @override
  String get help_tags_title => 'Hoe gebruik je tags?';

  @override
  String get help_tags_subtitle => 'Labels, geneste tags en de kaart';

  @override
  String get help_tags_intro =>
      'Tags zijn korte labels zoals #koffie die je aan transacties toevoegt. Een transactie kan meerdere tags hebben, zodat je je geld vanuit elke hoek bekijkt – niet alleen per portemonnee.';

  @override
  String get help_tags_add_title => 'Een tag toevoegen';

  @override
  String get help_tags_add_body =>
      'Typ bij het invoeren van een transactie een naam in het tagveld en kies een suggestie of maak een nieuwe. Tags hebben geen spaties – schrijf coffee-shop of coffee_shop. Hoofd- en kleine letters geven dezelfde tag.';

  @override
  String get help_tags_nested_title => 'Geneste tags';

  @override
  String get help_tags_nested_body =>
      'Gebruik een schuine streep / om een tag in een andere te zetten, zoals mappen: eten/koffie en eten/boodschappen staan allebei in eten. De bovenliggende tag wordt voor je gemaakt.';

  @override
  String get help_tags_parent_title =>
      'Een bovenliggende tag bevat zijn geneste tags';

  @override
  String get help_tags_parent_body =>
      '#eten openen toont elke transactie met #eten, #eten/koffie of #eten/boodschappen. Totalen, filters en budgetten van een bovenliggende tag tellen zijn geneste tags mee. Een transactie met beide tags telt maar één keer.';

  @override
  String get help_tags_multi_title => 'Meerdere tags op één transactie';

  @override
  String get help_tags_multi_body =>
      'Een diner op vakantie kan tegelijk #reizen en #eten/restaurant zijn. Het telt dan in allebei, en de twee tags worden verbonden op de kaart.';

  @override
  String get help_tags_manage_title => 'Maken, hernoemen, verplaatsen';

  @override
  String get help_tags_manage_body =>
      'Tik op de Tags-pagina op + om een tag te maken en kies een bovenliggende tag om hem te nesten. Open een tag om hem te hernoemen, onder een andere tag te zetten, een geneste tag toe te voegen of te verwijderen. Hernoem je een bovenliggende tag, dan volgen zijn geneste tags; hernoem je hem naar een bestaande tag, dan worden ze samengevoegd.';

  @override
  String get help_tags_map_title => 'De kaart lezen';

  @override
  String get help_tags_map_body =>
      'Elke cirkel is een tag: hoe groter, hoe meer geld erdoorheen ging. De ring toont het aandeel uitgaven en inkomsten. Doorgetrokken lijnen verbinden een bovenliggende tag met zijn geneste tags, vage lijnen verbinden tags op dezelfde transactie. Tik op een cirkel om de cijfers te zien.';

  @override
  String get help_tags_tips_title => 'Tips';

  @override
  String get help_tags_tip1 =>
      'Begin breed – eten, huis, vervoer – en nest alleen als je meer detail wilt.';

  @override
  String get help_tags_tip2 =>
      'Gebruik tags voor wat over portemonnees heen gaat: #vakantie, #cadeaus, #auto.';

  @override
  String get help_tags_tip3 =>
      'Houd namen kort; twee of drie niveaus is genoeg.';

  @override
  String get help_tags_example => 'Voorbeeld';

  @override
  String get help_tags_example_total => 'Totaal voor #eten';

  @override
  String get help_tags_ex_parent => 'eten';

  @override
  String get help_tags_ex_child1 => 'koffie';

  @override
  String get help_tags_ex_child2 => 'boodschappen';

  @override
  String get help_tags_ex_travel => 'reizen';

  @override
  String get help_tags_ex_restaurant => 'restaurant';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'Abonnementen';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnementen',
      one: '1 abonnement',
      zero: 'Geen abonnementen',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'Nog geen abonnementen';

  @override
  String get subscriptions_empty_subtitle =>
      'Zet Herhalen aan bij een transactie en die verschijnt hier.';

  @override
  String get subscriptions_all_wallets => 'Alle portemonnees';

  @override
  String get subscriptions_active => 'Actief';

  @override
  String get subscriptions_paused => 'Gepauzeerd';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / maand';
  }

  @override
  String get subscriptions_edit_title => 'Abonnement bewerken';

  @override
  String get subscriptions_amount => 'Bedrag';

  @override
  String get subscriptions_wallet => 'Portemonnee';

  @override
  String get subscriptions_from_wallet => 'Van portemonnee';

  @override
  String get subscriptions_to_wallet => 'Naar portemonnee';

  @override
  String get subscriptions_frequency => 'Frequentie';

  @override
  String get subscriptions_description => 'Omschrijving';

  @override
  String get subscriptions_tags => 'Tags';

  @override
  String get subscriptions_pause => 'Pauzeren';

  @override
  String get subscriptions_resume => 'Hervatten';

  @override
  String get subscriptions_stop => 'Abonnement stoppen';

  @override
  String get subscriptions_saved => 'Abonnement bijgewerkt';

  @override
  String get subscriptions_stopped => 'Abonnement gestopt';

  @override
  String get subscriptions_type_hint =>
      'Het type van een abonnement kan niet veranderen.';

  @override
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'Voortgang';

  @override
  String get progress_by_day => 'Dag voor dag';

  @override
  String get progress_by_month => 'Maand voor maand';

  @override
  String get progress_other => 'Overig';

  @override
  String get progress_month => 'Maand';

  @override
  String get progress_year => 'Jaar';

  @override
  String get progress_income => 'Inkomsten';

  @override
  String get progress_all_wallets => 'Alle portemonnees';

  @override
  String get progress_scope_title => 'Gegevens tonen voor';

  @override
  String progress_not_included(String codes) {
    return '$codes niet meegerekend';
  }

  @override
  String get progress_empty_title => 'Nog niets te analyseren';

  @override
  String get progress_untagged => 'Zonder tag';

  @override
  String get progress_no_expenses => 'Geen uitgaven in deze periode';

  @override
  String get progress_empty_subtitle =>
      'Voeg een paar transacties toe en je voortgang verschijnt hier.';

  @override
  String get progress_spent => 'Uitgegeven';

  @override
  String get progress_spending => 'Uitgaven';

  @override
  String get progress_saved => 'Gespaard';

  @override
  String get progress_overspent => 'Te veel uitgegeven';

  @override
  String progress_vs(String label) {
    return 't.o.v. $label';
  }

  @override
  String progress_kept_share(int percent) {
    return 'Je hield $percent% van je inkomsten over';
  }

  @override
  String progress_overspent_by(String amount) {
    return 'Je gaf $amount meer uit dan je verdiende';
  }

  @override
  String progress_nothing_in(String period) {
    return 'Geen transacties in $period';
  }

  @override
  String get progress_compare_title => 'Vergelijken met';

  @override
  String get progress_baseline_previous_month => 'Vorige maand';

  @override
  String get progress_baseline_previous_year => 'Vorig jaar';

  @override
  String get progress_baseline_last_year => 'Zelfde maand vorig jaar';

  @override
  String progress_baseline_average_months(int count) {
    return 'Gemiddelde van de laatste $count maanden';
  }

  @override
  String progress_baseline_average_years(int count) {
    return 'Gemiddelde van de laatste $count jaar';
  }

  @override
  String get progress_baseline_pick_month => 'Kies een maand';

  @override
  String get progress_baseline_pick_year => 'Kies een jaar';

  @override
  String progress_average_months(int count) {
    return 'het $count-maands gemiddelde';
  }

  @override
  String progress_average_years(int count) {
    return 'het $count-jaars gemiddelde';
  }

  @override
  String get progress_pace_title => 'Uitgaventempo';

  @override
  String progress_pace_less(String amount, String baseline) {
    return '$amount minder dan $baseline op dit moment';
  }

  @override
  String progress_pace_more(String amount, String baseline) {
    return '$amount meer dan $baseline op dit moment';
  }

  @override
  String progress_pace_same(String baseline) {
    return 'Zelfde tempo als $baseline';
  }

  @override
  String progress_total_less(String amount, String baseline) {
    return '$amount minder dan $baseline';
  }

  @override
  String progress_total_more(String amount, String baseline) {
    return '$amount meer dan $baseline';
  }

  @override
  String progress_total_same(String baseline) {
    return 'Ongeveer gelijk aan $baseline';
  }

  @override
  String progress_forecast_month(String amount) {
    return 'In dit tempo ≈ $amount aan het eind van de maand';
  }

  @override
  String progress_forecast_year(String amount) {
    return 'In dit tempo ≈ $amount aan het eind van het jaar';
  }

  @override
  String progress_day(int day) {
    return 'Dag $day';
  }

  @override
  String get progress_changes_title => 'Wat is er veranderd';

  @override
  String progress_now_was(String now, String was) {
    return 'nu $now · was $was';
  }

  @override
  String get progress_new => 'Nieuw';

  @override
  String get progress_breakdown_title => 'Per tag';

  @override
  String get progress_no_income => 'Geen inkomsten in deze periode';

  @override
  String progress_show_all(int count) {
    return 'Alles tonen ($count)';
  }

  @override
  String get progress_show_less => 'Minder tonen';

  @override
  String get progress_overlap_hint =>
      'Een transactie met tags uit meerdere groepen telt in elke groep mee.';

  @override
  String get progress_habits_title => 'Gewoontes';

  @override
  String get progress_daily_average => 'Daggemiddelde';

  @override
  String get progress_biggest_expense => 'Grootste uitgave';

  @override
  String get progress_recurring => 'Terugkerende betalingen';

  @override
  String progress_recurring_share(int percent) {
    return '$percent% van je uitgaven';
  }

  @override
  String get progress_average_expense => 'Gemiddelde uitgave';

  @override
  String progress_peak_weekday(String weekday) {
    return 'Je geeft het meest uit op $weekday';
  }

  @override
  String get progress_weekday_hint => 'Gemiddelde uitgaven per weekdag';

  @override
  String progress_history_months(int count) {
    return 'Laatste $count maanden';
  }

  @override
  String progress_history_years(int count) {
    return 'Laatste $count jaar';
  }

  @override
  String progress_average_per_month(String amount) {
    return 'Gemiddeld $amount per maand';
  }

  @override
  String progress_average_per_year(String amount) {
    return 'Gemiddeld $amount per jaar';
  }

  @override
  String progress_to_date_hint(String baseline) {
    return 'Vergeleken met dezelfde dagen van $baseline';
  }

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Valuta';

  @override
  String get currency_no_results => 'Geen valuta gevonden';

  @override
  String get currency_base_title => 'Hoofdvaluta';

  @override
  String get currency_base_hint =>
      'Je totale saldo wordt omgerekend naar deze valuta.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'Instellingen';

  @override
  String get settings_preferences => 'Voorkeuren';

  @override
  String get settings_notifications => 'Meldingen';

  @override
  String get settings_currency => 'Valuta';

  @override
  String get settings_dark_mode => 'Donkere modus';

  @override
  String get settings_show_mascot => 'Mascotte tonen';

  @override
  String get settings_data_privacy => 'Gegevens en privacy';

  @override
  String get settings_export_transactions => 'Transacties exporteren';

  @override
  String get settings_reset_all_data => 'Alle gegevens wissen';

  @override
  String get settings_reset_title => 'Alle gegevens wissen?';

  @override
  String get settings_reset_message =>
      'Elke portemonnee, transactie en instelling op dit apparaat wordt gewist. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get settings_reset_action => 'Wissen';

  @override
  String get settings_reset_done => 'Alle gegevens verwijderd';

  @override
  String settings_version(String version, String build) {
    return 'Versie: $version ($build)';
  }

  @override
  String get settings_language => 'Taal';

  @override
  String get settings_manage => 'Beheren';

  @override
  String get settings_tags => 'Tags';

  @override
  String get settings_subscriptions => 'Abonnementen';

  @override
  String get settings_language_info => 'Kies je voorkeurstaal voor de app.';

  @override
  String get settings_theme => 'Thema';

  @override
  String get settings_theme_system => 'Systeem';

  @override
  String get settings_theme_light => 'Licht';

  @override
  String get settings_theme_dark => 'Donker';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'Over Wumbi';

  @override
  String get about_project => 'Over het project';

  @override
  String get about_text =>
      'Wumbi houdt je geld op je telefoon. Typ het bedrag, tik op Inkomsten of Uitgave, klaar. Geen account nodig, en er wordt niets geüpload tenzij je het aanzet.';

  @override
  String get about_support => 'Contact opnemen';

  @override
  String get about_read_more => 'Lees meer op wumbi.app';

  @override
  String get settings_about_section => 'Over Wumbi';

  @override
  String get settings_privacy_policy => 'Privacybeleid';

  @override
  String get settings_terms => 'Gebruiksvoorwaarden';

  @override
  String get settings_press => 'Perskit';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'Voer een bedrag in';

  @override
  String validation_up_to_tags(int count) {
    return 'Maximaal $count tags';
  }

  @override
  String get validation_rate_unavailable => 'Koers niet beschikbaar';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'Databasefout, probeer het opnieuw.';

  @override
  String get error_unknown => 'Er ging iets mis. Probeer het opnieuw.';

  @override
  String get error_rate_unavailable =>
      'Geen wisselkoers beschikbaar. Maak verbinding met internet en probeer het opnieuw.';

  @override
  String get error_validation => 'Controleer de ingevoerde waarden.';

  @override
  String get error_wallet_has_transactions =>
      'De valuta kan niet meer wijzigen zodra een portemonnee transacties heeft.';

  @override
  String get error_not_found => 'Dit item bestaat niet meer.';

  @override
  String debt_error_owes_you_only(String name, String amount) {
    return '$name is je maar $amount schuldig';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return 'Je bent $name maar $amount schuldig';
  }

  @override
  String get person_error_has_debts =>
      'Vereffen of verwijder eerst de schulden van deze persoon.';

  @override
  String get debt_error_closed => 'Deze schuld is al vereffend.';

  @override
  String get error_tag_name => 'Voer een tagnaam in (maximaal 30 tekens).';

  @override
  String get error_open_db_title => 'Kan je gegevens niet openen';

  @override
  String get error_open_db_message =>
      'Wumbi kon de database op dit apparaat niet ontgrendelen.';

  @override
  String get error_reset_app => 'App resetten';

  @override
  String get dashboard_budgets => 'Budgetten';

  @override
  String get budget_new => 'Nieuw budget';

  @override
  String get budget_empty_hint =>
      'Stel een uitgavelimiet in voor een portemonnee of een #tag';

  @override
  String get budgets_all => 'Alle budgetten';

  @override
  String get budgets_title => 'Budgetten';

  @override
  String budget_left(String amount) {
    return '$amount over';
  }

  @override
  String budget_over(String amount) {
    return '$amount te veel';
  }

  @override
  String budget_starts(String date) {
    return 'Begint $date';
  }

  @override
  String get budget_ended => 'Afgelopen';

  @override
  String budget_per_day(String amount) {
    return '$amount/dag';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return '$spent van $limit uitgegeven';
  }

  @override
  String get budget_this_week => 'Deze week';

  @override
  String get budget_set_limit => 'Uitgavelimiet instellen';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name: $amount over';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name: $amount te veel';
  }

  @override
  String get budget_all_spending => 'Alle uitgaven';

  @override
  String get budget_name => 'Naam';

  @override
  String get budget_name_placeholder => 'naam';

  @override
  String budget_name_hint(String name) {
    return 'Budgetnaam: $name';
  }

  @override
  String get budget_what_counts => 'Wat telt';

  @override
  String get budget_wallets => 'Portemonnees';

  @override
  String get budget_all_wallets => 'Alle portemonnees';

  @override
  String get budget_tags => 'Tags';

  @override
  String get budget_any_tag => 'Elke tag';

  @override
  String get budget_scope_all => 'Telt elke uitgave.';

  @override
  String budget_scope_wallets(String wallets) {
    return 'Telt uitgaven uit $wallets.';
  }

  @override
  String budget_scope_tags(String tags) {
    return 'Telt uitgaven met tag $tags.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return 'Telt uitgaven uit $wallets met tag $tags.';
  }

  @override
  String get budget_scope_or => 'of';

  @override
  String get budget_period_section => 'Periode';

  @override
  String get budget_repeats => 'Herhaling';

  @override
  String get budget_period_weekly => 'Wekelijks';

  @override
  String get budget_period_monthly => 'Maandelijks';

  @override
  String get budget_period_yearly => 'Jaarlijks';

  @override
  String get budget_period_custom => 'Eenmalig';

  @override
  String get budget_starts_on => 'Begint op';

  @override
  String get budget_first_day => 'Eerste dag';

  @override
  String get budget_last_day => 'Laatste dag';

  @override
  String budget_day_of_month(int day) {
    return 'Dag $day';
  }

  @override
  String get budget_start_day_title => 'Startdag';

  @override
  String get budget_start_day_hint =>
      'Kortere maanden beginnen op hun laatste dag.';

  @override
  String get budget_start_weekday_title => 'Eerste dag van de week';

  @override
  String get budget_carry_over => 'Overdragen';

  @override
  String get budget_rollover_none => 'Niet overdragen';

  @override
  String get budget_rollover_surplus => 'Rest overdragen';

  @override
  String get budget_rollover_both => 'Rest en overschrijding overdragen';

  @override
  String get budget_count_planned => 'Gepland meetellen';

  @override
  String get budget_count_planned_hint => 'Inclusief gepland en abonnementen';

  @override
  String get budget_count_planned_desc =>
      'Geplande betalingen en abonnementen tellen al mee voor het limiet vóór betaling.';

  @override
  String budget_suggested_months(String amount) {
    return 'Voorstel: $amount · gem. laatste 3 maanden';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'Voorstel: $amount · gem. laatste 3 weken';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'Voorstel: $amount · gem. laatste 3 jaar';
  }

  @override
  String get budget_deleted => 'Budget verwijderd';

  @override
  String budget_delete_title(String name) {
    return '$name verwijderen?';
  }

  @override
  String get budget_delete_message => 'Je transacties blijven ongewijzigd.';

  @override
  String get budget_error_name => 'Naam tot 40 tekens';

  @override
  String get budget_error_dates => 'De laatste dag moet na de eerste komen';

  @override
  String get budget_left_caption => 'over';

  @override
  String get budget_over_caption => 'te veel';

  @override
  String get budget_under_caption => 'onder budget';

  @override
  String budget_spent(String amount) {
    return 'Uitgegeven $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'Gepland $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'Limiet $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount overgedragen';
  }

  @override
  String get budget_on_track => 'Op schema';

  @override
  String budget_ahead_of_pace(String amount) {
    return '$amount voor op schema';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return '$amount sneller dan gepland';
  }

  @override
  String budget_forecast(String amount) {
    return 'prognose $amount';
  }

  @override
  String get budget_no_spending => 'Nog geen uitgaven deze periode';

  @override
  String get budgets_active => 'Actief';

  @override
  String get budgets_upcoming => 'Gepland';

  @override
  String get budgets_empty_title => 'Nog geen budgetten';

  @override
  String get budgets_empty_subtitle =>
      'Stel een limiet in en zie wat er over is';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count andere budgetten',
      one: '+1 ander budget',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen',
      one: '1 dag',
    );
    return '$amount/dag voor $_temp0';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnementen',
      one: '1 abonnement',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afgelopen ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgetten verwijderd',
      one: '1 budget verwijderd',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'Schulden';

  @override
  String get debts_owed_to_me => 'Te ontvangen';

  @override
  String get debts_i_owe => 'Ik ben schuldig';

  @override
  String get debts_empty_owed_title => 'Niemand is je iets schuldig';

  @override
  String get debts_empty_owe_title => 'Je bent niemand iets schuldig';

  @override
  String get debts_empty_subtitle =>
      'Tik op „Nieuwe schuld”, of gebruik Overboeking → Schulden op het transactiescherm';

  @override
  String get debt_new => 'Nieuwe schuld';

  @override
  String get debt_edit_title => 'Schuld bewerken';

  @override
  String get debts_all => 'Alle schulden';

  @override
  String get debts_empty_hint => 'Houd bij wat je hebt uitgeleend of geleend';

  @override
  String get dashboard_reorder_hint => 'Vasthouden om te ordenen';

  @override
  String dashboard_debts_to_receive(String amount) {
    return '$amount te ontvangen';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return '$amount terug te betalen';
  }

  @override
  String get dashboard_new => 'Nieuw';

  @override
  String get debt_they_owe_me => 'Ik krijg geld';

  @override
  String get debt_i_owe_them => 'Ik ben schuldig';

  @override
  String get debt_person => 'Wie';

  @override
  String get debt_person_chip => 'Wie';

  @override
  String get debt_person_title => 'Met wie?';

  @override
  String get debt_person_search => 'Naam — persoon, bank, winkel…';

  @override
  String get debt_person_empty => 'Nog niemand — typ een naam';

  @override
  String get debt_person_none => 'Niemand';

  @override
  String get debt_choose => 'Kiezen';

  @override
  String get debt_amount => 'Bedrag';

  @override
  String get debt_note_hint => 'Notitie (optioneel)';

  @override
  String get debt_note_placeholder => 'notitie';

  @override
  String get debt_due_date => 'Vervaldatum';

  @override
  String get debt_due_title => 'Vervaldatum';

  @override
  String get debt_add_due => 'Vervaldatum';

  @override
  String get debt_due_change => 'Datum wijzigen';

  @override
  String get debt_due_remove => 'Vervaldatum verwijderen';

  @override
  String get debt_none => 'Geen';

  @override
  String get debt_money_moved => 'Geld verplaatst';

  @override
  String get debt_not_in_wallet => 'Niet via een portemonnee';

  @override
  String get debt_error_person => 'Kies met wie';

  @override
  String get debt_gave => 'Gegeven';

  @override
  String get debt_got => 'Gekregen';

  @override
  String get debt_badge_loan => 'Lening';

  @override
  String get debt_badge_return => 'Terugbetaling';

  @override
  String get debt_overdue => 'te laat';

  @override
  String get debt_settled_label => 'Vereffend';

  @override
  String get debt_forgiven_label => 'Kwijtgescholden';

  @override
  String get debt_returned_in_full => 'Volledig terugbetaald';

  @override
  String get debt_paid_in_full => 'Volledig betaald';

  @override
  String get debt_part => 'Deel';

  @override
  String get debt_forgive => 'Kwijtschelden';

  @override
  String get debt_remind => 'Herinneren';

  @override
  String get debt_history => 'Geschiedenis';

  @override
  String get debt_edit_note => 'Notitie bewerken';

  @override
  String get debt_rename_person => 'Hernoemen';

  @override
  String get debt_delete => 'Schuld verwijderen';

  @override
  String get debt_delete_title => 'Deze schuld verwijderen?';

  @override
  String get debt_deleted => 'Schuld verwijderd';

  @override
  String get debt_payment_deleted => 'Betaling verwijderd';

  @override
  String get debt_return_deleted => 'Terugbetaling verwijderd';

  @override
  String debt_due(String date) {
    return 'vervalt $date';
  }

  @override
  String debt_left(String amount) {
    return '$amount open';
  }

  @override
  String debt_left_of(String amount) {
    return 'open van $amount';
  }

  @override
  String debt_of(String amount) {
    return 'van $amount';
  }

  @override
  String debt_to_wallet(String wallet) {
    return 'naar $wallet';
  }

  @override
  String debt_from_wallet(String wallet) {
    return 'van $wallet';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name is je $amount schuldig';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return 'Je bent $name $amount schuldig';
  }

  @override
  String debt_overall(String text) {
    return 'In totaal: $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'In totaal: $name is je $owed schuldig · jij $owe';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name is je $amount schuldig · „Gekregen“ telt als terugbetaling';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return 'Je bent $name $amount schuldig · „Gegeven“ telt als terugbetaling';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name is je $owed schuldig · jij $owe';
  }

  @override
  String debt_hint_none(String name) {
    return 'Geen open schulden met $name · „Gegeven“ leent uit, „Gekregen“ leent';
  }

  @override
  String debt_person_add(String name) {
    return '„$name“ toevoegen';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'is je $amount schuldig';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'je bent $amount schuldig';
  }

  @override
  String debt_title_lent_to(String name) {
    return 'Uitgeleend aan $name';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return 'Geleend van $name';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name heeft terugbetaald';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return '$name terugbetaald';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return '$amount uitgeleend aan $name';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return '$amount geleend van $name';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name gaf $amount terug · $left open';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name gaf $amount terug · alles vereffend';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return '$amount terugbetaald aan $name · $left open';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return '$amount terugbetaald aan $name · alles vereffend';
  }

  @override
  String debt_forgive_title(String name) {
    return '$name kwijtschelden?';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'De resterende $amount wordt kwijtgescholden. Er wordt geen geld verplaatst.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'Schuld kwijtgescholden · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'Hoi $name! Even een herinnering aan $amount voor $note ($date). Bedankt!';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'Hoi $name! Even een herinnering aan $amount ($date). Bedankt!';
  }

  @override
  String debt_history_lent(String amount) {
    return '$amount uitgeleend';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return '$amount uitgeleend van $wallet';
  }

  @override
  String debt_history_borrowed(String amount) {
    return '$amount geleend';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return '$amount geleend naar $wallet';
  }

  @override
  String debt_history_returned(String amount) {
    return '$amount terugbetaald';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return '$amount terug → $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return '$amount terugbetaald';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return '$amount terugbetaald van $wallet';
  }

  @override
  String debt_history_forgiven(String amount) {
    return '$amount kwijtgescholden';
  }

  @override
  String debts_overdue_count(int count) {
    return '$count te laat';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schulden',
      one: '1 schuld',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personen',
      one: '1 persoon',
      zero: 'Niemand',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vereffend ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lening verwijderd met $count terugbetalingen',
      one: 'Lening verwijderd met 1 terugbetaling',
      zero: 'Lening verwijderd',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transacties worden ook verwijderd.',
      one: '1 transactie wordt ook verwijderd.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'Nieuw abonnement';

  @override
  String subscriptions_active_count(int count) {
    return '$count actief';
  }

  @override
  String subscriptions_paused_count(int count) {
    return '$count gepauzeerd';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'Stel een uitgavelimiet in om deze portemonnee onder controle te houden.';

  @override
  String get wallet_include_in_total => 'Meetellen in totaalsaldo';

  @override
  String get wallet_include_in_total_on =>
      'Het saldo van deze portemonnee telt mee in het totaal op het startscherm.';

  @override
  String get wallet_include_in_total_off =>
      'Telt niet mee in het totaal op het startscherm — handig voor spaargeld, gedeelde of alleen-bijhouden-portemonnees.';

  @override
  String get dashboard_wallets_not_counted => 'Niet in totaalsaldo';

  @override
  String dashboard_wallets_excluded(int count) {
    return '$count niet meegeteld';
  }

  @override
  String get budget_rollover_none_desc =>
      'Elke periode begint opnieuw met dezelfde limiet. Rest en overschrijding gaan niet mee.';

  @override
  String get budget_rollover_surplus_desc =>
      'Wat je niet hebt uitgegeven, komt bij de limiet van de volgende periode.';

  @override
  String get budget_rollover_both_desc =>
      'Een rest verhoogt de volgende limiet, een overschrijding verlaagt die.';

  @override
  String get budget_planned_title => 'Geplande betalingen';

  @override
  String get budget_planned_exclude => 'Gepland niet meetellen';

  @override
  String get budget_planned_exclude_desc =>
      'Alleen betalingen die al gedaan zijn tellen mee voor het limiet. Geplande betalingen en abonnementen tellen pas mee na betaling.';

  @override
  String budget_used_percent(int percent) {
    return '$percent% gebruikt';
  }

  @override
  String get budget_stat_spent => 'Uitgegeven';

  @override
  String get budget_stat_limit => 'Limiet';

  @override
  String get budget_stat_planned => 'Gepland';

  @override
  String get budget_stat_per_day => 'Per dag';

  @override
  String get budget_stat_forecast => 'Prognose';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nog $count dagen',
      one: 'nog 1 dag',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_monthly_spend => 'Maandelijkse uitgaven';

  @override
  String get subscriptions_active_empty => 'Geen actieve abonnementen';

  @override
  String get subscriptions_paused_empty => 'Geen gepauzeerde abonnementen';

  @override
  String budgets_summary_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Je zit boven $count budgetten',
      one: 'Je zit boven 1 budget',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_close(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgetten zijn bijna op',
      one: '1 budget is bijna op',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_ok(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Je blijft binnen je budgetten',
      one: 'Je blijft binnen je budget',
    );
    return '$_temp0';
  }

  @override
  String get budget_edit_title => 'Budget bewerken';

  @override
  String get wallet_edit_title => 'Portemonnee bewerken';

  @override
  String get budget_tab_overview => 'Overzicht';

  @override
  String get budget_back_to_current => 'Terug naar vandaag';

  @override
  String get budget_row_starts => 'Begint op';

  @override
  String debt_story_lent_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return '$name is je nog $left schuldig van de $total die je op $date hebt uitgeleend.';
  }

  @override
  String debt_story_borrowed_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return 'Je bent $name nog $left schuldig van de $total die je op $date hebt geleend.';
  }

  @override
  String debt_story_lent_settled(String name, String total, String date) {
    return '$name heeft de $total van $date volledig terugbetaald.';
  }

  @override
  String debt_story_borrowed_settled(String name, String total, String date) {
    return 'Je hebt de $total die je op $date van $name leende volledig terugbetaald.';
  }

  @override
  String debt_story_forgiven(String total, String date) {
    return 'Gesloten op $date — de rest van de $total is kwijtgescholden.';
  }

  @override
  String get debt_stat_lent => 'Uitgeleend';

  @override
  String get debt_stat_borrowed => 'Geleend';

  @override
  String get debt_stat_paid_back => 'Terugbetaald';

  @override
  String get debt_stat_date => 'Datum';

  @override
  String get debt_stat_due => 'Vervaldatum';

  @override
  String get debt_note => 'Notitie';

  @override
  String get debt_add_note => 'Notitie toevoegen';

  @override
  String get debt_got_part_back => 'Deel terug';

  @override
  String get debt_paid_part => 'Deel betaald';

  @override
  String get debt_section_details => 'Details';

  @override
  String get debts_to_receive => 'Te ontvangen';

  @override
  String get debts_to_pay => 'Terug te betalen';

  @override
  String get debts_settled_empty => 'Nog geen afgeloste schulden';

  @override
  String get transfer_debt_pay_back => 'Terugbetalen';

  @override
  String get transfer_debt_lend => 'Uitlenen';

  @override
  String get transfer_debt_lend_someone => 'Uitlenen aan…';

  @override
  String transfer_debt_lend_to(String name) {
    return 'Uitlenen aan $name';
  }

  @override
  String transfer_debt_only_left(String amount) {
    return 'Nog maar $amount open';
  }

  @override
  String get transfer_debt_locked =>
      'Een schuld kan niet herhalen of in de toekomst liggen';

  @override
  String transfer_debt_summary_repay(
    String wallet,
    String amount,
    String name,
  ) {
    return '$wallet −$amount → betaalt $name terug';
  }

  @override
  String transfer_debt_summary_lend(String wallet, String amount, String name) {
    return '$wallet −$amount → uitgeleend aan $name';
  }

  @override
  String get debt_wallet_title_in => 'Waar is het geld terechtgekomen?';

  @override
  String get debt_wallet_title_out => 'Waarmee heb je betaald?';

  @override
  String debt_wallet_explain_in(String name, String amount) {
    return '$name heeft je $amount terugbetaald. In welke portemonnee kwam het? We tellen het daar bij op. Was het contant geld dat je niet bijhoudt, kies dan „Niet via een portemonnee”.';
  }

  @override
  String debt_wallet_explain_out(String name, String amount) {
    return 'Je betaalt $name $amount terug. Uit welke portemonnee komt het? We halen het daar af. Heb je contant betaald en houd je dat niet bij, kies dan „Niet via een portemonnee”.';
  }

  @override
  String get debt_wallet_only_debt =>
      'Geen portemonnee verandert, alleen de schuld';

  @override
  String debt_wallet_confirm_in(String wallet) {
    return 'Toevoegen aan $wallet';
  }

  @override
  String debt_wallet_confirm_out(String wallet) {
    return 'Betalen vanuit $wallet';
  }

  @override
  String get debt_wallet_confirm_none => 'Opslaan zonder portemonnee';

  @override
  String get debt_history_swipe_hint =>
      'Veeg een betaling naar links om hem te verwijderen';

  @override
  String get debt_form_person => 'Persoon';

  @override
  String get debt_form_wallet => 'Portemonnee';

  @override
  String get menu_open => 'Menu openen';

  @override
  String get menu_close => 'Menu sluiten';

  @override
  String get settings_mascot_talks => 'Wumbi praat';

  @override
  String get mascot_label => 'Hamster Wumbi. Tik om te kletsen';

  @override
  String get mascot_dismiss => 'Wumbi terug laten gaan naar zijn hoekje';

  @override
  String get mascot_action_view => 'Laat zien';

  @override
  String get mascot_action_add => 'Toevoegen';

  @override
  String mascot_month_flow(String month, String income, String expense) {
    return '$month: +$income · −$expense';
  }

  @override
  String get mascot_greeting_morning => 'Goedemorgen, baas!';

  @override
  String get mascot_greeting_afternoon => 'Hoi baas!';

  @override
  String get mascot_greeting_evening => 'Goedenavond, baas!';

  @override
  String get mascot_all_calm => 'Alles rustig, de zaadjes liggen op hun plek';

  @override
  String get mascot_all_for_now => 'Meer weet ik nu even niet 🙂';

  @override
  String get mascot_quiet_today => 'Begrepen, baas. Vandaag zeg ik niks';

  @override
  String mascot_flow_up(String amount, String month) {
    return '$month: de voorraad groeide met $amount. Zo doorgaan!';
  }

  @override
  String mascot_flow_down(String amount, String month) {
    return '$month: er ging $amount meer uit dan er binnenkwam. Dat halen we wel in';
  }

  @override
  String mascot_reserve_full(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Volle wangen! Zaadjes voor $months maanden',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Baas, de schuld met $name moest $days dagen geleden terug',
      one: 'Baas, de schuld met $name moest gisteren terug',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue_nudge(String name) {
    return 'Die schuld met $name staat nog steeds open, baas. Even kijken?';
  }

  @override
  String mascot_budget_over(String name) {
    return 'Baas, “$name” is over de limiet. Kijken waar de zaadjes heen lekten?';
  }

  @override
  String mascot_budget_over_by(String name, String amount) {
    return '“$name” zit $amount over. Samen even uitzoeken, baas?';
  }

  @override
  String mascot_budget_near_left(String name, String amount) {
    return 'Nog maar $amount over in “$name” deze periode, baas';
  }

  @override
  String mascot_budget_near_percent(String name, int percent) {
    return '“$name” zit al op $percent%. Een beetje rustiger aan?';
  }

  @override
  String mascot_sleep_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Ik was in slaap gesukkeld, baas… $days dagen zonder boeking. Even inhalen?',
    );
    return '$_temp0';
  }

  @override
  String get mascot_sleep_quiet =>
      'Wel erg stil hier. Niets vergeten te noteren, baas?';

  @override
  String get mascot_sigh_month =>
      'Baas, deze maand gaan er meer zaadjes uit dan erin. Zoeken we het lek?';

  @override
  String get mascot_sigh_ahead =>
      'De uitgaven lopen voor op het inkomen. Samen kijken wat eraf kan?';

  @override
  String mascot_welcome_back(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Je bent terug, baas! $count nieuwe boekingen sinds de vorige keer',
      one: 'Je bent terug, baas! Eén nieuwe boeking sinds de vorige keer',
      zero: 'Je bent terug, baas! Zonder jou was het stil',
    );
    return '$_temp0';
  }

  @override
  String get mascot_evening_waited => 'Baas! Ik heb de hele dag op je gewacht!';

  @override
  String get mascot_evening_missed => 'Ik heb je gemist…';

  @override
  String get mascot_evening_log =>
      'Zullen we de uitgaven van vandaag noteren voor we ze vergeten?';

  @override
  String get mascot_evening_count =>
      'Help je me de zaadjes van vandaag te tellen?';

  @override
  String get mascot_event_reserve =>
      'Baas, we hebben voor drie maanden zaadjes! Nu kunnen we rustig slapen';

  @override
  String mascot_event_best_month(String amount) {
    return 'Beste maand in een half jaar! $amount de voorraad in. Trots op je, baas';
  }

  @override
  String mascot_event_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Al $days dagen tellen we samen zaadjes. Dank je, baas!',
    );
    return '$_temp0';
  }

  @override
  String get mascot_event_records =>
      'De 100e boeking! Samen tellen is veel leuker, baas';

  @override
  String mascot_event_streak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          '$days dagen op rij zonder er één over te slaan, baas! Wat een discipline',
    );
    return '$_temp0';
  }

  @override
  String mascot_charge_today(String name, String amount) {
    return 'Baas, vandaag neemt $name $amount';
  }

  @override
  String mascot_charge_tomorrow(String name, String amount) {
    return 'Morgen neemt $name $amount, baas';
  }

  @override
  String mascot_charge_soon(String name, String amount) {
    return 'Over een paar dagen neemt $name $amount';
  }

  @override
  String get mascot_charge_unnamed => 'een abonnement';

  @override
  String mascot_debt_due_today(String name) {
    return 'Baas, de schuld met $name vervalt vandaag';
  }

  @override
  String mascot_debt_due_tomorrow(String name) {
    return 'De schuld met $name vervalt morgen. Niet vergeten?';
  }

  @override
  String mascot_debt_due_soon(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Nog $days dagen voor de schuld met $name',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_mover(String name, int percent) {
    return 'Baas, “$name” eet $percent% meer zaadjes dan vorige maand. Even kijken?';
  }

  @override
  String mascot_insight_untagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uitgaven zonder tag deze maand. Zullen we ze indelen?',
      one: 'Eén uitgave zonder tag deze maand. Even indelen?',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_peak_day(String weekday) {
    return '$weekday is je hongerigste dag, baas';
  }

  @override
  String mascot_insight_reserve(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'De wangen zitten goed: zaadjes voor ongeveer $months maanden',
      one: 'De wangen zitten goed: zaadjes voor ongeveer een maand',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_top_expense(String name, String amount) {
    return 'Grootste hap deze maand: “$name”, $amount';
  }

  @override
  String mascot_insight_top_expense_amount(String amount) {
    return 'Grootste losse hap deze maand: $amount';
  }

  @override
  String mascot_insight_daily_average(String amount) {
    return 'Baas, deze maand gaat er per dag zo’n $amount uit';
  }

  @override
  String mascot_insight_daily_below(int percent) {
    return 'Per dag $percent% minder zaadjes dan normaal. Goed bezig, baas!';
  }

  @override
  String mascot_insight_daily_above(int percent) {
    return 'Baas, per dag $percent% meer zaadjes dan normaal. Kijken waar ze heen gaan?';
  }

  @override
  String mascot_insight_weekend(int percent) {
    return 'In het weekend vliegen de zaadjes $percent% sneller weg dan doordeweeks';
  }

  @override
  String mascot_insight_frequent_tag(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count keer “$name” deze maand. Wordt het een gewoonte, baas?',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_small_spends(String amount) {
    return 'Kleine aankopen kwamen deze maand op $amount. Zaadje voor zaadje, baas';
  }

  @override
  String mascot_insight_savings_rate(int percent) {
    return 'Baas, $percent% van het inkomen blijft deze maand in de voorraad. Blije wangen!';
  }

  @override
  String get mascot_insight_no_income =>
      'Er is deze maand nog geen zaadje binnengekomen, baas. Salaris vergeten te noteren?';

  @override
  String mascot_insight_forecast_over(String amount) {
    return 'In dit tempo kost de maand zo’n $amount. Meer dan normaal, baas';
  }

  @override
  String mascot_insight_forecast_under(String amount) {
    return 'Deze maand wordt licht: zo’n $amount. De voorraad zegt dankjewel';
  }

  @override
  String mascot_insight_owed_to_me(String amount) {
    return 'Baas, er staat $amount voor je open. Tijd voor een vriendelijk duwtje?';
  }

  @override
  String mascot_insight_negative_wallet(String name) {
    return '“$name” staat onder nul, baas. Een paar zaadjes overzetten?';
  }

  @override
  String mascot_insight_no_rate(String codes) {
    return '$codes kan ik nog niet omrekenen, geen koers. Zodra we online zijn, tel ik verder';
  }

  @override
  String mascot_insight_income_up(int percent) {
    return 'Baas, $percent% meer zaadjes binnen dan normaal! De helft van het extraatje meteen opzij?';
  }

  @override
  String mascot_insight_tag_yearly(String name, String amount) {
    return 'In dit tempo eet “$name” zo’n $amount per jaar';
  }

  @override
  String get mascot_insight_no_spend_yesterday =>
      'Gisteren geen enkele uitgave! Mijn wangen zijn trots op je, baas';

  @override
  String get mascot_tip_budget =>
      'Baas, een budget is gewoon een hekje om de zaadjes. Zetten we het eerste neer?';

  @override
  String get mascot_tip_subscriptions =>
      'Vaste betalingen? Voeg ze één keer toe, dan houd ik ze in de gaten';

  @override
  String mascot_tip_subs_yearly(String amount) {
    return 'Baas, abonnementen eten $amount per jaar. Zijn er die je niet echt gebruikt?';
  }

  @override
  String mascot_tip_recurring_share(int percent) {
    return '$percent% van de uitgaven deze maand zijn vaste betalingen. Rondjes, net als mijn rad';
  }

  @override
  String get mascot_tip_new_month =>
      'Nieuwe maand, baas! Schoon buideltje. Budgetten instellen?';

  @override
  String mascot_tip_monday_recap(String amount) {
    return 'Vorige week ging er $amount uit. Eens kijken hoe we het deze week doen, baas';
  }

  @override
  String mascot_tip_month_end(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Nog $days dagen deze maand. Je doet het geweldig, baas',
      one: 'Nog één dag deze maand. Je doet het geweldig, baas',
    );
    return '$_temp0';
  }

  @override
  String get mascot_tip_tags =>
      'Met tags zie ik waar de zaadjes heen gaan, baas. Probeer #eten of #thuis';

  @override
  String mascot_tip_debt_due_date(String name) {
    return 'Geef de schuld met $name een termijn, dan herinner ik je op tijd';
  }

  @override
  String mascot_tip_budget_for(String name, int percent) {
    return 'Baas, “$name” neemt $percent% van alle uitgaven. Een budget ervoor?';
  }

  @override
  String get mascot_tip_rainy_day =>
      'Baas, maak een aparte potje-voor-later portemonnee. Dan overvallen verrassingen ons niet';

  @override
  String get mascot_tip_pay_yourself_first =>
      'Er zijn zaadjes binnen! Zet meteen een deel opzij, baas, voor ze wegrollen';

  @override
  String get mascot_tip_treat =>
      'De voorraad staat er goed voor, baas. Jezelf af en toe verwennen mag, zonder schuldgevoel';

  @override
  String mascot_tip_future_self(String amount, String amount2) {
    return 'Maar $amount per dag is $amount2 per jaar. Stel je die wangen voor, baas!';
  }

  @override
  String get mascot_joke_friday =>
      'Het is vrijdag, baas! Ga lekker, ik pas op de zaadjes';

  @override
  String get mascot_joke_late_night =>
      'Het is laat, baas… Even noteren en naar bed? Ik zit al te gapen';

  @override
  String get mascot_joke_cheeks =>
      'Wist je, baas? Hamsters dragen zaadjes in hun wangen. Ik draag jouw budget';

  @override
  String get mascot_joke_trees =>
      'Zelfs als zaadjes aan bomen groeiden, zou ik ze nog in mijn wangen verstoppen';

  @override
  String get mascot_joke_twice =>
      'Ik heb je zaadjes twee keer geteld. Zelfde aantal, baas. Goed teken';

  @override
  String get mascot_joke_secret =>
      'Psst, baas… Rond elke uitgave in je hoofd naar boven af. Het verschil is je geheime voorraad';

  @override
  String mascot_reaction_income(String amount) {
    return '$amount gevangen! De voorraad in, baas';
  }

  @override
  String mascot_reaction_big_income(String amount) {
    return 'Wauw, baas! +$amount. Mijn wangen knappen bijna!';
  }

  @override
  String mascot_reaction_transfer(String amount) {
    return '$amount verplaatst';
  }

  @override
  String mascot_reaction_lent(String amount) {
    return '$amount uitgeleend. Ik onthoud het, baas';
  }

  @override
  String get mascot_reaction_debt_closed =>
      'Schuld afgelost! Schone pootjes, baas';

  @override
  String get mascot_reaction_forgiven =>
      'Kwijtgescholden… Je hebt een goed hart, baas';

  @override
  String get mascot_reaction_first_wallet =>
      'Eerste portemonnee, baas! Het verzamelen begint';

  @override
  String get mascot_reaction_budget => 'Budget staat. Ik houd de wacht, baas';

  @override
  String get mascot_wallet_negative => 'Baas, deze portemonnee staat onder nul';

  @override
  String mascot_wallet_down(int percent) {
    return 'Sinds de 1e is hier $percent% van de zaadjes weg';
  }

  @override
  String mascot_wallet_up(String amount) {
    return 'Sinds de 1e $amount erbij. Prachtig, baas!';
  }

  @override
  String get mascot_wallet_sleeping =>
      'Deze portemonnee slaapt al een maand. Ssst…';

  @override
  String get mascot_wallet_calm => 'Hier is alles rustig, baas';

  @override
  String mascot_budgets_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Baas, $count budgetten zijn over de limiet',
      one: 'Baas, één budget is over de limiet',
    );
    return '$_temp0';
  }

  @override
  String mascot_budgets_near(String name) {
    return '“$name” is bijna op, baas';
  }

  @override
  String get mascot_budgets_calm =>
      'Alle hekjes staan, baas. De budgetten zitten goed';

  @override
  String mascot_budget_detail_over(String amount) {
    return '$amount over. Volgende keer de limiet omhoog, baas?';
  }

  @override
  String mascot_budget_detail_pace(String date) {
    return 'In dit tempo is de limiet op $date op';
  }

  @override
  String get mascot_budget_detail_within =>
      'Binnen de limiet gebleven! Trots op je, baas';

  @override
  String get mascot_budget_detail_calm => 'Alles volgens plan, baas';

  @override
  String mascot_debts_overdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Baas, $count schulden zijn over tijd',
      one: 'Baas, één schuld is over tijd',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debts_all_closed =>
      'Alle schulden afgelost! Schone pootjes, baas';

  @override
  String get mascot_debts_tracking => 'Ik houd bij wie wie zaadjes schuldig is';

  @override
  String mascot_debt_detail_overdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Dit moest $days dagen geleden terug, baas',
      one: 'Dit moest gisteren terug, baas',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debt_detail_lent => 'Ik weet wie onze zaadjes leende, baas';

  @override
  String mascot_debt_detail_due(String date) {
    return 'Terug vóór $date';
  }

  @override
  String mascot_subs_spinning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnementen nemen elke maand hun deel zaadjes',
      one: 'Eén abonnement neemt elke maand zijn deel zaadjes',
    );
    return '$_temp0';
  }

  @override
  String mascot_tags_top(String name) {
    return 'De meeste zaadjes gingen deze maand naar “$name”';
  }

  @override
  String mascot_tag_up(int percent) {
    return 'Hier $percent% meer dan vorige maand';
  }

  @override
  String mascot_tag_down(int percent) {
    return '$percent% minder dan vorige maand. Mooi zo, baas!';
  }

  @override
  String mascot_progress_saved(String amount) {
    return '$amount de voorraad in. Top gedaan, baas!';
  }

  @override
  String mascot_progress_over(String amount) {
    return '$amount meer zaadjes uit dan in';
  }

  @override
  String mascot_progress_over_tag(String amount, String name) {
    return '$amount meer zaadjes uit dan in, vooral aan “$name”';
  }

  @override
  String mascot_progress_forecast(String amount) {
    return 'In dit tempo gaat er deze periode zo’n $amount uit';
  }

  @override
  String get mascot_progress_counting =>
      'Ik ben deze periode nog aan het tellen, baas';

  @override
  String get mascot_screen_wallet_filter =>
      'Filter op tag en je ziet waar de zaadjes van deze portemonnee heen gaan';

  @override
  String get mascot_screen_wallet_switch =>
      'Tik bovenaan op de naam om naar een andere portemonnee te springen';

  @override
  String get mascot_screen_wallet_limit =>
      'In het tabblad Budgetten kun je een limiet op deze portemonnee zetten';

  @override
  String get mascot_screen_budgets_rollover =>
      'Budgetten kunnen restjes meenemen naar de volgende periode. Geen zaadje verspild';

  @override
  String get mascot_screen_budgets_tags =>
      'Een budget kan alleen de tags volgen die jij kiest. Bijvoorbeeld #café';

  @override
  String get mascot_screen_budget_periods =>
      'Blader door de periodes om met eerdere te vergelijken';

  @override
  String get mascot_screen_debts_due =>
      'Voeg een termijn toe, dan herinner ik je op tijd, baas';

  @override
  String get mascot_screen_debts_quick =>
      'Snelst terugbetalen: Overboeking → Schulden op het boekingsscherm';

  @override
  String get mascot_screen_subs_pause =>
      'Je kunt een abonnement pauzeren in plaats van verwijderen. De geschiedenis blijft';

  @override
  String get mascot_screen_tags_nest =>
      'Nest tags met een schuine streep: eten/koffie';

  @override
  String get mascot_screen_tags_map =>
      'Open de kaart, baas, dan zie je hoe je tags samenhangen';

  @override
  String get mascot_screen_tag_rename =>
      'Hernoem of verplaats een tag, de geneste gaan mee';

  @override
  String get mascot_screen_progress_baseline =>
      'Tik op “vs …” om te vergelijken met vorig jaar of een gemiddelde van 3 maanden';

  @override
  String mascot_ans_spent_today(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vandaag: $amount in $count uitgaven',
      one: 'Vandaag: $amount, maar één uitgave',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_today =>
      'Vandaag geen enkele uitgave, baas. Alle zaadjes nog daar!';

  @override
  String mascot_ans_spent_yesterday(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gisteren: $amount in $count uitgaven',
      one: 'Gisteren: $amount, maar één uitgave',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_yesterday =>
      'Gisteren gaf je geen enkel zaadje uit. Hoera!';

  @override
  String mascot_ans_spent_week(String amount) {
    return 'Deze week tot nu toe: $amount';
  }

  @override
  String mascot_ans_spent_month(String expense, String income) {
    return 'Deze maand ging er $expense uit en kwam er $income binnen';
  }

  @override
  String get mascot_ans_no_expenses =>
      'Deze maand nog geen uitgaven. Prachtig, baas';

  @override
  String mascot_ans_upcoming(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count betalingen in de komende 7 dagen: $amount',
      one: 'Eén betaling in de komende 7 dagen: $amount',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_upcoming =>
      'De komende week hoef je niets te betalen';

  @override
  String mascot_ans_owed(String amount, String name) {
    return 'Er staat $amount voor je open, vooral bij $name';
  }

  @override
  String get mascot_ans_nobody_owes =>
      'Op dit moment is niemand je iets schuldig';

  @override
  String get mascot_ans_reserve_low =>
      'Minder dan een maand aan zaadjes, baas. Laten we die wangen samen vullen';

  @override
  String get mascot_ans_reserve_unknown =>
      'Daarvoor heb ik ongeveer een maand aan boekingen nodig';

  @override
  String mascot_ans_where(String name, int percent, String name2) {
    return 'De meeste zaadjes gingen naar “$name” ($percent%), daarna “$name2”';
  }

  @override
  String mascot_ans_where_one(String name, int percent) {
    return 'Bijna alle zaadjes gingen naar “$name”, $percent%';
  }

  @override
  String mascot_ans_where_untagged(int percent) {
    return 'Baas, $percent% van de uitgaven heeft geen tag, dus ik zie niet waar het heen ging. Indelen?';
  }

  @override
  String get mascot_q_today => 'Vandaag uitgegeven?';

  @override
  String get mascot_q_yesterday => 'En gisteren?';

  @override
  String get mascot_q_week => 'Deze week?';

  @override
  String get mascot_q_month => 'Deze maand?';

  @override
  String get mascot_q_where => 'Waar zijn de zaadjes gebleven?';

  @override
  String get mascot_q_biggest => 'Grootste uitgave?';

  @override
  String get mascot_q_budgets => 'Blijf ik binnen budget?';

  @override
  String get mascot_q_upcoming => 'Wat moet ik binnenkort betalen?';

  @override
  String get mascot_q_owed => 'Wie is me iets schuldig?';

  @override
  String get mascot_q_reserve => 'Hoe lang kan ik ermee toe?';

  @override
  String get mascot_q_tip => 'Een tip?';

  @override
  String get mascot_q_joke => 'Laat me lachen';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
