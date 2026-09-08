// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appLanguage => 'Français';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'Continuer';

  @override
  String get common_cancel => 'Annuler';

  @override
  String get common_save => 'Enregistrer';

  @override
  String get common_delete => 'Supprimer';

  @override
  String get common_confirm => 'Confirmer';

  @override
  String get common_undo => 'Annuler';

  @override
  String get common_ok => 'OK';

  @override
  String get common_retry => 'Réessayer';

  @override
  String get common_today => 'Aujourd\'hui';

  @override
  String get common_yesterday => 'Hier';

  @override
  String get common_income => 'Revenu';

  @override
  String get common_expense => 'Dépense';

  @override
  String get common_transfer => 'Virement';

  @override
  String get common_edit => 'Modifier';

  @override
  String get common_all => 'Tout';

  @override
  String get common_clear => 'Effacer';

  @override
  String get common_apply => 'Appliquer';

  @override
  String get common_done => 'Terminé';

  @override
  String get common_close => 'Fermer';

  @override
  String get common_search => 'Rechercher';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Voici Wumbi';

  @override
  String get onboarding_welcome_subtitle =>
      'Suis ton argent en quelques secondes. Pas de catégories, juste des tags.';

  @override
  String get onboarding_currency_title => 'Ta devise principale';

  @override
  String get onboarding_currency_subtitle =>
      'Les totaux s\'affichent dans cette devise. Tu pourras la changer dans les Réglages.';

  @override
  String get onboarding_wallet_title => 'Ton premier portefeuille';

  @override
  String get onboarding_wallet_subtitle =>
      'Chaque portefeuille a une seule devise. Tu pourras en ajouter d\'autres plus tard.';

  @override
  String get onboarding_create_wallet => 'Créer le portefeuille';

  @override
  String get common_skip => 'Passer';

  @override
  String get onboarding_welcome_start => 'Commencer';

  @override
  String get onboarding_benefit_wallets_title =>
      'Des portefeuilles dans toutes les devises';

  @override
  String get onboarding_benefit_wallets_body =>
      'Dollars, euros, bitcoin — chaque portefeuille garde sa propre devise. Ton total s\'affiche dans celle que tu choisis.';

  @override
  String get onboarding_benefit_tags_title => 'Des tags, pas des catégories';

  @override
  String get onboarding_benefit_tags_body =>
      'Oublie les catégories rigides. Ajoute les tags que tu veux — #coffee, #trip, #work — et retrouve tout plus tard.';

  @override
  String get onboarding_benefit_one_tap_title => 'Note-le en un tap';

  @override
  String get onboarding_benefit_one_tap_body =>
      'Saisis le montant, touche Revenu ou Dépense. C\'est fait. L\'écran reste ouvert pour le suivant.';

  @override
  String get onboarding_how_title => 'Comment ça marche';

  @override
  String get onboarding_how_body =>
      'Crée un portefeuille, note l\'argent qui bouge et vois tes totaux se mettre à jour aussitôt.';

  @override
  String get onboarding_how_step_wallet => 'Ajoute un portefeuille';

  @override
  String get onboarding_how_step_tap => 'Touche pour noter';

  @override
  String get onboarding_how_step_totals => 'Vois tes totaux';

  @override
  String get onboarding_wallet_hero_prefix => 'Crée ton premier';

  @override
  String get onboarding_wallet_hero_accent => 'Portefeuille';

  @override
  String get onboarding_final_title => 'Tout est prêt !';

  @override
  String get onboarding_final_body =>
      'Ton premier portefeuille est prêt. Wumbi garde le reste tout simple.';

  @override
  String get onboarding_final_button => 'C\'est parti';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'Mon argent';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sur $count portefeuilles',
      one: 'Sur 1 portefeuille',
      zero: 'Aucun portefeuille',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes non inclus';
  }

  @override
  String get dashboard_wallets => 'Portefeuilles';

  @override
  String get dashboard_new_wallet => 'Nouveau portefeuille';

  @override
  String get dashboard_empty_title => 'Crée ton premier portefeuille';

  @override
  String get dashboard_empty_subtitle =>
      'Wumbi a besoin d\'un portefeuille pour ranger ton argent.';

  @override
  String get dashboard_tags => 'Tags';

  @override
  String get dashboard_subscriptions => 'Abonnements';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'Nom du portefeuille';

  @override
  String get wallet_currency => 'Devise';

  @override
  String get wallet_primary => 'Portefeuille principal';

  @override
  String get wallet_has_transactions => 'Contient des transactions';

  @override
  String get wallet_pick_another_primary =>
      'Choisis un autre portefeuille principal';

  @override
  String wallet_delete_title(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get wallet_delete_message =>
      'Ses transactions seront supprimées. Les virements avec d\'autres portefeuilles restent visibles.';

  @override
  String get wallet_deleted => 'Portefeuille supprimé';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Portefeuille supprimé · $count répétitions en pause',
      one: 'Portefeuille supprimé · 1 répétition en pause',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'Aucune transaction';

  @override
  String get wallet_empty_subtitle => 'Touche + pour en ajouter une';

  @override
  String get wallet_switch_title => 'Changer de portefeuille';

  @override
  String wallet_transfer_to(String name) {
    return 'Virement vers $name';
  }

  @override
  String wallet_transfer_from(String name) {
    return 'Virement depuis $name';
  }

  @override
  String get wallet_deleted_suffix => '(supprimé)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count récurrentes',
      one: '1 récurrente',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'Ce portefeuille n\'existe plus';

  @override
  String get wallet_filter => 'Filtrer';

  @override
  String get wallet_sort => 'Trier';

  @override
  String get wallet_filter_title => 'Filtrer les transactions';

  @override
  String get wallet_filter_type => 'Type';

  @override
  String get wallet_filter_date => 'Date';

  @override
  String get wallet_filter_tags => 'Tags';

  @override
  String get wallet_filter_from => 'Du';

  @override
  String get wallet_filter_to => 'Au';

  @override
  String get wallet_filter_any_date => 'Toutes dates';

  @override
  String get wallet_filter_this_month => 'Ce mois-ci';

  @override
  String get wallet_filter_last_month => 'Mois dernier';

  @override
  String get wallet_filter_last_30_days => '30 derniers jours';

  @override
  String get wallet_filter_this_year => 'Cette année';

  @override
  String get wallet_filter_custom_range => 'Période perso';

  @override
  String get wallet_filter_upcoming_only => 'À venir seulement';

  @override
  String get wallet_filter_clear => 'Effacer les filtres';

  @override
  String get wallet_filter_no_tags => 'Aucun tag dans ce portefeuille';

  @override
  String get wallet_filter_no_results_title => 'Aucun résultat';

  @override
  String get wallet_filter_no_results_subtitle =>
      'Essaie de retirer un filtre.';

  @override
  String wallet_filter_active(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtres',
      one: '1 filtre',
    );
    return '$_temp0';
  }

  @override
  String get wallet_sort_title => 'Trier par';

  @override
  String get sort_date_newest => 'Plus récentes';

  @override
  String get sort_date_oldest => 'Plus anciennes';

  @override
  String get sort_amount_high => 'Plus gros montant';

  @override
  String get sort_amount_low => 'Plus petit montant';

  @override
  String get wallet_upcoming_section => 'À venir';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions à venir pas encore comptées',
      one: '1 transaction à venir pas encore comptée',
    );
    return '$_temp0';
  }

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'Modifier';

  @override
  String get transaction_description_placeholder => 'description';

  @override
  String get transaction_tags_placeholder => '#tags';

  @override
  String get transaction_repeat => 'Répéter';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · fait partie d\'une répétition';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount seront ajoutés à $wallet';
  }

  @override
  String transaction_hint_stale(String date) {
    return 'taux du $date';
  }

  @override
  String get transaction_rate_unavailable =>
      'Taux indisponible — connecte-toi pour l\'actualiser';

  @override
  String transaction_saved(String amount, String wallet) {
    return '$amount enregistré dans $wallet';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return '$amount déplacé vers $wallet';
  }

  @override
  String get transaction_deleted => 'Transaction supprimée';

  @override
  String get transaction_upcoming_badge => 'À venir';

  @override
  String transaction_upcoming_hint(String date) {
    return 'Comptée le $date';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return '$amount planifié pour le $date';
  }

  @override
  String get transaction_delete_title => 'Supprimer cette transaction ?';

  @override
  String get transaction_delete_this_one => 'Supprimer celle-ci';

  @override
  String get transaction_delete_and_stop =>
      'Supprimer et arrêter la répétition';

  @override
  String get transaction_need_second_wallet_title =>
      'Crée un deuxième portefeuille pour un virement';

  @override
  String get transaction_need_second_wallet_message =>
      'Les virements déplacent de l\'argent entre deux de tes portefeuilles.';

  @override
  String get transaction_different_currency => 'Devise différente';

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
    return 'Virement de $amount depuis $wallet';
  }

  @override
  String get transfer_amount_received => 'Montant reçu';

  @override
  String get transfer_confirm => 'Confirmer le virement';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'Jamais';

  @override
  String get repeat_every_day => 'Chaque jour';

  @override
  String get repeat_every_week => 'Chaque semaine';

  @override
  String get repeat_every_month => 'Chaque mois';

  @override
  String get repeat_every_year => 'Chaque année';

  @override
  String get repeat_daily => 'Quotidien';

  @override
  String get repeat_weekly => 'Hebdomadaire';

  @override
  String get repeat_monthly => 'Mensuel';

  @override
  String get repeat_yearly => 'Annuel';

  @override
  String get repeat_rules_title => 'Abonnements';

  @override
  String get repeat_rules_hint =>
      'Touche un abonnement pour le modifier. Les transactions existantes ne changent jamais.';

  @override
  String repeat_next(String date) {
    return 'Prochain : $date';
  }

  @override
  String get repeat_paused => 'En pause';

  @override
  String get repeat_delete_title => 'Arrêter cette répétition ?';

  @override
  String get repeat_delete_message =>
      'Les transactions existantes restent. Aucune nouvelle ne sera créée.';

  @override
  String get repeat_stop => 'Arrêter';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'Choisis une date';

  @override
  String get date_pick_from => 'Du';

  @override
  String get date_pick_to => 'Au';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'Recherche';

  @override
  String get search_placeholder => 'Description, montant, portefeuille ou tag';

  @override
  String get search_hint =>
      'Cherche dans tous les portefeuilles par description, montant, nom ou tag.';

  @override
  String get search_no_results_title => 'Aucun résultat';

  @override
  String get search_no_results_subtitle =>
      'Essaie un autre mot, montant ou tag.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
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
  String get tags_view_graph => 'Carte';

  @override
  String get tags_search_placeholder => 'Rechercher un tag';

  @override
  String get tags_empty_title => 'Aucun tag';

  @override
  String get tags_empty_subtitle =>
      'Ajoute des #tags à une transaction et ils apparaîtront ici.';

  @override
  String get tags_search_no_results => 'Aucun tag ne correspond';

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
      zero: 'Jamais utilisé',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'Dépensé';

  @override
  String get tags_earned => 'Gagné';

  @override
  String get tags_net => 'Net';

  @override
  String tags_not_included(String codes) {
    return '$codes non inclus';
  }

  @override
  String get tags_graph_hint =>
      'Les plus grands cercles ont bougé le plus d\'argent. Les lignes relient les tags utilisés ensemble.';

  @override
  String get tags_graph_empty =>
      'Ajoute des tags à quelques transactions pour voir la carte.';

  @override
  String get tag_wallets => 'Portefeuilles';

  @override
  String get tag_transactions => 'Transactions';

  @override
  String get tag_no_transactions => 'Aucune transaction avec ce tag';

  @override
  String get tag_rename => 'Renommer le tag';

  @override
  String get tag_name_placeholder => 'Nom du tag';

  @override
  String get tag_delete => 'Supprimer le tag';

  @override
  String tag_delete_title(String name) {
    return 'Supprimer #$name ?';
  }

  @override
  String get tag_delete_message =>
      'Il sera retiré de toutes les transactions. Les transactions, elles, restent.';

  @override
  String get tag_deleted => 'Tag supprimé';

  @override
  String get tag_renamed => 'Tag renommé';

  @override
  String tag_merged(String name) {
    return 'Fusionné avec #$name';
  }

  @override
  String get tag_not_found => 'Ce tag n\'existe plus';

  @override
  String get tag_wallet_deleted => '(supprimé)';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'Abonnements';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
      zero: 'Aucun abonnement',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'Aucun abonnement';

  @override
  String get subscriptions_empty_subtitle =>
      'Active Répéter sur une transaction et elle apparaîtra ici.';

  @override
  String get subscriptions_all_wallets => 'Tous les portefeuilles';

  @override
  String get subscriptions_active => 'Actifs';

  @override
  String get subscriptions_paused => 'En pause';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / mois';
  }

  @override
  String get subscriptions_edit_title => 'Modifier l\'abonnement';

  @override
  String get subscriptions_amount => 'Montant';

  @override
  String get subscriptions_wallet => 'Portefeuille';

  @override
  String get subscriptions_from_wallet => 'Depuis le portefeuille';

  @override
  String get subscriptions_to_wallet => 'Vers le portefeuille';

  @override
  String get subscriptions_frequency => 'Fréquence';

  @override
  String get subscriptions_description => 'Description';

  @override
  String get subscriptions_tags => 'Tags';

  @override
  String get subscriptions_pause => 'Pause';

  @override
  String get subscriptions_resume => 'Reprendre';

  @override
  String get subscriptions_stop => 'Arrêter l\'abonnement';

  @override
  String get subscriptions_saved => 'Abonnement mis à jour';

  @override
  String get subscriptions_stopped => 'Abonnement arrêté';

  @override
  String get subscriptions_type_hint =>
      'Le type d\'un abonnement ne peut pas changer.';

  @override
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'Progression';

  @override
  String get progress_month => 'Mois';

  @override
  String get progress_year => 'Année';

  @override
  String get progress_income => 'Revenu';

  @override
  String get progress_expense => 'Dépense';

  @override
  String get progress_net => 'Net';

  @override
  String get progress_vs_last_month => 'vs le mois dernier';

  @override
  String get progress_vs_last_year => 'vs l\'année dernière';

  @override
  String get progress_all_wallets => 'Tous les portefeuilles';

  @override
  String get progress_scope_title => 'Afficher les données de';

  @override
  String get progress_chart_title => 'Revenus vs Dépenses';

  @override
  String progress_not_included(String codes) {
    return '$codes non inclus';
  }

  @override
  String get progress_empty_title => 'Rien à analyser pour l\'instant';

  @override
  String get progress_trend_title => 'Tendance';

  @override
  String get progress_tags_title => 'Dépenses par tag';

  @override
  String get progress_untagged => 'Sans tag';

  @override
  String get progress_other_tags => 'Autres';

  @override
  String get progress_no_expenses => 'Aucune dépense sur cette période';

  @override
  String get progress_empty_subtitle =>
      'Ajoutez quelques transactions et votre progression apparaîtra ici.';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Devise';

  @override
  String get currency_no_results => 'Aucune devise trouvée';

  @override
  String get currency_base_title => 'Devise principale';

  @override
  String get currency_base_hint =>
      'Ton solde total est converti dans cette devise.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'Réglages';

  @override
  String get settings_preferences => 'Préférences';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_currency => 'Devise';

  @override
  String get settings_dark_mode => 'Mode sombre';

  @override
  String get settings_show_mascot => 'Afficher la mascotte';

  @override
  String get settings_data_privacy => 'Données et vie privée';

  @override
  String get settings_export_transactions => 'Exporter les transactions';

  @override
  String get settings_reset_all_data => 'Tout réinitialiser';

  @override
  String get settings_reset_title => 'Tout réinitialiser ?';

  @override
  String get settings_reset_message =>
      'Tous les portefeuilles, transactions et réglages de cet appareil seront effacés. C\'est irréversible.';

  @override
  String get settings_reset_action => 'Réinitialiser';

  @override
  String get settings_reset_done => 'Données effacées';

  @override
  String settings_version(String version, String build) {
    return 'Version : $version ($build)';
  }

  @override
  String get settings_language => 'Langue';

  @override
  String get settings_manage => 'Gérer';

  @override
  String get settings_tags => 'Tags';

  @override
  String get settings_subscriptions => 'Abonnements';

  @override
  String get settings_language_info =>
      'Choisis la langue de l\'interface de l\'application.';

  @override
  String get settings_theme => 'Thème';

  @override
  String get settings_theme_system => 'Système';

  @override
  String get settings_theme_light => 'Clair';

  @override
  String get settings_theme_dark => 'Sombre';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'À propos de Wumbi';

  @override
  String get about_project => 'À propos du projet';

  @override
  String get about_text =>
      'Wumbi est une app de budget minimaliste qui fonctionne d\'abord en local. Tes données sont chiffrées et ne quittent jamais ton appareil.';

  @override
  String get about_support => 'Contacter le support';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'Saisis un montant';

  @override
  String validation_up_to_tags(int count) {
    return '$count tags maximum';
  }

  @override
  String get validation_rate_unavailable => 'Taux indisponible';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'Erreur de base de données, réessaie.';

  @override
  String get error_unknown => 'Une erreur est survenue. Réessaie.';

  @override
  String get error_rate_unavailable =>
      'Aucun taux de change disponible. Connecte-toi à Internet et réessaie.';

  @override
  String get error_validation => 'Vérifie les valeurs saisies.';

  @override
  String get error_wallet_has_transactions =>
      'La devise ne peut plus changer une fois que le portefeuille a des transactions.';

  @override
  String get error_not_found => 'Cet élément n\'existe plus.';

  @override
  String get error_tag_name => 'Saisis un nom de tag (30 caractères max).';

  @override
  String get error_open_db_title => 'Impossible d\'ouvrir tes données';

  @override
  String get error_open_db_message =>
      'Wumbi n\'a pas pu déverrouiller la base de données sur cet appareil.';

  @override
  String get error_reset_app => 'Réinitialiser l\'app';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
