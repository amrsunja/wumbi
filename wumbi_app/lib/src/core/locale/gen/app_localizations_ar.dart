// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appLanguage => 'العربية';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'متابعة';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_save => 'حفظ';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_undo => 'تراجع';

  @override
  String get common_ok => 'حسنًا';

  @override
  String get common_retry => 'إعادة المحاولة';

  @override
  String get common_today => 'اليوم';

  @override
  String get common_yesterday => 'أمس';

  @override
  String get common_income => 'دخل';

  @override
  String get common_expense => 'مصروف';

  @override
  String get common_transfer => 'تحويل';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_all => 'الكل';

  @override
  String get common_clear => 'مسح';

  @override
  String get common_apply => 'تطبيق';

  @override
  String get common_done => 'تم';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_search => 'بحث';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'تعرّف على Wumbi';

  @override
  String get onboarding_welcome_subtitle =>
      'تتبّع أموالك في ثوانٍ. بلا فئات، فقط وسوم.';

  @override
  String get onboarding_currency_title => 'عملتك الأساسية';

  @override
  String get onboarding_currency_subtitle =>
      'تظهر المجاميع بهذه العملة. يمكنك تغييرها لاحقًا من الإعدادات.';

  @override
  String get onboarding_wallet_title => 'محفظتك الأولى';

  @override
  String get onboarding_wallet_subtitle =>
      'لكل محفظة عملة واحدة. يمكنك إضافة محافظ أخرى لاحقًا.';

  @override
  String get onboarding_create_wallet => 'إنشاء محفظة';

  @override
  String get common_skip => 'تخطّي';

  @override
  String get onboarding_welcome_start => 'لنبدأ';

  @override
  String get onboarding_benefit_wallets_title => 'محافظ بأي عملة';

  @override
  String get onboarding_benefit_wallets_body =>
      'دولار، يورو، بيتكوين — لكل محفظة عملتها الخاصة. ويظهر إجماليك بالعملة التي تختارها.';

  @override
  String get onboarding_benefit_tags_title => 'وسوم، لا فئات';

  @override
  String get onboarding_benefit_tags_body =>
      'انسَ الفئات الجامدة. أضف أي وسوم تحب — #coffee، #trip، #work — واعثر على أي شيء لاحقًا.';

  @override
  String get onboarding_benefit_one_tap_title => 'سجّلها بنقرة واحدة';

  @override
  String get onboarding_benefit_one_tap_body =>
      'اكتب المبلغ، ثم اضغط دخل أو مصروف. انتهى. وتبقى الشاشة مفتوحة للمعاملة التالية.';

  @override
  String get onboarding_how_title => 'كيف يعمل';

  @override
  String get onboarding_how_body =>
      'أنشئ محفظة، وسجّل أموالك أولًا بأول، وشاهد مجاميعك تتحدّث فورًا.';

  @override
  String get onboarding_how_step_wallet => 'أضف محفظة';

  @override
  String get onboarding_how_step_tap => 'انقر للتسجيل';

  @override
  String get onboarding_how_step_totals => 'شاهد المجاميع';

  @override
  String get onboarding_wallet_hero_prefix => 'أنشئ أول';

  @override
  String get onboarding_wallet_hero_accent => 'محفظة';

  @override
  String get onboarding_final_title => 'كل شيء جاهز!';

  @override
  String get onboarding_final_body =>
      'محفظتك الأولى جاهزة. وسيتكفّل Wumbi بتبسيط الباقي.';

  @override
  String get onboarding_final_button => 'هيا بنا';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'أموالي';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'في $count محفظة',
      many: 'في $count محفظة',
      few: 'في $count محافظ',
      two: 'في محفظتين',
      one: 'في محفظة واحدة',
      zero: 'لا توجد محافظ بعد',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes غير مشمولة';
  }

  @override
  String get dashboard_wallets => 'المحافظ';

  @override
  String get dashboard_new_wallet => 'محفظة جديدة';

  @override
  String get dashboard_empty_title => 'أنشئ محفظتك الأولى';

  @override
  String get dashboard_empty_subtitle =>
      'يحتاج Wumbi إلى محفظة يحفظ فيها أموالك.';

  @override
  String get dashboard_tags => 'الوسوم';

  @override
  String get dashboard_subscriptions => 'الاشتراكات';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'اسم المحفظة';

  @override
  String get wallet_currency => 'العملة';

  @override
  String get wallet_primary => 'المحفظة الرئيسية';

  @override
  String get wallet_has_transactions => 'تحتوي على معاملات';

  @override
  String get wallet_pick_another_primary => 'اختر محفظة أخرى كرئيسية';

  @override
  String wallet_delete_title(String name) {
    return 'حذف $name؟';
  }

  @override
  String get wallet_delete_message =>
      'ستُحذف معاملاتها. وتبقى التحويلات مع المحافظ الأخرى ظاهرة.';

  @override
  String get wallet_deleted => 'تم حذف المحفظة';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حذف المحفظة · أُوقف $count تكرار',
      many: 'تم حذف المحفظة · أُوقف $count تكرارًا',
      few: 'تم حذف المحفظة · أُوقفت $count تكرارات',
      two: 'تم حذف المحفظة · أُوقف تكراران',
      one: 'تم حذف المحفظة · أُوقف تكرار واحد',
      zero: 'تم حذف المحفظة',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'لا توجد معاملات بعد';

  @override
  String get wallet_empty_subtitle => 'اضغط + لإضافة أول معاملة';

  @override
  String get wallet_switch_title => 'تبديل المحفظة';

  @override
  String wallet_transfer_to(String name) {
    return 'تحويل إلى $name';
  }

  @override
  String wallet_transfer_from(String name) {
    return 'تحويل من $name';
  }

  @override
  String get wallet_deleted_suffix => '(محذوفة)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تكرار',
      many: '$count تكرارًا',
      few: '$count تكرارات',
      two: 'تكراران',
      one: 'تكرار واحد',
      zero: 'لا تكرارات',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'لم تعد هذه المحفظة موجودة';

  @override
  String get wallet_filter => 'فلترة';

  @override
  String get wallet_sort => 'ترتيب';

  @override
  String get wallet_filter_title => 'فلترة المعاملات';

  @override
  String get wallet_filter_type => 'النوع';

  @override
  String get wallet_filter_date => 'التاريخ';

  @override
  String get wallet_filter_tags => 'الوسوم';

  @override
  String get wallet_filter_from => 'من';

  @override
  String get wallet_filter_to => 'إلى';

  @override
  String get wallet_filter_any_date => 'أي تاريخ';

  @override
  String get wallet_filter_this_month => 'هذا الشهر';

  @override
  String get wallet_filter_last_month => 'الشهر الماضي';

  @override
  String get wallet_filter_last_30_days => 'آخر 30 يومًا';

  @override
  String get wallet_filter_this_year => 'هذه السنة';

  @override
  String get wallet_filter_custom_range => 'مدة مخصصة';

  @override
  String get wallet_filter_upcoming_only => 'القادمة فقط';

  @override
  String get wallet_filter_clear => 'مسح الفلاتر';

  @override
  String get wallet_filter_no_tags => 'لا وسوم في هذه المحفظة بعد';

  @override
  String get wallet_filter_no_results_title => 'لا نتائج مطابقة';

  @override
  String get wallet_filter_no_results_subtitle => 'جرّب إزالة أحد الفلاتر.';

  @override
  String wallet_filter_active(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فلتر',
      many: '$count فلترًا',
      few: '$count فلاتر',
      two: 'فلتران',
      one: 'فلتر واحد',
      zero: 'لا فلاتر',
    );
    return '$_temp0';
  }

  @override
  String get wallet_sort_title => 'ترتيب حسب';

  @override
  String get sort_date_newest => 'الأحدث أولًا';

  @override
  String get sort_date_oldest => 'الأقدم أولًا';

  @override
  String get sort_amount_high => 'الأكبر مبلغًا';

  @override
  String get sort_amount_low => 'الأصغر مبلغًا';

  @override
  String get wallet_upcoming_section => 'القادمة';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة قادمة غير محتسبة بعد',
      many: '$count معاملة قادمة غير محتسبة بعد',
      few: '$count معاملات قادمة غير محتسبة بعد',
      two: 'معاملتان قادمتان غير محتسبتين بعد',
      one: 'معاملة قادمة واحدة غير محتسبة بعد',
      zero: 'لا معاملات قادمة',
    );
    return '$_temp0';
  }

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'تعديل';

  @override
  String get transaction_description_placeholder => 'الوصف';

  @override
  String get transaction_tags_placeholder => '#وسوم';

  @override
  String get transaction_repeat => 'تكرار';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · ضمن تكرار';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount ستُضاف إلى $wallet';
  }

  @override
  String transaction_hint_stale(String date) {
    return 'سعر بتاريخ $date';
  }

  @override
  String get transaction_rate_unavailable =>
      'السعر غير متاح — اتصل بالإنترنت للتحديث';

  @override
  String transaction_saved(String amount, String wallet) {
    return 'تم حفظ $amount في $wallet';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return 'تم نقل $amount إلى $wallet';
  }

  @override
  String get transaction_deleted => 'تم حذف المعاملة';

  @override
  String get transaction_upcoming_badge => 'قادمة';

  @override
  String transaction_upcoming_hint(String date) {
    return 'تُحتسب في $date';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return 'تمت جدولة $amount في $date';
  }

  @override
  String get transaction_delete_title => 'حذف هذه المعاملة؟';

  @override
  String get transaction_delete_this_one => 'حذف هذه فقط';

  @override
  String get transaction_delete_and_stop => 'حذف وإيقاف التكرار';

  @override
  String get transaction_need_second_wallet_title => 'أنشئ محفظة ثانية للتحويل';

  @override
  String get transaction_need_second_wallet_message =>
      'التحويلات تنقل المال بين محفظتين من محافظك.';

  @override
  String get transaction_different_currency => 'عملة مختلفة';

  @override
  String transaction_counterpart_to(String wallet, String amount) {
    return '← $wallet +$amount';
  }

  @override
  String transaction_counterpart_from(String wallet, String amount) {
    return '→ $wallet -$amount';
  }

  @override
  String get l10nTransfer =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSFER ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String transfer_title(String amount, String wallet) {
    return 'تحويل $amount من $wallet';
  }

  @override
  String get transfer_amount_received => 'المبلغ المستلم';

  @override
  String get transfer_confirm => 'تأكيد التحويل';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'أبدًا';

  @override
  String get repeat_every_day => 'كل يوم';

  @override
  String get repeat_every_week => 'كل أسبوع';

  @override
  String get repeat_every_month => 'كل شهر';

  @override
  String get repeat_every_year => 'كل سنة';

  @override
  String get repeat_daily => 'يوميًا';

  @override
  String get repeat_weekly => 'أسبوعيًا';

  @override
  String get repeat_monthly => 'شهريًا';

  @override
  String get repeat_yearly => 'سنويًا';

  @override
  String get repeat_rules_title => 'الاشتراكات';

  @override
  String get repeat_rules_hint =>
      'اضغط على اشتراك لتعديله. المعاملات الحالية لا تتغيّر أبدًا.';

  @override
  String repeat_next(String date) {
    return 'التالي: $date';
  }

  @override
  String get repeat_paused => 'متوقّف';

  @override
  String get repeat_delete_title => 'إيقاف هذا التكرار؟';

  @override
  String get repeat_delete_message =>
      'تبقى المعاملات الحالية. ولن تُنشأ معاملات جديدة.';

  @override
  String get repeat_stop => 'إيقاف';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'اختر تاريخًا';

  @override
  String get date_pick_from => 'من';

  @override
  String get date_pick_to => 'إلى';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'بحث';

  @override
  String get search_placeholder => 'الوصف أو المبلغ أو المحفظة أو الوسم';

  @override
  String get search_hint =>
      'ابحث في كل المحافظ بالوصف أو المبلغ أو اسم المحفظة أو الوسم.';

  @override
  String get search_no_results_title => 'لا توجد نتائج';

  @override
  String get search_no_results_subtitle => 'جرّب كلمة أو مبلغًا أو وسمًا آخر.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get l10nTags =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TAGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get tags_title => 'الوسوم';

  @override
  String get tags_view_list => 'قائمة';

  @override
  String get tags_view_graph => 'خريطة';

  @override
  String get tags_search_placeholder => 'ابحث في الوسوم';

  @override
  String get tags_empty_title => 'لا وسوم بعد';

  @override
  String get tags_empty_subtitle => 'أضف #وسوم إلى معاملة وستظهر هنا.';

  @override
  String get tags_search_no_results => 'لا وسوم تطابق بحثك';

  @override
  String tags_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وسم',
      many: '$count وسمًا',
      few: '$count وسوم',
      two: 'وسمان',
      one: 'وسم واحد',
      zero: 'لا وسوم',
    );
    return '$_temp0';
  }

  @override
  String tags_usage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count معاملة',
      many: '$count معاملة',
      few: '$count معاملات',
      two: 'معاملتان',
      one: 'معاملة واحدة',
      zero: 'غير مستخدم بعد',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'المصروف';

  @override
  String get tags_earned => 'الدخل';

  @override
  String get tags_net => 'الصافي';

  @override
  String tags_not_included(String codes) {
    return '$codes غير مشمولة';
  }

  @override
  String get tags_graph_hint =>
      'الدوائر الأكبر حرّكت أموالًا أكثر. والخطوط تصل الوسوم المستخدمة معًا.';

  @override
  String get tags_graph_empty => 'أضف وسومًا إلى بعض المعاملات لرؤية الخريطة.';

  @override
  String get tag_wallets => 'المحافظ';

  @override
  String get tag_transactions => 'المعاملات';

  @override
  String get tag_no_transactions => 'لا معاملات بهذا الوسم';

  @override
  String get tag_rename => 'إعادة تسمية الوسم';

  @override
  String get tag_name_placeholder => 'اسم الوسم';

  @override
  String get tag_delete => 'حذف الوسم';

  @override
  String tag_delete_title(String name) {
    return 'حذف #$name؟';
  }

  @override
  String get tag_delete_message =>
      'سيُزال من كل معاملة. وتبقى المعاملات نفسها كما هي.';

  @override
  String get tag_deleted => 'تم حذف الوسم';

  @override
  String get tag_renamed => 'تمت إعادة تسمية الوسم';

  @override
  String tag_merged(String name) {
    return 'تم الدمج في #$name';
  }

  @override
  String get tag_not_found => 'لم يعد هذا الوسم موجودًا';

  @override
  String get tag_wallet_deleted => '(محذوفة)';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'الاشتراكات';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اشتراك',
      many: '$count اشتراكًا',
      few: '$count اشتراكات',
      two: 'اشتراكان',
      one: 'اشتراك واحد',
      zero: 'لا اشتراكات',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'لا اشتراكات بعد';

  @override
  String get subscriptions_empty_subtitle =>
      'فعّل التكرار على معاملة وستظهر هنا.';

  @override
  String get subscriptions_all_wallets => 'كل المحافظ';

  @override
  String get subscriptions_active => 'نشط';

  @override
  String get subscriptions_paused => 'متوقّف';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / شهريًا';
  }

  @override
  String get subscriptions_edit_title => 'تعديل الاشتراك';

  @override
  String get subscriptions_amount => 'المبلغ';

  @override
  String get subscriptions_wallet => 'المحفظة';

  @override
  String get subscriptions_from_wallet => 'من محفظة';

  @override
  String get subscriptions_to_wallet => 'إلى محفظة';

  @override
  String get subscriptions_frequency => 'التكرار';

  @override
  String get subscriptions_description => 'الوصف';

  @override
  String get subscriptions_tags => 'الوسوم';

  @override
  String get subscriptions_pause => 'إيقاف مؤقت';

  @override
  String get subscriptions_resume => 'استئناف';

  @override
  String get subscriptions_stop => 'إيقاف الاشتراك';

  @override
  String get subscriptions_saved => 'تم تحديث الاشتراك';

  @override
  String get subscriptions_stopped => 'تم إيقاف الاشتراك';

  @override
  String get subscriptions_type_hint => 'لا يمكن تغيير نوع الاشتراك.';

  @override
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'التقدم';

  @override
  String get progress_month => 'شهر';

  @override
  String get progress_year => 'سنة';

  @override
  String get progress_income => 'دخل';

  @override
  String get progress_expense => 'مصروف';

  @override
  String get progress_net => 'الصافي';

  @override
  String get progress_vs_last_month => 'مقارنة بالشهر الماضي';

  @override
  String get progress_vs_last_year => 'مقارنة بالسنة الماضية';

  @override
  String get progress_all_wallets => 'كل المحافظ';

  @override
  String get progress_scope_title => 'عرض البيانات لـ';

  @override
  String get progress_chart_title => 'الدخل مقابل المصروف';

  @override
  String progress_not_included(String codes) {
    return '$codes غير مشمولة';
  }

  @override
  String get progress_empty_title => 'لا يوجد ما يمكن تحليله بعد';

  @override
  String get progress_trend_title => 'الاتجاه';

  @override
  String get progress_tags_title => 'المصروف حسب الوسم';

  @override
  String get progress_untagged => 'بدون وسم';

  @override
  String get progress_other_tags => 'أخرى';

  @override
  String get progress_no_expenses => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get progress_empty_subtitle => 'أضف بعض المعاملات وسيظهر تقدمك هنا.';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'العملة';

  @override
  String get currency_no_results => 'لا توجد عملة مطابقة';

  @override
  String get currency_base_title => 'العملة الأساسية';

  @override
  String get currency_base_hint => 'يُحوَّل رصيدك الإجمالي إلى هذه العملة.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'الإعدادات';

  @override
  String get settings_preferences => 'التفضيلات';

  @override
  String get settings_notifications => 'الإشعارات';

  @override
  String get settings_currency => 'العملة';

  @override
  String get settings_dark_mode => 'الوضع الداكن';

  @override
  String get settings_show_mascot => 'إظهار التميمة';

  @override
  String get settings_data_privacy => 'البيانات والخصوصية';

  @override
  String get settings_export_transactions => 'تصدير المعاملات';

  @override
  String get settings_reset_all_data => 'إعادة تعيين كل البيانات';

  @override
  String get settings_reset_title => 'إعادة تعيين كل البيانات؟';

  @override
  String get settings_reset_message =>
      'ستُمحى كل محفظة ومعاملة وإعداد على هذا الجهاز. لا يمكن التراجع عن ذلك.';

  @override
  String get settings_reset_action => 'إعادة تعيين';

  @override
  String get settings_reset_done => 'تم حذف كل البيانات';

  @override
  String settings_version(String version, String build) {
    return 'الإصدار: $version ($build)';
  }

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_manage => 'إدارة';

  @override
  String get settings_tags => 'الوسوم';

  @override
  String get settings_subscriptions => 'الاشتراكات';

  @override
  String get settings_language_info => 'اختر لغتك المفضّلة لواجهة التطبيق.';

  @override
  String get settings_theme => 'المظهر';

  @override
  String get settings_theme_system => 'النظام';

  @override
  String get settings_theme_light => 'فاتح';

  @override
  String get settings_theme_dark => 'داكن';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'عن Wumbi';

  @override
  String get about_project => 'عن المشروع';

  @override
  String get about_text =>
      'يُبقي Wumbi أموالك في هاتفك. اكتب المبلغ، اضغط دخل أو مصروف، وانتهى. لا حاجة لحساب، ولا يُرفَع شيء ما لم تشغّله بنفسك.';

  @override
  String get about_support => 'تواصل مع الدعم';

  @override
  String get about_read_more => 'اقرأ المزيد على wumbi.app';

  @override
  String get settings_about_section => 'عن التطبيق';

  @override
  String get settings_privacy_policy => 'سياسة الخصوصية';

  @override
  String get settings_terms => 'شروط الاستخدام';

  @override
  String get settings_press => 'للصحافة';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'أدخل مبلغًا';

  @override
  String validation_up_to_tags(int count) {
    return 'حتى $count وسوم';
  }

  @override
  String get validation_rate_unavailable => 'السعر غير متاح';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'خطأ في قاعدة البيانات، حاول مجددًا.';

  @override
  String get error_unknown => 'حدث خطأ ما. حاول مجددًا من فضلك.';

  @override
  String get error_rate_unavailable =>
      'لا يتوفر سعر صرف. اتصل بالإنترنت وحاول مجددًا.';

  @override
  String get error_validation => 'تحقّق من القيم المُدخلة من فضلك.';

  @override
  String get error_wallet_has_transactions =>
      'لا يمكن تغيير العملة بعد أن تصبح للمحفظة معاملات.';

  @override
  String get error_not_found => 'لم يعد هذا العنصر موجودًا.';

  @override
  String get error_tag_name => 'أدخل اسم وسم (حتى 30 حرفًا).';

  @override
  String get error_open_db_title => 'تعذّر فتح بياناتك';

  @override
  String get error_open_db_message =>
      'تعذّر على Wumbi فتح قاعدة البيانات على هذا الجهاز.';

  @override
  String get error_reset_app => 'إعادة تعيين التطبيق';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
