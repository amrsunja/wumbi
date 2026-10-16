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
  String get wallet_tab_transactions => 'Transactions';

  @override
  String get wallet_tab_budgets => 'Budgets';

  @override
  String get wallet_tab_subscriptions => 'Abonnements';

  @override
  String get wallet_budgets_empty =>
      'Aucune limite de dépenses pour ce portefeuille';

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
  String get transaction_edit_title => 'Modifier la transaction';

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
  String get tags_new => 'Nouveau tag';

  @override
  String get tags_create => 'Créer le tag';

  @override
  String tags_created(String name) {
    return '#$name créé';
  }

  @override
  String tags_exists(String name) {
    return '#$name existe déjà';
  }

  @override
  String get tags_parent => 'Tag parent';

  @override
  String get tags_parent_none => 'Aucun parent';

  @override
  String get tags_name_hint => 'ex. café';

  @override
  String get tags_create_tip =>
      'Astuce : tapez repas/café pour imbriquer un tag d\'un coup.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count imbriqués',
      one: '1 imbriqué',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'Comment utiliser les tags ?';

  @override
  String get tags_graph_mode_all => 'Tout';

  @override
  String get tags_graph_mode_spending => 'Dépenses';

  @override
  String get tags_graph_mode_income => 'Revenus';

  @override
  String get tags_graph_legend_size => 'Plus grand = plus d\'argent';

  @override
  String get tags_graph_legend_nested => 'Imbriqué';

  @override
  String get tags_graph_legend_together => 'Utilisés ensemble';

  @override
  String get tags_graph_tap_hint => 'Touchez un cercle pour voir ses chiffres';

  @override
  String get tags_graph_open => 'Ouvrir';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lié à $count tags',
      one: 'Lié à 1 tag',
      zero: 'Aucun lien pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'Déplacer';

  @override
  String tag_move_title(String name) {
    return 'Déplacer #$name';
  }

  @override
  String get tag_moved => 'Tag déplacé';

  @override
  String get tag_add_nested => 'Ajouter un tag imbriqué';

  @override
  String get tag_nested_tags => 'Tags imbriqués';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inclut $count tags imbriqués',
      one: 'Inclut 1 tag imbriqué',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ce tag et ses $count tags imbriqués seront retirés de toutes les transactions. Les transactions restent.',
      one:
          'Ce tag et son tag imbriqué seront retirés de toutes les transactions. Les transactions restent.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'Les tags imbriqués sont renommés aussi. Utilisez / pour le placer sous un autre tag.';

  @override
  String get tag_top_level => 'Premier niveau';

  @override
  String get tag_nested_empty => 'Aucun tag imbriqué pour l\'instant';

  @override
  String get settings_help => 'Besoin d\'aide ?';

  @override
  String get help_title => 'Besoin d\'aide ?';

  @override
  String get help_subtitle =>
      'De courts guides pour tirer le meilleur de Wumbi.';

  @override
  String get help_tags_title => 'Comment utiliser les tags ?';

  @override
  String get help_tags_subtitle => 'Étiquettes, tags imbriqués et carte';

  @override
  String get help_tags_intro =>
      'Les tags sont de courtes étiquettes comme #café que vous ajoutez à vos transactions. Une transaction peut en porter plusieurs : vous regardez ainsi votre argent sous tous les angles, pas seulement par portefeuille.';

  @override
  String get help_tags_add_title => 'Ajouter un tag';

  @override
  String get help_tags_add_body =>
      'En saisissant une transaction, tapez un nom dans le champ des tags, puis choisissez une suggestion ou créez-en un nouveau. Pas d\'espaces dans un tag : écrivez coffee-shop ou coffee_shop. Majuscules et minuscules donnent le même tag.';

  @override
  String get help_tags_nested_title => 'Tags imbriqués';

  @override
  String get help_tags_nested_body =>
      'Utilisez une barre oblique / pour placer un tag dans un autre, comme des dossiers : repas/café et repas/courses vivent tous deux dans repas. Le tag parent est créé pour vous.';

  @override
  String get help_tags_parent_title => 'Un parent inclut ses tags imbriqués';

  @override
  String get help_tags_parent_body =>
      'Ouvrir #repas affiche toutes les transactions taguées #repas, #repas/café ou #repas/courses. Les totaux, filtres et budgets d\'un parent comptent aussi ses tags imbriqués. Une transaction avec les deux tags n\'est comptée qu\'une fois.';

  @override
  String get help_tags_multi_title => 'Plusieurs tags sur une transaction';

  @override
  String get help_tags_multi_body =>
      'Un dîner en vacances peut être #voyage et #repas/restaurant à la fois. Il compte alors dans les deux, et les deux tags sont reliés sur la carte.';

  @override
  String get help_tags_manage_title => 'Créer, renommer, déplacer';

  @override
  String get help_tags_manage_body =>
      'Sur la page Tags, touchez + pour créer un tag et choisissez un parent pour l\'imbriquer. Ouvrez un tag pour le renommer, le déplacer sous un autre parent, lui ajouter un tag imbriqué ou le supprimer. Renommer un parent renomme ses tags imbriqués ; renommer vers un tag existant fusionne les deux.';

  @override
  String get help_tags_map_title => 'Lire la carte';

  @override
  String get help_tags_map_body =>
      'Chaque cercle est un tag : plus il est grand, plus il a fait circuler d\'argent. Son anneau montre la part des dépenses et des revenus. Les traits pleins relient un parent à ses tags imbriqués, les traits légers relient les tags utilisés sur une même transaction. Touchez un cercle pour voir ses chiffres.';

  @override
  String get help_tags_tips_title => 'Astuces';

  @override
  String get help_tags_tip1 =>
      'Commencez large — repas, maison, transport — et n\'imbriquez que si vous voulez plus de détail.';

  @override
  String get help_tags_tip2 =>
      'Utilisez les tags pour ce qui traverse vos portefeuilles : #vacances, #cadeaux, #voiture.';

  @override
  String get help_tags_tip3 =>
      'Gardez des noms courts ; deux ou trois niveaux suffisent.';

  @override
  String get help_tags_example => 'Exemple';

  @override
  String get help_tags_example_total => 'Total de #repas';

  @override
  String get help_tags_ex_parent => 'repas';

  @override
  String get help_tags_ex_child1 => 'café';

  @override
  String get help_tags_ex_child2 => 'courses';

  @override
  String get help_tags_ex_travel => 'voyage';

  @override
  String get help_tags_ex_restaurant => 'restaurant';

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
  String get progress_all_wallets => 'Tous les portefeuilles';

  @override
  String get progress_scope_title => 'Afficher les données de';

  @override
  String progress_not_included(String codes) {
    return '$codes non inclus';
  }

  @override
  String get progress_empty_title => 'Rien à analyser pour l\'instant';

  @override
  String get progress_untagged => 'Sans tag';

  @override
  String get progress_no_expenses => 'Aucune dépense sur cette période';

  @override
  String get progress_empty_subtitle =>
      'Ajoutez quelques transactions et votre progression apparaîtra ici.';

  @override
  String get progress_spent => 'Dépensé';

  @override
  String get progress_spending => 'Dépenses';

  @override
  String get progress_saved => 'Épargné';

  @override
  String get progress_overspent => 'Dépassement';

  @override
  String progress_vs(String label) {
    return 'vs $label';
  }

  @override
  String progress_kept_share(int percent) {
    return 'Vous avez gardé $percent % de vos revenus';
  }

  @override
  String progress_overspent_by(String amount) {
    return 'Vous avez dépensé $amount de plus que vos revenus';
  }

  @override
  String progress_nothing_in(String period) {
    return 'Aucune transaction en $period';
  }

  @override
  String get progress_compare_title => 'Comparer avec';

  @override
  String get progress_baseline_previous_month => 'Mois précédent';

  @override
  String get progress_baseline_previous_year => 'Année précédente';

  @override
  String get progress_baseline_last_year => 'Même mois l\'an dernier';

  @override
  String progress_baseline_average_months(int count) {
    return 'Moyenne des $count derniers mois';
  }

  @override
  String progress_baseline_average_years(int count) {
    return 'Moyenne des $count dernières années';
  }

  @override
  String get progress_baseline_pick_month => 'Choisir un mois';

  @override
  String get progress_baseline_pick_year => 'Choisir une année';

  @override
  String progress_average_months(int count) {
    return 'la moyenne sur $count mois';
  }

  @override
  String progress_average_years(int count) {
    return 'la moyenne sur $count ans';
  }

  @override
  String get progress_pace_title => 'Rythme des dépenses';

  @override
  String progress_pace_less(String amount, String baseline) {
    return '$amount de moins que $baseline à ce stade';
  }

  @override
  String progress_pace_more(String amount, String baseline) {
    return '$amount de plus que $baseline à ce stade';
  }

  @override
  String progress_pace_same(String baseline) {
    return 'Même rythme que $baseline';
  }

  @override
  String progress_total_less(String amount, String baseline) {
    return '$amount de moins que $baseline';
  }

  @override
  String progress_total_more(String amount, String baseline) {
    return '$amount de plus que $baseline';
  }

  @override
  String progress_total_same(String baseline) {
    return 'À peu près comme $baseline';
  }

  @override
  String progress_forecast_month(String amount) {
    return 'À ce rythme ≈ $amount d\'ici la fin du mois';
  }

  @override
  String progress_forecast_year(String amount) {
    return 'À ce rythme ≈ $amount d\'ici la fin de l\'année';
  }

  @override
  String progress_day(int day) {
    return 'Jour $day';
  }

  @override
  String get progress_changes_title => 'Ce qui a changé';

  @override
  String progress_now_was(String now, String was) {
    return '$now maintenant · avant $was';
  }

  @override
  String get progress_new => 'Nouveau';

  @override
  String get progress_breakdown_title => 'Par tag';

  @override
  String get progress_no_income => 'Aucun revenu sur cette période';

  @override
  String progress_show_all(int count) {
    return 'Tout afficher ($count)';
  }

  @override
  String get progress_show_less => 'Afficher moins';

  @override
  String get progress_overlap_hint =>
      'Une transaction avec des tags de plusieurs familles compte dans chacune.';

  @override
  String get progress_habits_title => 'Habitudes';

  @override
  String get progress_daily_average => 'Moyenne par jour';

  @override
  String get progress_biggest_expense => 'Plus grosse dépense';

  @override
  String get progress_recurring => 'Paiements récurrents';

  @override
  String progress_recurring_share(int percent) {
    return '$percent % de vos dépenses';
  }

  @override
  String get progress_average_expense => 'Dépense moyenne';

  @override
  String progress_peak_weekday(String weekday) {
    return 'Vous dépensez le plus le $weekday';
  }

  @override
  String get progress_weekday_hint => 'Dépense moyenne par jour de la semaine';

  @override
  String progress_history_months(int count) {
    return '$count derniers mois';
  }

  @override
  String progress_history_years(int count) {
    return '$count dernières années';
  }

  @override
  String progress_average_per_month(String amount) {
    return 'En moyenne $amount par mois';
  }

  @override
  String progress_average_per_year(String amount) {
    return 'En moyenne $amount par an';
  }

  @override
  String progress_to_date_hint(String baseline) {
    return 'Comparé aux mêmes jours de $baseline';
  }

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
      'Wumbi garde ton argent sur ton téléphone. Tape le montant, appuie sur Revenu ou Dépense, c\'est fait. Pas de compte obligatoire, et rien ne part ailleurs tant que tu ne l\'actives pas.';

  @override
  String get about_support => 'Contacter le support';

  @override
  String get about_read_more => 'En savoir plus sur wumbi.app';

  @override
  String get settings_about_section => 'À propos';

  @override
  String get settings_privacy_policy => 'Politique de confidentialité';

  @override
  String get settings_terms => 'Conditions d\'utilisation';

  @override
  String get settings_press => 'Espace presse';

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
  String debt_error_owes_you_only(String name, String amount) {
    return '$name ne vous doit que $amount';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return 'Vous ne devez que $amount à $name';
  }

  @override
  String get person_error_has_debts =>
      'Réglez ou supprimez d\'abord les dettes de cette personne.';

  @override
  String get debt_error_closed => 'Cette dette est déjà réglée.';

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
  String get dashboard_budgets => 'Budgets';

  @override
  String get budget_new => 'Nouveau budget';

  @override
  String get budget_empty_hint =>
      'Fixez une limite de dépenses pour un portefeuille ou un #tag';

  @override
  String get budgets_all => 'Tous les budgets';

  @override
  String get budgets_title => 'Budgets';

  @override
  String budget_left(String amount) {
    return 'Reste $amount';
  }

  @override
  String budget_over(String amount) {
    return '$amount de dépassement';
  }

  @override
  String budget_starts(String date) {
    return 'Commence le $date';
  }

  @override
  String get budget_ended => 'Terminé';

  @override
  String budget_per_day(String amount) {
    return '$amount/jour';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return '$spent dépensés sur $limit';
  }

  @override
  String get budget_this_week => 'Cette semaine';

  @override
  String get budget_set_limit => 'Fixer une limite de dépenses';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name : reste $amount';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name : $amount de dépassement';
  }

  @override
  String get budget_all_spending => 'Toutes les dépenses';

  @override
  String get budget_name => 'Nom';

  @override
  String get budget_name_placeholder => 'nom';

  @override
  String budget_name_hint(String name) {
    return 'Nom du budget : $name';
  }

  @override
  String get budget_what_counts => 'Ce qui compte';

  @override
  String get budget_wallets => 'Portefeuilles';

  @override
  String get budget_all_wallets => 'Tous les portefeuilles';

  @override
  String get budget_tags => 'Tags';

  @override
  String get budget_any_tag => 'Tout tag';

  @override
  String get budget_scope_all => 'Compte toutes les dépenses.';

  @override
  String budget_scope_wallets(String wallets) {
    return 'Compte les dépenses de $wallets.';
  }

  @override
  String budget_scope_tags(String tags) {
    return 'Compte les dépenses taguées $tags.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return 'Compte les dépenses de $wallets taguées $tags.';
  }

  @override
  String get budget_scope_or => 'ou';

  @override
  String get budget_period_section => 'Période';

  @override
  String get budget_repeats => 'Répétition';

  @override
  String get budget_period_weekly => 'Chaque semaine';

  @override
  String get budget_period_monthly => 'Chaque mois';

  @override
  String get budget_period_yearly => 'Chaque année';

  @override
  String get budget_period_custom => 'Ponctuel';

  @override
  String get budget_starts_on => 'Commence le';

  @override
  String get budget_first_day => 'Premier jour';

  @override
  String get budget_last_day => 'Dernier jour';

  @override
  String budget_day_of_month(int day) {
    return 'Le $day';
  }

  @override
  String get budget_start_day_title => 'Jour de début';

  @override
  String get budget_start_day_hint =>
      'Les mois plus courts commencent leur dernier jour.';

  @override
  String get budget_start_weekday_title => 'Premier jour de la semaine';

  @override
  String get budget_carry_over => 'Report';

  @override
  String get budget_rollover_none => 'Ne pas reporter';

  @override
  String get budget_rollover_surplus => 'Reporter le reste';

  @override
  String get budget_rollover_both => 'Reporter le reste et les dépassements';

  @override
  String get budget_count_planned => 'Compter le prévu';

  @override
  String get budget_count_planned_hint =>
      'Inclut le à venir et les abonnements';

  @override
  String get budget_count_planned_desc =>
      'Les paiements à venir et les abonnements comptent dans la limite avant d\'être payés.';

  @override
  String budget_suggested_months(String amount) {
    return 'Suggéré : $amount · moy. des 3 derniers mois';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'Suggéré : $amount · moy. des 3 dernières semaines';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'Suggéré : $amount · moy. des 3 dernières années';
  }

  @override
  String get budget_deleted => 'Budget supprimé';

  @override
  String budget_delete_title(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get budget_delete_message => 'Vos transactions restent inchangées.';

  @override
  String get budget_error_name => 'Nom de 40 caractères max.';

  @override
  String get budget_error_dates => 'Le dernier jour doit suivre le premier';

  @override
  String get budget_left_caption => 'restant';

  @override
  String get budget_over_caption => 'de dépassement';

  @override
  String get budget_under_caption => 'en dessous';

  @override
  String budget_spent(String amount) {
    return 'Dépensé $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'Prévu $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'Limite $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount reporté';
  }

  @override
  String get budget_on_track => 'Dans les temps';

  @override
  String budget_ahead_of_pace(String amount) {
    return '$amount d’avance';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return '$amount plus vite que prévu';
  }

  @override
  String budget_forecast(String amount) {
    return 'prévision $amount';
  }

  @override
  String get budget_no_spending => 'Aucune dépense sur cette période';

  @override
  String get budgets_active => 'Actifs';

  @override
  String get budgets_upcoming => 'À venir';

  @override
  String get budgets_empty_title => 'Aucun budget';

  @override
  String get budgets_empty_subtitle =>
      'Fixez une limite et suivez ce qu’il reste';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count autres budgets',
      one: '+1 autre budget',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$amount/jour pendant $_temp0';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonnements',
      one: '1 abonnement',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Terminés ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets supprimés',
      one: '1 budget supprimé',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'Dettes';

  @override
  String get debts_owed_to_me => 'On me doit';

  @override
  String get debts_i_owe => 'Je dois';

  @override
  String get debts_empty_owed_title => 'Personne ne vous doit rien';

  @override
  String get debts_empty_owe_title => 'Vous ne devez rien à personne';

  @override
  String get debts_empty_subtitle =>
      'Touchez « Nouvelle dette » ou Virement → Dettes sur l’écran de transaction';

  @override
  String get debt_new => 'Nouvelle dette';

  @override
  String get debts_all => 'Toutes les dettes';

  @override
  String get debts_empty_hint => 'Suivez l’argent prêté ou emprunté';

  @override
  String get dashboard_reorder_hint => 'Maintenir pour réorganiser';

  @override
  String dashboard_debts_to_receive(String amount) {
    return '$amount à recevoir';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return '$amount à rendre';
  }

  @override
  String get dashboard_new => 'Nouveau';

  @override
  String get debt_they_owe_me => 'On me doit';

  @override
  String get debt_i_owe_them => 'Je dois';

  @override
  String get debt_person => 'Qui';

  @override
  String get debt_person_chip => 'Qui';

  @override
  String get debt_person_title => 'Avec qui ?';

  @override
  String get debt_person_search => 'Nom — personne, banque, magasin…';

  @override
  String get debt_person_empty => 'Personne pour l’instant — tapez un nom';

  @override
  String get debt_person_none => 'Personne';

  @override
  String get debt_choose => 'Choisir';

  @override
  String get debt_amount => 'Montant';

  @override
  String get debt_note_hint => 'Note (facultatif)';

  @override
  String get debt_note_placeholder => 'note';

  @override
  String get debt_due_date => 'Échéance';

  @override
  String get debt_due_title => 'Échéance';

  @override
  String get debt_add_due => 'Échéance';

  @override
  String get debt_due_change => 'Changer la date';

  @override
  String get debt_due_remove => 'Retirer l’échéance';

  @override
  String get debt_none => 'Aucune';

  @override
  String get debt_money_moved => 'Argent déplacé';

  @override
  String get debt_not_in_wallet => 'Hors portefeuille';

  @override
  String get debt_error_person => 'Choisissez avec qui';

  @override
  String get debt_gave => 'Donné';

  @override
  String get debt_got => 'Reçu';

  @override
  String get debt_badge_loan => 'Prêt';

  @override
  String get debt_badge_return => 'Retour';

  @override
  String get debt_overdue => 'en retard';

  @override
  String get debt_settled_label => 'Réglé';

  @override
  String get debt_forgiven_label => 'Annulé';

  @override
  String get debt_returned_in_full => 'Remboursé en totalité';

  @override
  String get debt_paid_in_full => 'Payé en totalité';

  @override
  String get debt_part => 'Partiel';

  @override
  String get debt_forgive => 'Annuler';

  @override
  String get debt_remind => 'Rappeler';

  @override
  String get debt_history => 'Historique';

  @override
  String get debt_edit_note => 'Modifier la note';

  @override
  String get debt_rename_person => 'Renommer';

  @override
  String get debt_delete => 'Supprimer la dette';

  @override
  String get debt_delete_title => 'Supprimer cette dette ?';

  @override
  String get debt_deleted => 'Dette supprimée';

  @override
  String get debt_payment_deleted => 'Paiement supprimé';

  @override
  String get debt_return_deleted => 'Remboursement supprimé';

  @override
  String debt_due(String date) {
    return 'échéance $date';
  }

  @override
  String debt_left(String amount) {
    return 'reste $amount';
  }

  @override
  String debt_left_of(String amount) {
    return 'restant sur $amount';
  }

  @override
  String debt_of(String amount) {
    return 'sur $amount';
  }

  @override
  String debt_to_wallet(String wallet) {
    return 'vers $wallet';
  }

  @override
  String debt_from_wallet(String wallet) {
    return 'depuis $wallet';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name vous doit $amount';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return 'Vous devez $amount à $name';
  }

  @override
  String debt_overall(String text) {
    return 'Au total : $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'Au total : $name vous doit $owed · vous devez $owe';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name vous doit $amount · « Reçu » compte comme un remboursement';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return 'Vous devez $amount à $name · « Donné » compte comme un remboursement';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name vous doit $owed · vous devez $owe';
  }

  @override
  String debt_hint_none(String name) {
    return 'Aucune dette ouverte avec $name · « Donné » prête, « Reçu » emprunte';
  }

  @override
  String debt_person_add(String name) {
    return 'Ajouter « $name »';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'vous doit $amount';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'vous devez $amount';
  }

  @override
  String debt_title_lent_to(String name) {
    return 'Prêté à $name';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return 'Emprunté à $name';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name a remboursé';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return 'Remboursé à $name';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return '$amount prêtés à $name';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return '$amount empruntés à $name';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name a rendu $amount · reste $left';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name a rendu $amount · tout est réglé';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return '$amount remboursés à $name · reste $left';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return '$amount remboursés à $name · tout est réglé';
  }

  @override
  String debt_forgive_title(String name) {
    return 'Annuler la dette de $name ?';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'Les $amount restants seront annulés. Aucun argent ne bouge.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'Dette annulée · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'Salut $name ! Petit rappel pour $amount ($note, $date). Merci !';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'Salut $name ! Petit rappel pour $amount ($date). Merci !';
  }

  @override
  String debt_history_lent(String amount) {
    return 'Prêté $amount';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return 'Prêté $amount depuis $wallet';
  }

  @override
  String debt_history_borrowed(String amount) {
    return 'Emprunté $amount';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return 'Emprunté $amount vers $wallet';
  }

  @override
  String debt_history_returned(String amount) {
    return 'Rendu $amount';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return 'Rendu $amount → $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return 'Remboursé $amount';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return 'Remboursé $amount depuis $wallet';
  }

  @override
  String debt_history_forgiven(String amount) {
    return 'Annulé $amount';
  }

  @override
  String debts_overdue_count(int count) {
    return '$count en retard';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dettes',
      one: '1 dette',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
      zero: 'Personne',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Réglées ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prêt supprimé avec $count remboursements',
      one: 'Prêt supprimé avec 1 remboursement',
      zero: 'Prêt supprimé',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions seront aussi supprimées.',
      one: '1 transaction sera aussi supprimée.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'Nouvel abonnement';

  @override
  String subscriptions_active_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs',
      one: '1 actif',
      zero: '0 actif',
    );
    return '$_temp0';
  }

  @override
  String subscriptions_paused_count(int count) {
    return '$count en pause';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'Fixez une limite de dépenses pour garder ce portefeuille sous contrôle.';

  @override
  String get wallet_include_in_total => 'Inclure dans le solde total';

  @override
  String get wallet_include_in_total_on =>
      'Le solde de ce portefeuille est ajouté au total de l\'accueil.';

  @override
  String get wallet_include_in_total_off =>
      'Exclu du total de l\'accueil — pratique pour l\'épargne, les portefeuilles partagés ou de suivi.';

  @override
  String get dashboard_wallets_not_counted => 'Non inclus dans le total';

  @override
  String dashboard_wallets_excluded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non comptés',
      one: '1 non compté',
    );
    return '$_temp0';
  }

  @override
  String get budget_rollover_none_desc =>
      'Chaque période repart de zéro avec la même limite. Le reste et les dépassements ne sont pas reportés.';

  @override
  String get budget_rollover_surplus_desc =>
      'Ce que vous n\'avez pas dépensé s\'ajoute à la limite de la période suivante.';

  @override
  String get budget_rollover_both_desc =>
      'Le reste augmente la limite suivante, un dépassement la réduit.';

  @override
  String get budget_planned_title => 'Paiements prévus';

  @override
  String get budget_planned_exclude => 'Ne pas compter le prévu';

  @override
  String get budget_planned_exclude_desc =>
      'Seuls les paiements déjà effectués comptent dans la limite. Les paiements à venir et les abonnements comptent une fois payés.';

  @override
  String budget_used_percent(int percent) {
    return '$percent % utilisé';
  }

  @override
  String get budget_stat_spent => 'Dépensé';

  @override
  String get budget_stat_limit => 'Limite';

  @override
  String get budget_stat_planned => 'Prévu';

  @override
  String get budget_stat_per_day => 'Par jour';

  @override
  String get budget_stat_forecast => 'Prévision';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants',
      one: '1 jour restant',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_monthly_spend => 'Dépenses mensuelles';

  @override
  String get subscriptions_active_empty => 'Aucun abonnement actif';

  @override
  String get subscriptions_paused_empty => 'Aucun abonnement en pause';

  @override
  String budgets_summary_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous dépassez $count budgets',
      one: 'Vous dépassez 1 budget',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_close(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets approchent de leur limite',
      one: '1 budget approche de sa limite',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_ok(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vous respectez vos budgets',
      one: 'Vous respectez votre budget',
    );
    return '$_temp0';
  }

  @override
  String get budget_edit_title => 'Modifier le budget';

  @override
  String get wallet_edit_title => 'Modifier le portefeuille';

  @override
  String get budget_tab_overview => 'Aperçu';

  @override
  String get budget_back_to_current => 'Revenir à aujourd\'hui';

  @override
  String get budget_row_starts => 'Commence le';

  @override
  String debt_story_lent_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return '$name vous doit encore $left sur les $total prêtés le $date.';
  }

  @override
  String debt_story_borrowed_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return 'Vous devez encore $left à $name sur les $total empruntés le $date.';
  }

  @override
  String debt_story_lent_settled(String name, String total, String date) {
    return '$name a remboursé les $total prêtés le $date.';
  }

  @override
  String debt_story_borrowed_settled(String name, String total, String date) {
    return 'Vous avez remboursé les $total empruntés à $name le $date.';
  }

  @override
  String debt_story_forgiven(String total, String date) {
    return 'Clôturée le $date — le reste des $total a été annulé.';
  }

  @override
  String get debt_stat_lent => 'Prêté';

  @override
  String get debt_stat_borrowed => 'Emprunté';

  @override
  String get debt_stat_paid_back => 'Remboursé';

  @override
  String get debt_stat_date => 'Date';

  @override
  String get debt_stat_due => 'Échéance';

  @override
  String get debt_note => 'Note';

  @override
  String get debt_add_note => 'Ajouter une note';

  @override
  String get debt_got_part_back => 'Reçu en partie';

  @override
  String get debt_paid_part => 'Payé en partie';

  @override
  String get debt_section_details => 'Détails';

  @override
  String get debts_to_receive => 'À recevoir';

  @override
  String get debts_to_pay => 'À rembourser';

  @override
  String get debts_settled_empty => 'Aucune dette réglée';

  @override
  String get transfer_debt_pay_back => 'Rembourser';

  @override
  String get transfer_debt_lend => 'Prêter';

  @override
  String get transfer_debt_lend_someone => 'Prêter à…';

  @override
  String transfer_debt_lend_to(String name) {
    return 'Prêter à $name';
  }

  @override
  String transfer_debt_only_left(String amount) {
    return 'Il ne reste que $amount';
  }

  @override
  String get transfer_debt_locked =>
      'Une dette ne peut pas se répéter ni être datée dans le futur';

  @override
  String transfer_debt_summary_repay(
    String wallet,
    String amount,
    String name,
  ) {
    return '$wallet −$amount → rembourse $name';
  }

  @override
  String transfer_debt_summary_lend(String wallet, String amount, String name) {
    return '$wallet −$amount → prêté à $name';
  }

  @override
  String get debt_wallet_title_in => 'Où l’argent est-il arrivé ?';

  @override
  String get debt_wallet_title_out => 'D’où avez-vous payé ?';

  @override
  String debt_wallet_explain_in(String name, String amount) {
    return '$name vous a rendu $amount. Sur quel portefeuille est-il arrivé ? On l’y ajoute. Si c’était du liquide que vous ne suivez pas, choisissez « Hors portefeuille ».';
  }

  @override
  String debt_wallet_explain_out(String name, String amount) {
    return 'Vous remboursez $amount à $name. De quel portefeuille part l’argent ? On le retire de celui-ci. Si vous avez payé en liquide non suivi, choisissez « Hors portefeuille ».';
  }

  @override
  String get debt_wallet_only_debt =>
      'Aucun portefeuille ne change, seulement la dette';

  @override
  String debt_wallet_confirm_in(String wallet) {
    return 'Ajouter à $wallet';
  }

  @override
  String debt_wallet_confirm_out(String wallet) {
    return 'Payer depuis $wallet';
  }

  @override
  String get debt_wallet_confirm_none => 'Enregistrer sans portefeuille';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
