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
      'Wumbi — минималистичное приложение для бюджета, которое работает локально. Твои данные зашифрованы и не покидают устройство.';

  @override
  String get about_support => 'Связаться с поддержкой';

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
  String get error_tag_name => 'Введи название тега (до 30 символов).';

  @override
  String get error_open_db_title => 'Не удалось открыть данные';

  @override
  String get error_open_db_message =>
      'Wumbi не смог разблокировать базу данных на этом устройстве.';

  @override
  String get error_reset_app => 'Сбросить приложение';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
