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
  String get transaction_edit_title => 'Bewerken';

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
  String get progress_month => 'Maand';

  @override
  String get progress_year => 'Jaar';

  @override
  String get progress_income => 'Inkomsten';

  @override
  String get progress_expense => 'Uitgave';

  @override
  String get progress_net => 'Netto';

  @override
  String get progress_vs_last_month => 't.o.v. vorige maand';

  @override
  String get progress_vs_last_year => 't.o.v. vorig jaar';

  @override
  String get progress_all_wallets => 'Alle portemonnees';

  @override
  String get progress_scope_title => 'Gegevens tonen voor';

  @override
  String get progress_chart_title => 'Inkomsten vs Uitgaven';

  @override
  String progress_not_included(String codes) {
    return '$codes niet meegerekend';
  }

  @override
  String get progress_empty_title => 'Nog niets te analyseren';

  @override
  String get progress_trend_title => 'Verloop';

  @override
  String get progress_tags_title => 'Uitgaven per tag';

  @override
  String get progress_untagged => 'Zonder tag';

  @override
  String get progress_other_tags => 'Overig';

  @override
  String get progress_no_expenses => 'Geen uitgaven in deze periode';

  @override
  String get progress_empty_subtitle =>
      'Voeg een paar transacties toe en je voortgang verschijnt hier.';

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
  String get error_tag_name => 'Voer een tagnaam in (maximaal 30 tekens).';

  @override
  String get error_open_db_title => 'Kan je gegevens niet openen';

  @override
  String get error_open_db_message =>
      'Wumbi kon de database op dit apparaat niet ontgrendelen.';

  @override
  String get error_reset_app => 'App resetten';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
