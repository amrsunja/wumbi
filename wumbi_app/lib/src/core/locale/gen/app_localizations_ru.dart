// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appLanguage => 'Русский';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'Продолжить';

  @override
  String get common_cancel => 'Отмена';

  @override
  String get common_save => 'Сохранить';

  @override
  String get common_delete => 'Удалить';

  @override
  String get common_confirm => 'Подтвердить';

  @override
  String get common_undo => 'Вернуть';

  @override
  String get common_ok => 'ОК';

  @override
  String get common_retry => 'Ещё раз';

  @override
  String get common_today => 'Сегодня';

  @override
  String get common_yesterday => 'Вчера';

  @override
  String get common_income => 'Доход';

  @override
  String get common_expense => 'Расход';

  @override
  String get common_transfer => 'Перевод';

  @override
  String get common_edit => 'Изменить';

  @override
  String get common_all => 'Все';

  @override
  String get common_clear => 'Очистить';

  @override
  String get common_apply => 'Применить';

  @override
  String get common_done => 'Готово';

  @override
  String get common_close => 'Закрыть';

  @override
  String get common_search => 'Поиск';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Знакомься, Wumbi';

  @override
  String get onboarding_welcome_subtitle =>
      'Учёт денег за секунды. Без категорий — только теги.';

  @override
  String get onboarding_currency_title => 'Твоя основная валюта';

  @override
  String get onboarding_currency_subtitle =>
      'Итоги показываются в этой валюте. Её можно поменять позже в настройках.';

  @override
  String get onboarding_wallet_title => 'Твой первый кошелёк';

  @override
  String get onboarding_wallet_subtitle =>
      'У каждого кошелька одна валюта. Другие кошельки добавишь позже.';

  @override
  String get onboarding_create_wallet => 'Создать кошелёк';

  @override
  String get common_skip => 'Пропустить';

  @override
  String get onboarding_welcome_start => 'Начать';

  @override
  String get onboarding_benefit_wallets_title => 'Кошельки в любой валюте';

  @override
  String get onboarding_benefit_wallets_body =>
      'Доллары, евро, биткоин — у каждого кошелька своя валюта. Общий итог покажем в той, которую выберешь.';

  @override
  String get onboarding_benefit_tags_title => 'Теги вместо категорий';

  @override
  String get onboarding_benefit_tags_body =>
      'Забудь про жёсткие категории. Ставь любые теги — #coffee, #trip, #work — и находи всё что угодно.';

  @override
  String get onboarding_benefit_one_tap_title => 'Запись в одно касание';

  @override
  String get onboarding_benefit_one_tap_body =>
      'Введи сумму, нажми «Доход» или «Расход». Готово. Экран останется открытым для следующей.';

  @override
  String get onboarding_how_title => 'Как это работает';

  @override
  String get onboarding_how_body =>
      'Создай кошелёк, записывай движение денег и смотри, как итоги обновляются мгновенно.';

  @override
  String get onboarding_how_step_wallet => 'Добавь кошелёк';

  @override
  String get onboarding_how_step_tap => 'Нажми и запиши';

  @override
  String get onboarding_how_step_totals => 'Смотри итоги';

  @override
  String get onboarding_wallet_hero_prefix => 'Создай свой первый';

  @override
  String get onboarding_wallet_hero_accent => 'Кошелёк';

  @override
  String get onboarding_final_title => 'Всё готово!';

  @override
  String get onboarding_final_body =>
      'Первый кошелёк создан. Остальное Wumbi оставит простым.';

  @override
  String get onboarding_final_button => 'Поехали';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'Мои деньги';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В $count кошельках',
      many: 'В $count кошельках',
      few: 'В $count кошельках',
      one: 'В $count кошельке',
      zero: 'Пока нет кошельков',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes не учтены';
  }

  @override
  String get dashboard_wallets => 'Кошельки';

  @override
  String get dashboard_new_wallet => 'Новый кошелёк';

  @override
  String get dashboard_empty_title => 'Создай первый кошелёк';

  @override
  String get dashboard_empty_subtitle =>
      'Wumbi нужен кошелёк, чтобы хранить твои деньги.';

  @override
  String get dashboard_tags => 'Теги';

  @override
  String get dashboard_subscriptions => 'Подписки';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'Название кошелька';

  @override
  String get wallet_currency => 'Валюта';

  @override
  String get wallet_primary => 'Основной кошелёк';

  @override
  String get wallet_has_transactions => 'Есть транзакции';

  @override
  String get wallet_tab_transactions => 'Транзакции';

  @override
  String get wallet_tab_budgets => 'Бюджеты';

  @override
  String get wallet_tab_subscriptions => 'Подписки';

  @override
  String get wallet_budgets_empty => 'Для этого кошелька пока нет лимитов';

  @override
  String get wallet_pick_another_primary => 'Выбери другой основной кошелёк';

  @override
  String wallet_delete_title(String name) {
    return 'Удалить $name?';
  }

  @override
  String get wallet_delete_message =>
      'Его транзакции будут удалены. Переводы с другими кошельками останутся видны.';

  @override
  String get wallet_deleted => 'Кошелёк удалён';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Кошелёк удалён · $count повторов на паузе',
      many: 'Кошелёк удалён · $count повторов на паузе',
      few: 'Кошелёк удалён · $count повтора на паузе',
      one: 'Кошелёк удалён · $count повтор на паузе',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'Пока нет транзакций';

  @override
  String get wallet_empty_subtitle => 'Нажми +, чтобы добавить первую';

  @override
  String get wallet_switch_title => 'Сменить кошелёк';

  @override
  String wallet_transfer_to(String name) {
    return 'Перевод в $name';
  }

  @override
  String wallet_transfer_from(String name) {
    return 'Перевод из $name';
  }

  @override
  String get wallet_deleted_suffix => '(удалён)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count повторов',
      many: '$count повторов',
      few: '$count повтора',
      one: '$count повтор',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'Этого кошелька больше нет';

  @override
  String get wallet_filter => 'Фильтр';

  @override
  String get wallet_sort => 'Сортировка';

  @override
  String get wallet_filter_title => 'Фильтр транзакций';

  @override
  String get wallet_filter_type => 'Тип';

  @override
  String get wallet_filter_date => 'Дата';

  @override
  String get wallet_filter_tags => 'Теги';

  @override
  String get wallet_filter_from => 'С';

  @override
  String get wallet_filter_to => 'По';

  @override
  String get wallet_filter_any_date => 'Любая дата';

  @override
  String get wallet_filter_this_month => 'Этот месяц';

  @override
  String get wallet_filter_last_month => 'Прошлый месяц';

  @override
  String get wallet_filter_last_30_days => 'Последние 30 дней';

  @override
  String get wallet_filter_this_year => 'Этот год';

  @override
  String get wallet_filter_custom_range => 'Свой период';

  @override
  String get wallet_filter_upcoming_only => 'Только предстоящие';

  @override
  String get wallet_filter_clear => 'Сбросить фильтры';

  @override
  String get wallet_filter_no_tags => 'В этом кошельке пока нет тегов';

  @override
  String get wallet_filter_no_results_title => 'Ничего не найдено';

  @override
  String get wallet_filter_no_results_subtitle => 'Попробуй убрать фильтр.';

  @override
  String wallet_filter_active(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фильтров',
      many: '$count фильтров',
      few: '$count фильтра',
      one: '$count фильтр',
    );
    return '$_temp0';
  }

  @override
  String get wallet_sort_title => 'Сортировать по';

  @override
  String get sort_date_newest => 'Сначала новые';

  @override
  String get sort_date_oldest => 'Сначала старые';

  @override
  String get sort_amount_high => 'Сначала крупные';

  @override
  String get sort_amount_low => 'Сначала мелкие';

  @override
  String get wallet_upcoming_section => 'Предстоящие';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предстоящих транзакций пока не учтены',
      many: '$count предстоящих транзакций пока не учтены',
      few: '$count предстоящие транзакции пока не учтены',
      one: '$count предстоящая транзакция пока не учтена',
    );
    return '$_temp0';
  }

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'Изменить';

  @override
  String get transaction_description_placeholder => 'описание';

  @override
  String get transaction_tags_placeholder => '#tags';

  @override
  String get transaction_repeat => 'Повтор';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · часть повтора';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount будет добавлено в $wallet';
  }

  @override
  String transaction_hint_stale(String date) {
    return 'курс от $date';
  }

  @override
  String get transaction_rate_unavailable =>
      'Курс недоступен — подключись, чтобы обновить';

  @override
  String transaction_saved(String amount, String wallet) {
    return '$amount сохранено в $wallet';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return '$amount перемещено в $wallet';
  }

  @override
  String get transaction_deleted => 'Транзакция удалена';

  @override
  String get transaction_upcoming_badge => 'Запланировано';

  @override
  String transaction_upcoming_hint(String date) {
    return 'Учтётся $date';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return '$amount запланировано на $date';
  }

  @override
  String get transaction_delete_title => 'Удалить эту транзакцию?';

  @override
  String get transaction_delete_this_one => 'Удалить только эту';

  @override
  String get transaction_delete_and_stop => 'Удалить и остановить повтор';

  @override
  String get transaction_need_second_wallet_title =>
      'Создай второй кошелёк для перевода';

  @override
  String get transaction_need_second_wallet_message =>
      'Переводы перемещают деньги между двумя твоими кошельками.';

  @override
  String get transaction_different_currency => 'Другая валюта';

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
    return 'Перевод $amount из $wallet';
  }

  @override
  String get transfer_amount_received => 'Сумма зачисления';

  @override
  String get transfer_confirm => 'Подтвердить перевод';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'Никогда';

  @override
  String get repeat_every_day => 'Каждый день';

  @override
  String get repeat_every_week => 'Каждую неделю';

  @override
  String get repeat_every_month => 'Каждый месяц';

  @override
  String get repeat_every_year => 'Каждый год';

  @override
  String get repeat_daily => 'Ежедневно';

  @override
  String get repeat_weekly => 'Еженедельно';

  @override
  String get repeat_monthly => 'Ежемесячно';

  @override
  String get repeat_yearly => 'Ежегодно';

  @override
  String get repeat_rules_title => 'Подписки';

  @override
  String get repeat_rules_hint =>
      'Нажми на подписку, чтобы изменить её. Существующие транзакции не меняются.';

  @override
  String repeat_next(String date) {
    return 'Следующая: $date';
  }

  @override
  String get repeat_paused => 'На паузе';

  @override
  String get repeat_delete_title => 'Остановить этот повтор?';

  @override
  String get repeat_delete_message =>
      'Существующие транзакции останутся. Новые создаваться не будут.';

  @override
  String get repeat_stop => 'Остановить';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'Выбери дату';

  @override
  String get date_pick_from => 'С';

  @override
  String get date_pick_to => 'По';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'Поиск';

  @override
  String get search_placeholder => 'Описание, сумма, кошелёк или тег';

  @override
  String get search_hint =>
      'Ищи по всем кошелькам: описание, сумма, название кошелька или тег.';

  @override
  String get search_no_results_title => 'Ничего не найдено';

  @override
  String get search_no_results_subtitle =>
      'Попробуй другое слово, сумму или тег.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count результатов',
      many: '$count результатов',
      few: '$count результата',
      one: '$count результат',
    );
    return '$_temp0';
  }

  @override
  String get l10nTags =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TAGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get tags_title => 'Теги';

  @override
  String get tags_view_list => 'Список';

  @override
  String get tags_view_graph => 'Карта';

  @override
  String get tags_search_placeholder => 'Поиск тегов';

  @override
  String get tags_empty_title => 'Пока нет тегов';

  @override
  String get tags_empty_subtitle =>
      'Добавь #tags к транзакции, и они появятся здесь.';

  @override
  String get tags_search_no_results => 'Нет тегов по запросу';

  @override
  String tags_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тегов',
      many: '$count тегов',
      few: '$count тега',
      one: '$count тег',
    );
    return '$_temp0';
  }

  @override
  String tags_usage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count транзакций',
      many: '$count транзакций',
      few: '$count транзакции',
      one: '$count транзакция',
      zero: 'Пока не используется',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'Потрачено';

  @override
  String get tags_earned => 'Заработано';

  @override
  String get tags_net => 'Итого';

  @override
  String tags_not_included(String codes) {
    return '$codes не учтены';
  }

  @override
  String get tags_graph_hint =>
      'Чем больше круг, тем больше денег. Линии соединяют теги, которые встречаются вместе.';

  @override
  String get tags_graph_empty =>
      'Добавь теги к нескольким транзакциям, чтобы увидеть карту.';

  @override
  String get tag_wallets => 'Кошельки';

  @override
  String get tag_transactions => 'Транзакции';

  @override
  String get tag_no_transactions => 'Нет транзакций с этим тегом';

  @override
  String get tag_rename => 'Переименовать тег';

  @override
  String get tag_name_placeholder => 'Название тега';

  @override
  String get tag_delete => 'Удалить тег';

  @override
  String tag_delete_title(String name) {
    return 'Удалить #$name?';
  }

  @override
  String get tag_delete_message =>
      'Он будет убран из всех транзакций. Сами транзакции останутся.';

  @override
  String get tag_deleted => 'Тег удалён';

  @override
  String get tag_renamed => 'Тег переименован';

  @override
  String tag_merged(String name) {
    return 'Объединён с #$name';
  }

  @override
  String get tag_not_found => 'Этого тега больше нет';

  @override
  String get tag_wallet_deleted => '(удалён)';

  @override
  String get tags_new => 'Новый тег';

  @override
  String get tags_create => 'Создать тег';

  @override
  String tags_created(String name) {
    return 'Тег #$name создан';
  }

  @override
  String tags_exists(String name) {
    return '#$name уже существует';
  }

  @override
  String get tags_parent => 'Родительский тег';

  @override
  String get tags_parent_none => 'Нет';

  @override
  String get tags_name_hint => 'напр. кофе';

  @override
  String get tags_create_tip =>
      'Совет: напишите еда/кофе, чтобы сразу вложить тег.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вложенных',
      many: '$count вложенных',
      few: '$count вложенных',
      one: '$count вложенный',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'Как пользоваться тегами?';

  @override
  String get tags_graph_mode_all => 'Все';

  @override
  String get tags_graph_mode_spending => 'Расходы';

  @override
  String get tags_graph_mode_income => 'Доходы';

  @override
  String get tags_graph_legend_size => 'Больше = больше денег';

  @override
  String get tags_graph_legend_nested => 'Вложенные';

  @override
  String get tags_graph_legend_together => 'Вместе';

  @override
  String get tags_graph_tap_hint => 'Нажмите на круг, чтобы увидеть цифры';

  @override
  String get tags_graph_open => 'Открыть';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Связан с $count тегами',
      many: 'Связан с $count тегами',
      few: 'Связан с $count тегами',
      one: 'Связан с $count тегом',
      zero: 'Пока нет связей',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'Переместить';

  @override
  String tag_move_title(String name) {
    return 'Переместить #$name';
  }

  @override
  String get tag_moved => 'Тег перемещён';

  @override
  String get tag_add_nested => 'Добавить вложенный тег';

  @override
  String get tag_nested_tags => 'Вложенные теги';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Включает $count вложенных тегов',
      many: 'Включает $count вложенных тегов',
      few: 'Включает $count вложенных тега',
      one: 'Включает $count вложенный тег',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Тег и $count вложенных тегов будут удалены из всех транзакций. Сами транзакции останутся.',
      many:
          'Тег и $count вложенных тегов будут удалены из всех транзакций. Сами транзакции останутся.',
      few:
          'Тег и $count вложенных тега будут удалены из всех транзакций. Сами транзакции останутся.',
      one:
          'Тег и $count вложенный тег будут удалены из всех транзакций. Сами транзакции останутся.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'Вложенные теги тоже переименуются. Используйте /, чтобы переместить его под другой тег.';

  @override
  String get tag_top_level => 'Верхний уровень';

  @override
  String get tag_nested_empty => 'Пока нет вложенных тегов';

  @override
  String get settings_help => 'Нужна помощь?';

  @override
  String get help_title => 'Нужна помощь?';

  @override
  String get help_subtitle =>
      'Короткие гайды, чтобы получить максимум от Wumbi.';

  @override
  String get help_tags_title => 'Как пользоваться тегами?';

  @override
  String get help_tags_subtitle => 'Метки, вложенные теги и карта';

  @override
  String get help_tags_intro =>
      'Теги — это короткие метки вроде #кофе, которые вы добавляете к транзакциям. У транзакции может быть несколько тегов, поэтому на свои деньги можно смотреть под любым углом, а не только по кошелькам.';

  @override
  String get help_tags_add_title => 'Как добавить тег';

  @override
  String get help_tags_add_body =>
      'При вводе транзакции напишите название в поле тегов и выберите подсказку или создайте новый. В тегах нет пробелов — пишите coffee-shop или coffee_shop. Заглавные и строчные буквы дают один и тот же тег.';

  @override
  String get help_tags_nested_title => 'Вложенные теги';

  @override
  String get help_tags_nested_body =>
      'Используйте косую черту /, чтобы положить тег внутрь другого, как в папки: еда/кофе и еда/продукты лежат внутри еда. Родительский тег создаётся автоматически.';

  @override
  String get help_tags_parent_title => 'Родитель включает вложенные теги';

  @override
  String get help_tags_parent_body =>
      'Открыв #еда, вы увидите все транзакции с #еда, #еда/кофе или #еда/продукты. Итоги, фильтры и бюджеты родителя учитывают и вложенные теги. Транзакция с обоими тегами считается один раз.';

  @override
  String get help_tags_multi_title => 'Несколько тегов у одной транзакции';

  @override
  String get help_tags_multi_body =>
      'Ужин в отпуске может быть одновременно #путешествия и #еда/ресторан. Тогда он учитывается в обоих, а два тега связываются на карте.';

  @override
  String get help_tags_manage_title => 'Создать, переименовать, переместить';

  @override
  String get help_tags_manage_body =>
      'На странице «Теги» нажмите +, чтобы создать тег, и выберите родителя, чтобы вложить его. Откройте тег, чтобы переименовать его, переместить под другой тег, добавить вложенный тег или удалить. Переименование родителя переименует и вложенные теги; если новое имя уже занято, теги объединятся.';

  @override
  String get help_tags_map_title => 'Как читать карту';

  @override
  String get help_tags_map_body =>
      'Каждый круг — это тег: чем он больше, тем больше денег через него прошло. Кольцо показывает долю расходов и доходов. Сплошные линии соединяют родителя с вложенными тегами, бледные — теги из одной транзакции. Нажмите на круг, чтобы увидеть цифры.';

  @override
  String get help_tags_tips_title => 'Советы';

  @override
  String get help_tags_tip1 =>
      'Начните с общих тегов — еда, дом, транспорт — и вкладывайте, только когда нужно больше деталей.';

  @override
  String get help_tags_tip2 =>
      'Используйте теги для того, что проходит через все кошельки: #отпуск, #подарки, #машина.';

  @override
  String get help_tags_tip3 =>
      'Делайте названия короткими; двух-трёх уровней достаточно.';

  @override
  String get help_tags_example => 'Пример';

  @override
  String get help_tags_example_total => 'Итого по #еда';

  @override
  String get help_tags_ex_parent => 'еда';

  @override
  String get help_tags_ex_child1 => 'кофе';

  @override
  String get help_tags_ex_child2 => 'продукты';

  @override
  String get help_tags_ex_travel => 'путешествия';

  @override
  String get help_tags_ex_restaurant => 'ресторан';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'Подписки';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подписок',
      many: '$count подписок',
      few: '$count подписки',
      one: '$count подписка',
      zero: 'Нет подписок',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'Пока нет подписок';

  @override
  String get subscriptions_empty_subtitle =>
      'Включи «Повтор» у транзакции — она появится здесь.';

  @override
  String get subscriptions_all_wallets => 'Все кошельки';

  @override
  String get subscriptions_active => 'Активные';

  @override
  String get subscriptions_paused => 'На паузе';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / мес.';
  }

  @override
  String get subscriptions_edit_title => 'Изменить подписку';

  @override
  String get subscriptions_amount => 'Сумма';

  @override
  String get subscriptions_wallet => 'Кошелёк';

  @override
  String get subscriptions_from_wallet => 'Из кошелька';

  @override
  String get subscriptions_to_wallet => 'В кошелёк';

  @override
  String get subscriptions_frequency => 'Частота';

  @override
  String get subscriptions_description => 'Описание';

  @override
  String get subscriptions_tags => 'Теги';

  @override
  String get subscriptions_pause => 'Пауза';

  @override
  String get subscriptions_resume => 'Возобновить';

  @override
  String get subscriptions_stop => 'Остановить подписку';

  @override
  String get subscriptions_saved => 'Подписка обновлена';

  @override
  String get subscriptions_stopped => 'Подписка остановлена';

  @override
  String get subscriptions_type_hint => 'Тип подписки изменить нельзя.';

  @override
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'Прогресс';

  @override
  String get progress_month => 'Месяц';

  @override
  String get progress_year => 'Год';

  @override
  String get progress_income => 'Доход';

  @override
  String get progress_expense => 'Расход';

  @override
  String get progress_net => 'Итого';

  @override
  String get progress_vs_last_month => 'к прошлому месяцу';

  @override
  String get progress_vs_last_year => 'к прошлому году';

  @override
  String get progress_all_wallets => 'Все кошельки';

  @override
  String get progress_scope_title => 'Показать данные по';

  @override
  String get progress_chart_title => 'Доходы и расходы';

  @override
  String progress_not_included(String codes) {
    return '$codes не учтены';
  }

  @override
  String get progress_empty_title => 'Пока нечего анализировать';

  @override
  String get progress_trend_title => 'Динамика';

  @override
  String get progress_tags_title => 'Расходы по тегам';

  @override
  String get progress_untagged => 'Без тега';

  @override
  String get progress_other_tags => 'Прочее';

  @override
  String get progress_no_expenses => 'В этом периоде расходов нет';

  @override
  String get progress_empty_subtitle =>
      'Добавьте несколько операций — и здесь появится ваш прогресс.';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Валюта';

  @override
  String get currency_no_results => 'Валюта не найдена';

  @override
  String get currency_base_title => 'Основная валюта';

  @override
  String get currency_base_hint => 'Общий баланс пересчитывается в эту валюту.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_preferences => 'Предпочтения';

  @override
  String get settings_notifications => 'Уведомления';

  @override
  String get settings_currency => 'Валюта';

  @override
  String get settings_dark_mode => 'Тёмная тема';

  @override
  String get settings_show_mascot => 'Показывать маскота';

  @override
  String get settings_data_privacy => 'Данные и приватность';

  @override
  String get settings_export_transactions => 'Экспорт транзакций';

  @override
  String get settings_reset_all_data => 'Сбросить все данные';

  @override
  String get settings_reset_title => 'Сбросить все данные?';

  @override
  String get settings_reset_message =>
      'Все кошельки, транзакции и настройки на этом устройстве будут стёрты. Отменить это нельзя.';

  @override
  String get settings_reset_action => 'Сбросить';

  @override
  String get settings_reset_done => 'Все данные удалены';

  @override
  String settings_version(String version, String build) {
    return 'Версия: $version ($build)';
  }

  @override
  String get settings_language => 'Язык';

  @override
  String get settings_manage => 'Управление';

  @override
  String get settings_tags => 'Теги';

  @override
  String get settings_subscriptions => 'Подписки';

  @override
  String get settings_language_info => 'Выбери язык интерфейса приложения.';

  @override
  String get settings_theme => 'Тема';

  @override
  String get settings_theme_system => 'Системная';

  @override
  String get settings_theme_light => 'Светлая';

  @override
  String get settings_theme_dark => 'Тёмная';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'О Wumbi';

  @override
  String get about_project => 'О проекте';

  @override
  String get about_text =>
      'Wumbi держит твои деньги в твоём телефоне. Вводишь сумму, жмёшь Доход или Расход, готово. Аккаунт не нужен, и ничего никуда не уходит, пока ты сам не включишь.';

  @override
  String get about_support => 'Связаться с поддержкой';

  @override
  String get about_read_more => 'Подробнее на wumbi.app';

  @override
  String get settings_about_section => 'О приложении';

  @override
  String get settings_privacy_policy => 'Политика конфиденциальности';

  @override
  String get settings_terms => 'Условия использования';

  @override
  String get settings_press => 'Для прессы';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'Введи сумму';

  @override
  String validation_up_to_tags(int count) {
    return 'До $count тегов';
  }

  @override
  String get validation_rate_unavailable => 'Курс недоступен';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'Ошибка базы данных, попробуй ещё раз.';

  @override
  String get error_unknown => 'Что-то пошло не так. Попробуй ещё раз.';

  @override
  String get error_rate_unavailable =>
      'Курс обмена недоступен. Подключись к интернету и попробуй снова.';

  @override
  String get error_validation => 'Проверь введённые значения.';

  @override
  String get error_wallet_has_transactions =>
      'Валюту нельзя изменить, если в кошельке уже есть транзакции.';

  @override
  String get error_not_found => 'Этого элемента больше нет.';

  @override
  String debt_error_owes_you_only(String name, String amount) {
    return '$name должен вам только $amount';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return 'Вы должны $name только $amount';
  }

  @override
  String get person_error_has_debts =>
      'Сначала закройте или удалите долги этого человека.';

  @override
  String get debt_error_closed => 'Этот долг уже закрыт.';

  @override
  String get error_tag_name => 'Введи название тега (до 30 символов).';

  @override
  String get error_open_db_title => 'Не удалось открыть данные';

  @override
  String get error_open_db_message =>
      'Wumbi не смог разблокировать базу данных на этом устройстве.';

  @override
  String get error_reset_app => 'Сбросить приложение';

  @override
  String get dashboard_budgets => 'Бюджеты';

  @override
  String get budget_new => 'Новый бюджет';

  @override
  String get budget_empty_hint => 'Задайте лимит трат для кошелька или #тега';

  @override
  String get budgets_all => 'Все бюджеты';

  @override
  String get budgets_title => 'Бюджеты';

  @override
  String budget_left(String amount) {
    return 'Осталось $amount';
  }

  @override
  String budget_over(String amount) {
    return 'Перерасход $amount';
  }

  @override
  String budget_starts(String date) {
    return 'Начнётся $date';
  }

  @override
  String get budget_ended => 'Завершён';

  @override
  String budget_per_day(String amount) {
    return '$amount/день';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return 'Потрачено $spent из $limit';
  }

  @override
  String get budget_this_week => 'Эта неделя';

  @override
  String get budget_set_limit => 'Задать лимит трат';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name: осталось $amount';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name: перерасход $amount';
  }

  @override
  String get budget_all_spending => 'Все расходы';

  @override
  String get budget_name => 'Название';

  @override
  String get budget_name_placeholder => 'название';

  @override
  String get budget_what_counts => 'Что учитывается';

  @override
  String get budget_wallets => 'Кошельки';

  @override
  String get budget_all_wallets => 'Все кошельки';

  @override
  String get budget_tags => 'Теги';

  @override
  String get budget_any_tag => 'Любой тег';

  @override
  String get budget_scope_all => 'Учитывает все расходы.';

  @override
  String budget_scope_wallets(String wallets) {
    return 'Учитывает расходы из $wallets.';
  }

  @override
  String budget_scope_tags(String tags) {
    return 'Учитывает расходы с тегом $tags.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return 'Учитывает расходы из $wallets с тегом $tags.';
  }

  @override
  String get budget_scope_or => 'или';

  @override
  String get budget_period_section => 'Период';

  @override
  String get budget_repeats => 'Повтор';

  @override
  String get budget_period_weekly => 'Еженедельно';

  @override
  String get budget_period_monthly => 'Ежемесячно';

  @override
  String get budget_period_yearly => 'Ежегодно';

  @override
  String get budget_period_custom => 'Разово';

  @override
  String get budget_starts_on => 'Начало';

  @override
  String get budget_first_day => 'Первый день';

  @override
  String get budget_last_day => 'Последний день';

  @override
  String budget_day_of_month(int day) {
    return '$day-е число';
  }

  @override
  String get budget_start_day_title => 'День начала';

  @override
  String get budget_start_day_hint => 'В коротких месяцах — в последний день.';

  @override
  String get budget_start_weekday_title => 'Первый день недели';

  @override
  String get budget_carry_over => 'Перенос остатка';

  @override
  String get budget_rollover_none => 'Не переносить';

  @override
  String get budget_rollover_surplus => 'Переносить остаток';

  @override
  String get budget_rollover_both => 'Переносить остаток и перерасход';

  @override
  String get budget_count_planned => 'Учитывать запланированное';

  @override
  String get budget_count_planned_hint => 'Будущие операции и подписки';

  @override
  String get budget_count_planned_desc =>
      'Предстоящие платежи и подписки учитываются в лимите ещё до оплаты.';

  @override
  String budget_suggested_months(String amount) {
    return 'Совет: $amount · среднее за 3 месяца';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'Совет: $amount · среднее за 3 недели';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'Совет: $amount · среднее за 3 года';
  }

  @override
  String get budget_deleted => 'Бюджет удалён';

  @override
  String budget_delete_title(String name) {
    return 'Удалить $name?';
  }

  @override
  String get budget_delete_message => 'Операции останутся без изменений.';

  @override
  String get budget_error_name => 'Название до 40 символов';

  @override
  String get budget_error_dates => 'Последний день должен быть позже первого';

  @override
  String get budget_left_caption => 'осталось';

  @override
  String get budget_over_caption => 'перерасход';

  @override
  String get budget_under_caption => 'в пределах';

  @override
  String budget_spent(String amount) {
    return 'Потрачено $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'Запланировано $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'Лимит $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount перенесено';
  }

  @override
  String get budget_on_track => 'По плану';

  @override
  String budget_ahead_of_pace(String amount) {
    return '$amount в запасе';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return '$amount быстрее плана';
  }

  @override
  String budget_forecast(String amount) {
    return 'прогноз $amount';
  }

  @override
  String get budget_no_spending => 'В этом периоде трат пока нет';

  @override
  String get budgets_active => 'Активные';

  @override
  String get budgets_upcoming => 'Предстоящие';

  @override
  String get budgets_empty_title => 'Бюджетов пока нет';

  @override
  String get budgets_empty_subtitle => 'Задайте лимит и следите за остатком';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ещё $count бюджета',
      many: 'ещё $count бюджетов',
      few: 'ещё $count бюджета',
      one: 'ещё $count бюджет',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$amount/день на $_temp0';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подписки',
      many: '$count подписок',
      few: '$count подписки',
      one: '$count подписка',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Завершённые ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'удалено $count бюджета',
      many: 'удалено $count бюджетов',
      few: 'удалено $count бюджета',
      one: 'удалён $count бюджет',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'Долги';

  @override
  String get debts_owed_to_me => 'Мне должны';

  @override
  String get debts_i_owe => 'Я должен';

  @override
  String get debts_empty_owed_title => 'Вам никто не должен';

  @override
  String get debts_empty_owe_title => 'Вы никому не должны';

  @override
  String get debts_empty_subtitle =>
      'Выберите человека на экране операции, когда даёте в долг';

  @override
  String get debt_new => 'Новый долг';

  @override
  String get debts_all => 'Все долги';

  @override
  String get debts_empty_hint =>
      'Отслеживайте, кому вы одолжили и у кого заняли';

  @override
  String get dashboard_reorder_hint => 'Удерживайте, чтобы переставить';

  @override
  String dashboard_budgets_over(int count) {
    return 'превышено: $count';
  }

  @override
  String dashboard_budgets_at_risk(int count) {
    return 'под угрозой: $count';
  }

  @override
  String get dashboard_budgets_on_track => 'Всё в норме';

  @override
  String dashboard_debts_to_receive(String amount) {
    return 'вам должны $amount';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return 'вы должны $amount';
  }

  @override
  String get dashboard_new => 'Новый';

  @override
  String get debt_they_owe_me => 'Мне должны';

  @override
  String get debt_i_owe_them => 'Я должен';

  @override
  String get debt_person => 'Человек';

  @override
  String get debt_person_chip => 'Человек';

  @override
  String get debt_person_title => 'Человек';

  @override
  String get debt_person_search => 'Имя';

  @override
  String get debt_person_empty => 'Пока никого — введите имя';

  @override
  String get debt_person_none => 'Без человека';

  @override
  String get debt_choose => 'Выбрать';

  @override
  String get debt_amount => 'Сумма';

  @override
  String get debt_note_hint => 'Заметка (необязательно)';

  @override
  String get debt_note_placeholder => 'заметка';

  @override
  String get debt_due_date => 'Срок';

  @override
  String get debt_due_title => 'Срок';

  @override
  String get debt_add_due => 'Срок';

  @override
  String get debt_due_change => 'Изменить дату';

  @override
  String get debt_due_remove => 'Убрать срок';

  @override
  String get debt_none => 'Нет';

  @override
  String get debt_money_moved => 'Движение денег';

  @override
  String get debt_not_in_wallet => 'Не через кошелёк';

  @override
  String get debt_error_person => 'Выберите человека';

  @override
  String get debt_gave => 'Дал';

  @override
  String get debt_got => 'Получил';

  @override
  String get debt_badge_loan => 'Долг';

  @override
  String get debt_badge_return => 'Возврат';

  @override
  String get debt_overdue => 'просрочен';

  @override
  String get debt_settled_label => 'Закрыт';

  @override
  String get debt_forgiven_label => 'Прощён';

  @override
  String get debt_returned_in_full => 'Вернули полностью';

  @override
  String get debt_paid_in_full => 'Вернул полностью';

  @override
  String get debt_part => 'Часть';

  @override
  String get debt_forgive => 'Простить';

  @override
  String get debt_remind => 'Напомнить';

  @override
  String get debt_history => 'История';

  @override
  String get debt_edit_note => 'Изменить заметку';

  @override
  String get debt_rename_person => 'Переименовать';

  @override
  String get debt_delete => 'Удалить долг';

  @override
  String get debt_delete_title => 'Удалить этот долг?';

  @override
  String get debt_deleted => 'Долг удалён';

  @override
  String get debt_payment_deleted => 'Платёж удалён';

  @override
  String get debt_return_deleted => 'Возврат удалён';

  @override
  String debt_due(String date) {
    return 'до $date';
  }

  @override
  String debt_left(String amount) {
    return 'осталось $amount';
  }

  @override
  String debt_left_of(String amount) {
    return 'осталось из $amount';
  }

  @override
  String debt_of(String amount) {
    return 'из $amount';
  }

  @override
  String debt_to_wallet(String wallet) {
    return 'на $wallet';
  }

  @override
  String debt_from_wallet(String wallet) {
    return 'с $wallet';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name должен вам $amount';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return 'Вы должны $name $amount';
  }

  @override
  String debt_overall(String text) {
    return 'Всего: $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'Всего: $name должен вам $owed · вы должны $owe';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name должен вам $amount · «Получил» — это возврат';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return 'Вы должны $name $amount · «Дал» — это возврат долга';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name должен вам $owed · вы должны $owe';
  }

  @override
  String debt_hint_none(String name) {
    return 'Нет открытых долгов с $name · «Дал» — в долг, «Получил» — заём';
  }

  @override
  String debt_person_add(String name) {
    return 'Добавить «$name»';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'должен вам $amount';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'вы должны $amount';
  }

  @override
  String debt_title_lent_to(String name) {
    return 'Дал в долг: $name';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return 'Взял в долг: $name';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name вернул';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return 'Вернул: $name';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return 'Дали в долг $amount: $name';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return 'Взяли в долг $amount: $name';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name вернул $amount · осталось $left';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name вернул $amount · всё закрыто';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return 'Вернули $amount: $name · осталось $left';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return 'Вернули $amount: $name · всё закрыто';
  }

  @override
  String debt_forgive_title(String name) {
    return 'Простить долг $name?';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'Оставшиеся $amount будут списаны. Деньги не двигаются.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'Долг прощён · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'Привет, $name! Напоминаю про $amount за $note ($date). Спасибо!';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'Привет, $name! Напоминаю про $amount ($date). Спасибо!';
  }

  @override
  String debt_history_lent(String amount) {
    return 'Дал в долг $amount';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return 'Дал в долг $amount с $wallet';
  }

  @override
  String debt_history_borrowed(String amount) {
    return 'Взял в долг $amount';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return 'Взял в долг $amount на $wallet';
  }

  @override
  String debt_history_returned(String amount) {
    return 'Вернули $amount';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return 'Вернули $amount → $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return 'Вернул $amount';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return 'Вернул $amount с $wallet';
  }

  @override
  String debt_history_forgiven(String amount) {
    return 'Прощено $amount';
  }

  @override
  String debts_overdue_count(int count) {
    return 'просрочено: $count';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count долга',
      many: '$count долгов',
      few: '$count долга',
      one: '$count долг',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человека',
      many: '$count человек',
      few: '$count человека',
      one: '$count человек',
      zero: 'Никого',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Закрытые ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Долг удалён вместе с возвратами: $count',
      one: 'Долг удалён вместе с $count возвратом',
      zero: 'Долг удалён',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Также будут удалены операции: $count.',
      many: 'Также будут удалены $count операций.',
      few: 'Также будут удалены $count операции.',
      one: 'Также будет удалена $count операция.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'Новая подписка';

  @override
  String subscriptions_active_count(int count) {
    return 'активных: $count';
  }

  @override
  String subscriptions_paused_count(int count) {
    return 'на паузе: $count';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'Задайте лимит трат, чтобы держать этот кошелёк под контролем.';

  @override
  String get wallet_include_in_total => 'Учитывать в общем балансе';

  @override
  String get wallet_include_in_total_on =>
      'Баланс этого кошелька входит в общую сумму на главном экране.';

  @override
  String get wallet_include_in_total_off =>
      'Не входит в общую сумму на главном экране — удобно для накоплений, общих кошельков или кошельков для учёта.';

  @override
  String dashboard_wallets_excluded(int count) {
    return 'не учтено: $count';
  }

  @override
  String get budget_rollover_none_desc =>
      'Каждый период начинается заново с тем же лимитом. Остаток и перерасход не переносятся.';

  @override
  String get budget_rollover_surplus_desc =>
      'Непотраченное добавляется к лимиту следующего периода.';

  @override
  String get budget_rollover_both_desc =>
      'Остаток увеличивает лимит следующего периода, перерасход — уменьшает.';

  @override
  String budget_used_percent(int percent) {
    return 'использовано $percent%';
  }

  @override
  String get budget_stat_spent => 'Потрачено';

  @override
  String get budget_stat_limit => 'Лимит';

  @override
  String get budget_stat_planned => 'Запланировано';

  @override
  String get budget_stat_per_day => 'В день';

  @override
  String get budget_stat_forecast => 'Прогноз';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'осталось $count дня',
      many: 'осталось $count дней',
      few: 'осталось $count дня',
      one: 'остался $count день',
    );
    return '$_temp0';
  }

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
