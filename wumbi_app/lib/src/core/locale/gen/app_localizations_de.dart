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
  String get wallet_tab_transactions => 'Transaktionen';

  @override
  String get wallet_tab_budgets => 'Budgets';

  @override
  String get wallet_tab_subscriptions => 'Abos';

  @override
  String get wallet_budgets_empty =>
      'Noch keine Ausgabenlimits für diese Wallet';

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
  String get transaction_edit_title => 'Transaktion bearbeiten';

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
  String get tags_new => 'Neuer Tag';

  @override
  String get tags_create => 'Tag erstellen';

  @override
  String tags_created(String name) {
    return '#$name erstellt';
  }

  @override
  String tags_exists(String name) {
    return '#$name gibt es schon';
  }

  @override
  String get tags_parent => 'Übergeordneter Tag';

  @override
  String get tags_parent_none => 'Keiner';

  @override
  String get tags_name_hint => 'z. B. kaffee';

  @override
  String get tags_create_tip =>
      'Tipp: Tippe essen/kaffee, um einen Tag direkt zu verschachteln.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verschachtelt',
      one: '1 verschachtelt',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'Wie nutze ich Tags?';

  @override
  String get tags_graph_mode_all => 'Alle';

  @override
  String get tags_graph_mode_spending => 'Ausgaben';

  @override
  String get tags_graph_mode_income => 'Einnahmen';

  @override
  String get tags_graph_legend_size => 'Größer = mehr Geld';

  @override
  String get tags_graph_legend_nested => 'Verschachtelt';

  @override
  String get tags_graph_legend_together => 'Zusammen genutzt';

  @override
  String get tags_graph_tap_hint =>
      'Tippe auf einen Kreis, um seine Zahlen zu sehen';

  @override
  String get tags_graph_open => 'Öffnen';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mit $count Tags verbunden',
      one: 'Mit 1 Tag verbunden',
      zero: 'Noch keine Verbindungen',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'Verschieben';

  @override
  String tag_move_title(String name) {
    return '#$name verschieben';
  }

  @override
  String get tag_moved => 'Tag verschoben';

  @override
  String get tag_add_nested => 'Verschachtelten Tag hinzufügen';

  @override
  String get tag_nested_tags => 'Verschachtelte Tags';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enthält $count verschachtelte Tags',
      one: 'Enthält 1 verschachtelten Tag',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Er und seine $count verschachtelten Tags werden aus allen Transaktionen entfernt. Die Transaktionen selbst bleiben.',
      one:
          'Er und sein verschachtelter Tag werden aus allen Transaktionen entfernt. Die Transaktionen selbst bleiben.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'Verschachtelte Tags werden mit umbenannt. Mit / verschiebst du ihn unter einen anderen Tag.';

  @override
  String get tag_top_level => 'Oberste Ebene';

  @override
  String get tag_nested_empty => 'Noch keine verschachtelten Tags';

  @override
  String get settings_help => 'Hilfe nötig?';

  @override
  String get help_title => 'Hilfe nötig?';

  @override
  String get help_subtitle =>
      'Kurze Anleitungen, damit du das Beste aus Wumbi holst.';

  @override
  String get help_tags_title => 'Wie nutze ich Tags?';

  @override
  String get help_tags_subtitle => 'Labels, verschachtelte Tags und die Karte';

  @override
  String get help_tags_intro =>
      'Tags sind kurze Labels wie #kaffee, die du deinen Transaktionen gibst. Eine Transaktion kann mehrere Tags tragen – so siehst du dein Geld aus jedem Blickwinkel, nicht nur pro Wallet.';

  @override
  String get help_tags_add_title => 'Einen Tag hinzufügen';

  @override
  String get help_tags_add_body =>
      'Beim Erfassen einer Transaktion tippst du einen Namen ins Tag-Feld und wählst einen Vorschlag oder legst einen neuen an. Tags haben keine Leerzeichen – schreib coffee-shop oder coffee_shop. Groß- und Kleinschreibung ergeben denselben Tag.';

  @override
  String get help_tags_nested_title => 'Verschachtelte Tags';

  @override
  String get help_tags_nested_body =>
      'Mit einem Schrägstrich / legst du einen Tag in einen anderen, wie Ordner: essen/kaffee und essen/einkauf liegen beide in essen. Der übergeordnete Tag wird automatisch angelegt.';

  @override
  String get help_tags_parent_title =>
      'Ein übergeordneter Tag enthält seine verschachtelten Tags';

  @override
  String get help_tags_parent_body =>
      '#essen zeigt alle Transaktionen mit #essen, #essen/kaffee oder #essen/einkauf. Summen, Filter und Budgets eines übergeordneten Tags zählen seine verschachtelten Tags mit. Eine Transaktion mit beiden Tags zählt nur einmal.';

  @override
  String get help_tags_multi_title => 'Mehrere Tags an einer Transaktion';

  @override
  String get help_tags_multi_body =>
      'Ein Abendessen im Urlaub kann gleichzeitig #reise und #essen/restaurant sein. Es zählt dann in beiden, und die zwei Tags werden auf der Karte verbunden.';

  @override
  String get help_tags_manage_title => 'Erstellen, umbenennen, verschieben';

  @override
  String get help_tags_manage_body =>
      'Tippe auf der Tags-Seite auf +, um einen Tag zu erstellen, und wähle einen übergeordneten Tag, um ihn zu verschachteln. Öffne einen Tag, um ihn umzubenennen, unter einen anderen Tag zu verschieben, einen verschachtelten Tag hinzuzufügen oder ihn zu löschen. Benennst du einen übergeordneten Tag um, folgen seine verschachtelten Tags; benennst du ihn wie einen bestehenden Tag, werden beide zusammengeführt.';

  @override
  String get help_tags_map_title => 'Die Karte lesen';

  @override
  String get help_tags_map_body =>
      'Jeder Kreis ist ein Tag: Je größer, desto mehr Geld ist geflossen. Sein Ring zeigt den Anteil von Ausgaben und Einnahmen. Durchgezogene Linien verbinden einen übergeordneten Tag mit seinen verschachtelten Tags, zarte Linien verbinden Tags derselben Transaktion. Tippe auf einen Kreis, um seine Zahlen zu sehen.';

  @override
  String get help_tags_tips_title => 'Tipps';

  @override
  String get help_tags_tip1 =>
      'Fang breit an – essen, wohnen, verkehr – und verschachtele nur, wenn du mehr Details willst.';

  @override
  String get help_tags_tip2 =>
      'Nutze Tags für alles, was quer durch deine Wallets geht: #urlaub, #geschenke, #auto.';

  @override
  String get help_tags_tip3 =>
      'Halte Namen kurz; zwei oder drei Ebenen reichen.';

  @override
  String get help_tags_example => 'Beispiel';

  @override
  String get help_tags_example_total => 'Summe für #essen';

  @override
  String get help_tags_ex_parent => 'essen';

  @override
  String get help_tags_ex_child1 => 'kaffee';

  @override
  String get help_tags_ex_child2 => 'einkauf';

  @override
  String get help_tags_ex_travel => 'reise';

  @override
  String get help_tags_ex_restaurant => 'restaurant';

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
  String debt_error_owes_you_only(String name, String amount) {
    return '$name schuldet dir nur $amount';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return 'Du schuldest $name nur $amount';
  }

  @override
  String get person_error_has_debts =>
      'Begleiche oder lösche zuerst die Schulden dieser Person.';

  @override
  String get debt_error_closed => 'Diese Schuld ist bereits beglichen.';

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
  String get dashboard_budgets => 'Budgets';

  @override
  String get budget_new => 'Neues Budget';

  @override
  String get budget_empty_hint =>
      'Lege ein Ausgabenlimit für ein Wallet oder einen #Tag fest';

  @override
  String get budgets_all => 'Alle Budgets';

  @override
  String get budgets_title => 'Budgets';

  @override
  String budget_left(String amount) {
    return '$amount übrig';
  }

  @override
  String budget_over(String amount) {
    return '$amount drüber';
  }

  @override
  String budget_starts(String date) {
    return 'Beginnt am $date';
  }

  @override
  String get budget_ended => 'Beendet';

  @override
  String budget_per_day(String amount) {
    return '$amount/Tag';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return '$spent von $limit ausgegeben';
  }

  @override
  String get budget_this_week => 'Diese Woche';

  @override
  String get budget_set_limit => 'Ausgabenlimit festlegen';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name: $amount übrig';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name: $amount drüber';
  }

  @override
  String get budget_all_spending => 'Alle Ausgaben';

  @override
  String get budget_name => 'Name';

  @override
  String get budget_name_placeholder => 'Name';

  @override
  String budget_name_hint(String name) {
    return 'Budgetname: $name';
  }

  @override
  String get budget_what_counts => 'Was zählt';

  @override
  String get budget_wallets => 'Wallets';

  @override
  String get budget_all_wallets => 'Alle Wallets';

  @override
  String get budget_tags => 'Tags';

  @override
  String get budget_any_tag => 'Beliebiger Tag';

  @override
  String get budget_scope_all => 'Zählt jede Ausgabe.';

  @override
  String budget_scope_wallets(String wallets) {
    return 'Zählt Ausgaben aus $wallets.';
  }

  @override
  String budget_scope_tags(String tags) {
    return 'Zählt Ausgaben mit $tags.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return 'Zählt Ausgaben aus $wallets mit $tags.';
  }

  @override
  String get budget_scope_or => 'oder';

  @override
  String get budget_period_section => 'Zeitraum';

  @override
  String get budget_repeats => 'Wiederholung';

  @override
  String get budget_period_weekly => 'Wöchentlich';

  @override
  String get budget_period_monthly => 'Monatlich';

  @override
  String get budget_period_yearly => 'Jährlich';

  @override
  String get budget_period_custom => 'Einmalig';

  @override
  String get budget_starts_on => 'Beginnt am';

  @override
  String get budget_first_day => 'Erster Tag';

  @override
  String get budget_last_day => 'Letzter Tag';

  @override
  String budget_day_of_month(int day) {
    return 'Am $day.';
  }

  @override
  String get budget_start_day_title => 'Starttag';

  @override
  String get budget_start_day_hint => 'Kürzere Monate beginnen am letzten Tag.';

  @override
  String get budget_start_weekday_title => 'Erster Wochentag';

  @override
  String get budget_carry_over => 'Übertrag';

  @override
  String get budget_rollover_none => 'Nicht übertragen';

  @override
  String get budget_rollover_surplus => 'Rest übertragen';

  @override
  String get budget_rollover_both => 'Rest und Überziehung übertragen';

  @override
  String get budget_count_planned => 'Geplantes zählen';

  @override
  String get budget_count_planned_hint => 'Inklusive Anstehendem und Abos';

  @override
  String get budget_count_planned_desc =>
      'Geplante Zahlungen und Abos zählen schon vor der Zahlung zum Limit.';

  @override
  String budget_suggested_months(String amount) {
    return 'Vorschlag: $amount · Ø der letzten 3 Monate';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'Vorschlag: $amount · Ø der letzten 3 Wochen';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'Vorschlag: $amount · Ø der letzten 3 Jahre';
  }

  @override
  String get budget_deleted => 'Budget gelöscht';

  @override
  String budget_delete_title(String name) {
    return '$name löschen?';
  }

  @override
  String get budget_delete_message => 'Deine Buchungen bleiben unverändert.';

  @override
  String get budget_error_name => 'Name bis 40 Zeichen';

  @override
  String get budget_error_dates => 'Der letzte Tag muss nach dem ersten liegen';

  @override
  String get budget_left_caption => 'übrig';

  @override
  String get budget_over_caption => 'drüber';

  @override
  String get budget_under_caption => 'darunter';

  @override
  String budget_spent(String amount) {
    return 'Ausgegeben $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'Geplant $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'Limit $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount übertragen';
  }

  @override
  String get budget_on_track => 'Im Plan';

  @override
  String budget_ahead_of_pace(String amount) {
    return '$amount unter Plan';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return '$amount schneller als geplant';
  }

  @override
  String budget_forecast(String amount) {
    return 'Prognose $amount';
  }

  @override
  String get budget_no_spending => 'In diesem Zeitraum noch keine Ausgaben';

  @override
  String get budgets_active => 'Aktiv';

  @override
  String get budgets_upcoming => 'Anstehend';

  @override
  String get budgets_empty_title => 'Noch keine Budgets';

  @override
  String get budgets_empty_subtitle =>
      'Lege ein Limit fest und behalte den Rest im Blick';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count weitere Budgets',
      one: '+1 weiteres Budget',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$amount/Tag für $_temp0';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abos',
      one: '1 Abo',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Beendet ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Budgets entfernt',
      one: '1 Budget entfernt',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'Schulden';

  @override
  String get debts_owed_to_me => 'Mir geschuldet';

  @override
  String get debts_i_owe => 'Ich schulde';

  @override
  String get debts_empty_owed_title => 'Niemand schuldet dir etwas';

  @override
  String get debts_empty_owe_title => 'Du schuldest niemandem etwas';

  @override
  String get debts_empty_subtitle =>
      'Tippe auf „Neue Schuld“ oder nutze Umbuchung → Schulden im Buchungsbildschirm';

  @override
  String get debt_new => 'Neue Schuld';

  @override
  String get debts_all => 'Alle Schulden';

  @override
  String get debts_empty_hint =>
      'Behalte im Blick, was du verliehen oder geliehen hast';

  @override
  String get dashboard_reorder_hint => 'Halten zum Sortieren';

  @override
  String dashboard_debts_to_receive(String amount) {
    return '$amount zu bekommen';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return '$amount zurückzuzahlen';
  }

  @override
  String get dashboard_new => 'Neu';

  @override
  String get debt_they_owe_me => 'Mir geschuldet';

  @override
  String get debt_i_owe_them => 'Ich schulde';

  @override
  String get debt_person => 'Person';

  @override
  String get debt_person_chip => 'Person';

  @override
  String get debt_person_title => 'Person';

  @override
  String get debt_person_search => 'Name';

  @override
  String get debt_person_empty => 'Noch niemand — gib einen Namen ein';

  @override
  String get debt_person_none => 'Keine Person';

  @override
  String get debt_choose => 'Wählen';

  @override
  String get debt_amount => 'Betrag';

  @override
  String get debt_note_hint => 'Notiz (optional)';

  @override
  String get debt_note_placeholder => 'Notiz';

  @override
  String get debt_due_date => 'Fällig am';

  @override
  String get debt_due_title => 'Fälligkeit';

  @override
  String get debt_add_due => 'Fällig';

  @override
  String get debt_due_change => 'Datum ändern';

  @override
  String get debt_due_remove => 'Fälligkeit entfernen';

  @override
  String get debt_none => 'Keine';

  @override
  String get debt_money_moved => 'Geldbewegung';

  @override
  String get debt_not_in_wallet => 'Nicht über ein Wallet';

  @override
  String get debt_error_person => 'Wähle eine Person';

  @override
  String get debt_gave => 'Gegeben';

  @override
  String get debt_got => 'Erhalten';

  @override
  String get debt_badge_loan => 'Darlehen';

  @override
  String get debt_badge_return => 'Rückzahlung';

  @override
  String get debt_overdue => 'überfällig';

  @override
  String get debt_settled_label => 'Beglichen';

  @override
  String get debt_forgiven_label => 'Erlassen';

  @override
  String get debt_returned_in_full => 'Vollständig zurück';

  @override
  String get debt_paid_in_full => 'Vollständig bezahlt';

  @override
  String get debt_part => 'Teilweise';

  @override
  String get debt_forgive => 'Erlassen';

  @override
  String get debt_remind => 'Erinnern';

  @override
  String get debt_history => 'Verlauf';

  @override
  String get debt_edit_note => 'Notiz bearbeiten';

  @override
  String get debt_rename_person => 'Person umbenennen';

  @override
  String get debt_delete => 'Schuld löschen';

  @override
  String get debt_delete_title => 'Diese Schuld löschen?';

  @override
  String get debt_deleted => 'Schuld gelöscht';

  @override
  String get debt_payment_deleted => 'Zahlung gelöscht';

  @override
  String get debt_return_deleted => 'Rückzahlung gelöscht';

  @override
  String debt_due(String date) {
    return 'fällig $date';
  }

  @override
  String debt_left(String amount) {
    return '$amount offen';
  }

  @override
  String debt_left_of(String amount) {
    return 'offen von $amount';
  }

  @override
  String debt_of(String amount) {
    return 'von $amount';
  }

  @override
  String debt_to_wallet(String wallet) {
    return 'auf $wallet';
  }

  @override
  String debt_from_wallet(String wallet) {
    return 'von $wallet';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name schuldet dir $amount';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return 'Du schuldest $name $amount';
  }

  @override
  String debt_overall(String text) {
    return 'Insgesamt: $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'Insgesamt: $name schuldet dir $owed · du schuldest $owe';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name schuldet dir $amount · „Erhalten“ zählt als Rückzahlung';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return 'Du schuldest $name $amount · „Gegeben“ zählt als Rückzahlung';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name schuldet dir $owed · du schuldest $owe';
  }

  @override
  String debt_hint_none(String name) {
    return 'Keine offenen Schulden mit $name · „Gegeben“ leiht, „Erhalten“ borgt';
  }

  @override
  String debt_person_add(String name) {
    return '„$name“ hinzufügen';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'schuldet dir $amount';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'du schuldest $amount';
  }

  @override
  String debt_title_lent_to(String name) {
    return 'An $name verliehen';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return 'Von $name geliehen';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name hat zurückgezahlt';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return '$name zurückgezahlt';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return '$amount an $name verliehen';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return '$amount von $name geliehen';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name hat $amount zurückgezahlt · $left offen';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name hat $amount zurückgezahlt · alles beglichen';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return '$amount an $name zurückgezahlt · $left offen';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return '$amount an $name zurückgezahlt · alles beglichen';
  }

  @override
  String debt_forgive_title(String name) {
    return '$name die Schuld erlassen?';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'Die restlichen $amount werden erlassen. Kein Geld fließt.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'Schuld erlassen · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'Hallo $name! Kurze Erinnerung an $amount für $note ($date). Danke!';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'Hallo $name! Kurze Erinnerung an $amount ($date). Danke!';
  }

  @override
  String debt_history_lent(String amount) {
    return '$amount verliehen';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return '$amount von $wallet verliehen';
  }

  @override
  String debt_history_borrowed(String amount) {
    return '$amount geliehen';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return '$amount auf $wallet geliehen';
  }

  @override
  String debt_history_returned(String amount) {
    return '$amount zurückerhalten';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return '$amount zurück → $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return '$amount zurückgezahlt';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return '$amount von $wallet zurückgezahlt';
  }

  @override
  String debt_history_forgiven(String amount) {
    return '$amount erlassen';
  }

  @override
  String debts_overdue_count(int count) {
    return '$count überfällig';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schulden',
      one: '1 Schuld',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
      zero: 'Niemand',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Beglichen ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Darlehen mit $count Rückzahlungen gelöscht',
      one: 'Darlehen mit 1 Rückzahlung gelöscht',
      zero: 'Darlehen gelöscht',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Buchungen werden ebenfalls gelöscht.',
      one: '1 Buchung wird ebenfalls gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'Neues Abo';

  @override
  String subscriptions_active_count(int count) {
    return '$count aktiv';
  }

  @override
  String subscriptions_paused_count(int count) {
    return '$count pausiert';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'Lege ein Ausgabenlimit fest, um dieses Konto im Griff zu behalten.';

  @override
  String get wallet_include_in_total => 'Im Gesamtsaldo berücksichtigen';

  @override
  String get wallet_include_in_total_on =>
      'Der Saldo dieses Kontos zählt zur Gesamtsumme auf der Startseite.';

  @override
  String get wallet_include_in_total_off =>
      'Nicht in der Gesamtsumme auf der Startseite – praktisch für Ersparnisse, geteilte oder reine Tracking-Konten.';

  @override
  String get dashboard_wallets_not_counted => 'Nicht im Gesamtsaldo';

  @override
  String dashboard_wallets_excluded(int count) {
    return '$count nicht gezählt';
  }

  @override
  String get budget_rollover_none_desc =>
      'Jeder Zeitraum beginnt neu mit demselben Limit. Rest und Überziehung werden nicht übernommen.';

  @override
  String get budget_rollover_surplus_desc =>
      'Was du nicht ausgegeben hast, kommt zum Limit des nächsten Zeitraums hinzu.';

  @override
  String get budget_rollover_both_desc =>
      'Ein Rest erhöht das nächste Limit, eine Überziehung senkt es.';

  @override
  String get budget_planned_title => 'Geplante Zahlungen';

  @override
  String get budget_planned_exclude => 'Geplantes nicht zählen';

  @override
  String get budget_planned_exclude_desc =>
      'Nur bereits getätigte Zahlungen zählen zum Limit. Geplante Zahlungen und Abos zählen erst, wenn sie bezahlt sind.';

  @override
  String budget_used_percent(int percent) {
    return '$percent % verbraucht';
  }

  @override
  String get budget_stat_spent => 'Ausgegeben';

  @override
  String get budget_stat_limit => 'Limit';

  @override
  String get budget_stat_planned => 'Geplant';

  @override
  String get budget_stat_per_day => 'Pro Tag';

  @override
  String get budget_stat_forecast => 'Prognose';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noch $count Tage',
      one: 'noch 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_monthly_spend => 'Monatliche Ausgaben';

  @override
  String get subscriptions_active_empty => 'Keine aktiven Abos';

  @override
  String get subscriptions_paused_empty => 'Keine pausierten Abos';

  @override
  String budgets_summary_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du liegst über $count Budgets',
      one: 'Du liegst über 1 Budget',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_close(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Budgets sind fast ausgeschöpft',
      one: '1 Budget ist fast ausgeschöpft',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_ok(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Du hältst deine Budgets ein',
      one: 'Du hältst dein Budget ein',
    );
    return '$_temp0';
  }

  @override
  String get budget_edit_title => 'Budget bearbeiten';

  @override
  String get wallet_edit_title => 'Konto bearbeiten';

  @override
  String get budget_tab_overview => 'Übersicht';

  @override
  String get budget_back_to_current => 'Zurück zu heute';

  @override
  String get budget_row_starts => 'Beginnt am';

  @override
  String debt_story_lent_open(String name, String left, String total, String date) {
    return '$name schuldet dir noch $left von $total, die du am $date verliehen hast.';
  }

  @override
  String debt_story_borrowed_open(String name, String left, String total, String date) {
    return 'Du schuldest $name noch $left von $total, die du am $date geliehen hast.';
  }

  @override
  String debt_story_lent_settled(String name, String total, String date) {
    return '$name hat die $total vom $date vollständig zurückgezahlt.';
  }

  @override
  String debt_story_borrowed_settled(String name, String total, String date) {
    return 'Du hast $name die $total vom $date vollständig zurückgezahlt.';
  }

  @override
  String debt_story_forgiven(String total, String date) {
    return 'Am $date abgeschlossen — der Rest der $total wurde erlassen.';
  }

  @override
  String get debt_stat_lent => 'Verliehen';

  @override
  String get debt_stat_borrowed => 'Geliehen';

  @override
  String get debt_stat_paid_back => 'Zurückgezahlt';

  @override
  String get debt_stat_date => 'Datum';

  @override
  String get debt_stat_due => 'Fällig';

  @override
  String get debt_note => 'Notiz';

  @override
  String get debt_add_note => 'Notiz hinzufügen';

  @override
  String get debt_got_part_back => 'Teil erhalten';

  @override
  String get debt_paid_part => 'Teil bezahlt';

  @override
  String get debt_section_details => 'Details';

  @override
  String get debts_to_receive => 'Zu bekommen';

  @override
  String get debts_to_pay => 'Zurückzuzahlen';

  @override
  String get debts_settled_empty => 'Noch keine beglichenen Schulden';

  @override
  String get transfer_debt_pay_back => 'Zurückzahlen';

  @override
  String get transfer_debt_lend => 'Verleihen';

  @override
  String get transfer_debt_lend_someone => 'Jemandem leihen…';

  @override
  String transfer_debt_lend_to(String name) {
    return '$name leihen';
  }

  @override
  String transfer_debt_only_left(String amount) {
    return 'Nur noch $amount offen';
  }

  @override
  String get transfer_debt_locked => 'Eine Schuld kann sich nicht wiederholen oder in der Zukunft liegen';

  @override
  String transfer_debt_summary_repay(String wallet, String amount, String name) {
    return '$wallet −$amount → zahlt $name zurück';
  }

  @override
  String transfer_debt_summary_lend(String wallet, String amount, String name) {
    return '$wallet −$amount → an $name verliehen';
  }

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
