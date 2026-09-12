// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appLanguage => 'Deutsch';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'Weiter';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_save => 'Speichern';

  @override
  String get common_delete => 'Löschen';

  @override
  String get common_confirm => 'Bestätigen';

  @override
  String get common_undo => 'Rückgängig';

  @override
  String get common_ok => 'OK';

  @override
  String get common_retry => 'Erneut';

  @override
  String get common_today => 'Heute';

  @override
  String get common_yesterday => 'Gestern';

  @override
  String get common_income => 'Einnahme';

  @override
  String get common_expense => 'Ausgabe';

  @override
  String get common_transfer => 'Umbuchung';

  @override
  String get common_edit => 'Bearbeiten';

  @override
  String get common_all => 'Alle';

  @override
  String get common_clear => 'Leeren';

  @override
  String get common_apply => 'Anwenden';

  @override
  String get common_done => 'Fertig';

  @override
  String get common_close => 'Schließen';

  @override
  String get common_search => 'Suchen';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Das ist Wumbi';

  @override
  String get onboarding_welcome_subtitle =>
      'Geld erfassen in Sekunden. Keine Kategorien, nur Tags.';

  @override
  String get onboarding_currency_title => 'Deine Hauptwährung';

  @override
  String get onboarding_currency_subtitle =>
      'Summen erscheinen in dieser Währung. Du kannst sie später in den Einstellungen ändern.';

  @override
  String get onboarding_wallet_title => 'Dein erstes Konto';

  @override
  String get onboarding_wallet_subtitle =>
      'Jedes Konto hat eine Währung. Weitere Konten kannst du später anlegen.';

  @override
  String get onboarding_create_wallet => 'Konto anlegen';

  @override
  String get common_skip => 'Überspringen';

  @override
  String get onboarding_welcome_start => 'Leg los';

  @override
  String get onboarding_benefit_wallets_title => 'Konten in jeder Währung';

  @override
  String get onboarding_benefit_wallets_body =>
      'Dollar, Euro, Bitcoin — jedes Konto hat seine eigene Währung. Deine Summe siehst du in der, die du wählst.';

  @override
  String get onboarding_benefit_tags_title => 'Tags statt Kategorien';

  @override
  String get onboarding_benefit_tags_body =>
      'Vergiss starre Kategorien. Vergib beliebige Tags — #coffee, #trip, #work — und finde später alles wieder.';

  @override
  String get onboarding_benefit_one_tap_title => 'Mit einem Tipp erfasst';

  @override
  String get onboarding_benefit_one_tap_body =>
      'Betrag eintippen, auf Einnahme oder Ausgabe tippen. Fertig. Das Fenster bleibt für den nächsten offen.';

  @override
  String get onboarding_how_title => 'So funktioniert\'s';

  @override
  String get onboarding_how_body =>
      'Leg ein Konto an, erfasse dein Geld, wenn es sich bewegt, und sieh deine Summen sofort wachsen.';

  @override
  String get onboarding_how_step_wallet => 'Konto anlegen';

  @override
  String get onboarding_how_step_tap => 'Tippen zum Erfassen';

  @override
  String get onboarding_how_step_totals => 'Summen sehen';

  @override
  String get onboarding_wallet_hero_prefix => 'Erstelle dein erstes';

  @override
  String get onboarding_wallet_hero_accent => 'Konto';

  @override
  String get onboarding_final_title => 'Alles bereit!';

  @override
  String get onboarding_final_body =>
      'Dein erstes Konto steht. Um den Rest kümmert sich Wumbi.';

  @override
  String get onboarding_final_button => 'Los geht\'s';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'Mein Geld';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aus $count Konten',
      one: 'Aus 1 Konto',
      zero: 'Noch keine Konten',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes nicht enthalten';
  }

  @override
  String get dashboard_wallets => 'Konten';

  @override
  String get dashboard_new_wallet => 'Neues Konto';

  @override
  String get dashboard_empty_title => 'Erstelle dein erstes Konto';

  @override
  String get dashboard_empty_subtitle =>
      'Wumbi braucht ein Konto für dein Geld.';

  @override
  String get dashboard_tags => 'Tags';

  @override
  String get dashboard_subscriptions => 'Abos';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'Kontoname';

  @override
  String get wallet_currency => 'Währung';

  @override
  String get wallet_primary => 'Hauptkonto';

  @override
  String get wallet_has_transactions => 'Hat Transaktionen';

  @override
  String get wallet_pick_another_primary => 'Wähle ein anderes Hauptkonto';

  @override
  String wallet_delete_title(String name) {
    return '$name löschen?';
  }

  @override
  String get wallet_delete_message =>
      'Seine Transaktionen werden entfernt. Umbuchungen mit anderen Konten bleiben sichtbar.';

  @override
  String get wallet_deleted => 'Konto gelöscht';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Konto gelöscht · $count Wiederholungen pausiert',
      one: 'Konto gelöscht · 1 Wiederholung pausiert',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'Noch keine Transaktionen';

  @override
  String get wallet_empty_subtitle => 'Tippe auf +, um die erste zu erfassen';

  @override
  String get wallet_switch_title => 'Konto wechseln';

  @override
  String wallet_transfer_to(String name) {
    return 'Umbuchung auf $name';
  }

  @override
  String wallet_transfer_from(String name) {
    return 'Umbuchung von $name';
  }

  @override
  String get wallet_deleted_suffix => '(gelöscht)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Wiederholungen',
      one: '1 Wiederholung',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'Dieses Konto existiert nicht mehr';

  @override
  String get wallet_filter => 'Filter';

  @override
  String get wallet_sort => 'Sortieren';

  @override
  String get wallet_filter_title => 'Transaktionen filtern';

  @override
  String get wallet_filter_type => 'Art';

  @override
  String get wallet_filter_date => 'Datum';

  @override
  String get wallet_filter_tags => 'Tags';

  @override
  String get wallet_filter_from => 'Von';

  @override
  String get wallet_filter_to => 'Bis';

  @override
  String get wallet_filter_any_date => 'Jedes Datum';

  @override
  String get wallet_filter_this_month => 'Dieser Monat';

  @override
  String get wallet_filter_last_month => 'Letzter Monat';

  @override
  String get wallet_filter_last_30_days => 'Letzte 30 Tage';

  @override
  String get wallet_filter_this_year => 'Dieses Jahr';

  @override
  String get wallet_filter_custom_range => 'Eigener Zeitraum';

  @override
  String get wallet_filter_upcoming_only => 'Nur Geplante';

  @override
  String get wallet_filter_clear => 'Filter löschen';

  @override
  String get wallet_filter_no_tags => 'Noch keine Tags in diesem Konto';

  @override
  String get wallet_filter_no_results_title => 'Keine Treffer';

  @override
  String get wallet_filter_no_results_subtitle => 'Entferne einen Filter.';

  @override
  String wallet_filter_active(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Filter',
      one: '1 Filter',
    );
    return '$_temp0';
  }

  @override
  String get wallet_sort_title => 'Sortieren nach';

  @override
  String get sort_date_newest => 'Neueste zuerst';

  @override
  String get sort_date_oldest => 'Älteste zuerst';

  @override
  String get sort_amount_high => 'Größter Betrag';

  @override
  String get sort_amount_low => 'Kleinster Betrag';

  @override
  String get wallet_upcoming_section => 'Geplant';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geplante Transaktionen zählen noch nicht',
      one: '1 geplante Transaktion zählt noch nicht',
    );
    return '$_temp0';
  }

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'Bearbeiten';

  @override
  String get transaction_description_placeholder => 'Beschreibung';

  @override
  String get transaction_tags_placeholder => '#tags';

  @override
  String get transaction_repeat => 'Wiederholen';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · Teil einer Wiederholung';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount gehen auf $wallet';
  }

  @override
  String transaction_hint_stale(String date) {
    return 'Kurs vom $date';
  }

  @override
  String get transaction_rate_unavailable =>
      'Kein Kurs — geh online zum Aktualisieren';

  @override
  String transaction_saved(String amount, String wallet) {
    return '$amount in $wallet gespeichert';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return '$amount nach $wallet verschoben';
  }

  @override
  String get transaction_deleted => 'Transaktion gelöscht';

  @override
  String get transaction_upcoming_badge => 'Geplant';

  @override
  String transaction_upcoming_hint(String date) {
    return 'Zählt ab $date';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return '$amount für $date geplant';
  }

  @override
  String get transaction_delete_title => 'Diese Transaktion löschen?';

  @override
  String get transaction_delete_this_one => 'Nur diese löschen';

  @override
  String get transaction_delete_and_stop => 'Löschen und nicht wiederholen';

  @override
  String get transaction_need_second_wallet_title =>
      'Für Umbuchungen brauchst du ein zweites Konto';

  @override
  String get transaction_need_second_wallet_message =>
      'Umbuchungen verschieben Geld zwischen zwei deiner Konten.';

  @override
  String get transaction_different_currency => 'Andere Währung';

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
    return '$amount von $wallet umbuchen';
  }

  @override
  String get transfer_amount_received => 'Erhaltener Betrag';

  @override
  String get transfer_confirm => 'Umbuchung bestätigen';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'Nie';

  @override
  String get repeat_every_day => 'Jeden Tag';

  @override
  String get repeat_every_week => 'Jede Woche';

  @override
  String get repeat_every_month => 'Jeden Monat';

  @override
  String get repeat_every_year => 'Jedes Jahr';

  @override
  String get repeat_daily => 'Täglich';

  @override
  String get repeat_weekly => 'Wöchentlich';

  @override
  String get repeat_monthly => 'Monatlich';

  @override
  String get repeat_yearly => 'Jährlich';

  @override
  String get repeat_rules_title => 'Abos';

  @override
  String get repeat_rules_hint =>
      'Tippe auf ein Abo, um es zu bearbeiten. Bestehende Transaktionen ändern sich nie.';

  @override
  String repeat_next(String date) {
    return 'Nächste: $date';
  }

  @override
  String get repeat_paused => 'Pausiert';

  @override
  String get repeat_delete_title => 'Wiederholung stoppen?';

  @override
  String get repeat_delete_message =>
      'Bestehende Transaktionen bleiben. Es werden keine neuen erstellt.';

  @override
  String get repeat_stop => 'Stoppen';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'Datum wählen';

  @override
  String get date_pick_from => 'Von';

  @override
  String get date_pick_to => 'Bis';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'Suche';

  @override
  String get search_placeholder => 'Beschreibung, Betrag, Konto oder Tag';

  @override
  String get search_hint =>
      'Durchsuche alle Konten nach Beschreibung, Betrag, Kontoname oder Tag.';

  @override
  String get search_no_results_title => 'Nichts gefunden';

  @override
  String get search_no_results_subtitle =>
      'Versuche ein anderes Wort, einen Betrag oder Tag.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get l10nTags =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TAGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get tags_title => 'Tags';

  @override
  String get tags_view_list => 'Liste';

  @override
  String get tags_view_graph => 'Karte';

  @override
  String get tags_search_placeholder => 'Tags suchen';

  @override
  String get tags_empty_title => 'Noch keine Tags';

  @override
  String get tags_empty_subtitle =>
      'Vergib #tags bei einer Transaktion und sie erscheinen hier.';

  @override
  String get tags_search_no_results => 'Keine Tags gefunden';

  @override
  String tags_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tags',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String tags_usage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Transaktionen',
      one: '1 Transaktion',
      zero: 'Noch nicht genutzt',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'Ausgegeben';

  @override
  String get tags_earned => 'Eingenommen';

  @override
  String get tags_net => 'Netto';

  @override
  String tags_not_included(String codes) {
    return '$codes nicht enthalten';
  }

  @override
  String get tags_graph_hint =>
      'Größere Kreise bewegten mehr Geld. Linien verbinden Tags, die zusammen genutzt werden.';

  @override
  String get tags_graph_empty =>
      'Vergib Tags bei ein paar Transaktionen, um die Karte zu sehen.';

  @override
  String get tag_wallets => 'Konten';

  @override
  String get tag_transactions => 'Transaktionen';

  @override
  String get tag_no_transactions => 'Keine Transaktionen mit diesem Tag';

  @override
  String get tag_rename => 'Tag umbenennen';

  @override
  String get tag_name_placeholder => 'Tag-Name';

  @override
  String get tag_delete => 'Tag löschen';

  @override
  String tag_delete_title(String name) {
    return '#$name löschen?';
  }

  @override
  String get tag_delete_message =>
      'Er wird aus allen Transaktionen entfernt. Die Transaktionen selbst bleiben.';

  @override
  String get tag_deleted => 'Tag gelöscht';

  @override
  String get tag_renamed => 'Tag umbenannt';

  @override
  String tag_merged(String name) {
    return 'Mit #$name zusammengeführt';
  }

  @override
  String get tag_not_found => 'Dieser Tag existiert nicht mehr';

  @override
  String get tag_wallet_deleted => '(gelöscht)';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'Abos';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
      zero: 'Keine Abos',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'Noch keine Abos';

  @override
  String get subscriptions_empty_subtitle =>
      'Stelle bei einer Transaktion Wiederholen ein und sie erscheint hier.';

  @override
  String get subscriptions_all_wallets => 'Alle Konten';

  @override
  String get subscriptions_active => 'Aktiv';

  @override
  String get subscriptions_paused => 'Pausiert';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / Monat';
  }

  @override
  String get subscriptions_edit_title => 'Abo bearbeiten';

  @override
  String get subscriptions_amount => 'Betrag';

  @override
  String get subscriptions_wallet => 'Konto';

  @override
  String get subscriptions_from_wallet => 'Von Konto';

  @override
  String get subscriptions_to_wallet => 'Auf Konto';

  @override
  String get subscriptions_frequency => 'Häufigkeit';

  @override
  String get subscriptions_description => 'Beschreibung';

  @override
  String get subscriptions_tags => 'Tags';

  @override
  String get subscriptions_pause => 'Pausieren';

  @override
  String get subscriptions_resume => 'Fortsetzen';

  @override
  String get subscriptions_stop => 'Abo stoppen';

  @override
  String get subscriptions_saved => 'Abo aktualisiert';

  @override
  String get subscriptions_stopped => 'Abo gestoppt';

  @override
  String get subscriptions_type_hint =>
      'Die Art eines Abos lässt sich nicht ändern.';

  @override
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'Fortschritt';

  @override
  String get progress_month => 'Monat';

  @override
  String get progress_year => 'Jahr';

  @override
  String get progress_income => 'Einnahme';

  @override
  String get progress_expense => 'Ausgabe';

  @override
  String get progress_net => 'Netto';

  @override
  String get progress_vs_last_month => 'ggü. letztem Monat';

  @override
  String get progress_vs_last_year => 'ggü. letztem Jahr';

  @override
  String get progress_all_wallets => 'Alle Konten';

  @override
  String get progress_scope_title => 'Daten anzeigen für';

  @override
  String get progress_chart_title => 'Einnahmen vs Ausgaben';

  @override
  String progress_not_included(String codes) {
    return '$codes nicht enthalten';
  }

  @override
  String get progress_empty_title => 'Noch nichts auszuwerten';

  @override
  String get progress_trend_title => 'Verlauf';

  @override
  String get progress_tags_title => 'Ausgaben nach Tag';

  @override
  String get progress_untagged => 'Ohne Tag';

  @override
  String get progress_other_tags => 'Sonstige';

  @override
  String get progress_no_expenses => 'Keine Ausgaben in diesem Zeitraum';

  @override
  String get progress_empty_subtitle =>
      'Füge ein paar Transaktionen hinzu und dein Fortschritt erscheint hier.';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Währung';

  @override
  String get currency_no_results => 'Keine Währung gefunden';

  @override
  String get currency_base_title => 'Hauptwährung';

  @override
  String get currency_base_hint =>
      'Dein gesamter Kontostand wird in diese Währung umgerechnet.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_preferences => 'Allgemein';

  @override
  String get settings_notifications => 'Mitteilungen';

  @override
  String get settings_currency => 'Währung';

  @override
  String get settings_dark_mode => 'Dunkelmodus';

  @override
  String get settings_show_mascot => 'Maskottchen anzeigen';

  @override
  String get settings_data_privacy => 'Daten & Datenschutz';

  @override
  String get settings_export_transactions => 'Transaktionen exportieren';

  @override
  String get settings_reset_all_data => 'Daten zurücksetzen';

  @override
  String get settings_reset_title => 'Alle Daten zurücksetzen?';

  @override
  String get settings_reset_message =>
      'Alle Konten, Transaktionen und Einstellungen auf diesem Gerät werden gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get settings_reset_action => 'Zurücksetzen';

  @override
  String get settings_reset_done => 'Alle Daten gelöscht';

  @override
  String settings_version(String version, String build) {
    return 'Version: $version ($build)';
  }

  @override
  String get settings_language => 'Sprache';

  @override
  String get settings_manage => 'Verwalten';

  @override
  String get settings_tags => 'Tags';

  @override
  String get settings_subscriptions => 'Abos';

  @override
  String get settings_language_info =>
      'Wähle die Sprache für die App-Oberfläche.';

  @override
  String get settings_theme => 'Design';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Hell';

  @override
  String get settings_theme_dark => 'Dunkel';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'Über Wumbi';

  @override
  String get about_project => 'Über das Projekt';

  @override
  String get about_text =>
      'Wumbi behält dein Geld auf deinem Handy. Betrag tippen, Einnahme oder Ausgabe antippen, fertig. Kein Konto nötig, und nichts wird hochgeladen, solange du es nicht einschaltest.';

  @override
  String get about_support => 'Support kontaktieren';

  @override
  String get about_read_more => 'Mehr auf wumbi.app';

  @override
  String get settings_about_section => 'Über Wumbi';

  @override
  String get settings_privacy_policy => 'Datenschutzerklärung';

  @override
  String get settings_terms => 'Nutzungsbedingungen';

  @override
  String get settings_press => 'Pressebereich';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'Betrag eingeben';

  @override
  String validation_up_to_tags(int count) {
    return 'Bis zu $count Tags';
  }

  @override
  String get validation_rate_unavailable => 'Kein Kurs verfügbar';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'Datenbankfehler, bitte erneut versuchen.';

  @override
  String get error_unknown =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get error_rate_unavailable =>
      'Kein Wechselkurs verfügbar. Geh online und versuche es erneut.';

  @override
  String get error_validation => 'Bitte prüfe deine Eingaben.';

  @override
  String get error_wallet_has_transactions =>
      'Die Währung lässt sich nicht mehr ändern, sobald ein Konto Transaktionen hat.';

  @override
  String get error_not_found => 'Dieser Eintrag existiert nicht mehr.';

  @override
  String get error_tag_name => 'Gib einen Tag-Namen ein (max. 30 Zeichen).';

  @override
  String get error_open_db_title => 'Daten konnten nicht geöffnet werden';

  @override
  String get error_open_db_message =>
      'Wumbi konnte die Datenbank auf diesem Gerät nicht entsperren.';

  @override
  String get error_reset_app => 'App zurücksetzen';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
