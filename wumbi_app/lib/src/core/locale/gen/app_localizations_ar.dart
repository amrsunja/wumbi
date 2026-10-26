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
  String get wallet_tab_transactions => 'المعاملات';

  @override
  String get wallet_tab_budgets => 'الميزانيات';

  @override
  String get wallet_tab_subscriptions => 'الاشتراكات';

  @override
  String get wallet_budgets_empty => 'لا توجد حدود إنفاق لهذه المحفظة بعد';

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
  String get transaction_edit_title => 'تعديل المعاملة';

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
  String get tags_new => 'وسم جديد';

  @override
  String get tags_create => 'إنشاء الوسم';

  @override
  String tags_created(String name) {
    return 'تم إنشاء #$name';
  }

  @override
  String tags_exists(String name) {
    return '#$name موجود بالفعل';
  }

  @override
  String get tags_parent => 'الوسم الأب';

  @override
  String get tags_parent_none => 'بدون';

  @override
  String get tags_name_hint => 'مثال: قهوة';

  @override
  String get tags_create_tip =>
      'نصيحة: اكتب طعام/قهوة لتضع الوسم داخل وسم آخر مباشرة.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وسم فرعي',
      many: '$count وسمًا فرعيًا',
      few: '$count وسوم فرعية',
      two: 'وسمان فرعيان',
      one: 'وسم فرعي واحد',
      zero: 'لا وسوم فرعية',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'كيف تستخدم الوسوم؟';

  @override
  String get tags_graph_mode_all => 'الكل';

  @override
  String get tags_graph_mode_spending => 'المصروفات';

  @override
  String get tags_graph_mode_income => 'الدخل';

  @override
  String get tags_graph_legend_size => 'أكبر = مال أكثر';

  @override
  String get tags_graph_legend_nested => 'فرعي';

  @override
  String get tags_graph_legend_together => 'مستخدمة معًا';

  @override
  String get tags_graph_tap_hint => 'اضغط على دائرة لترى أرقامها';

  @override
  String get tags_graph_open => 'فتح';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مرتبط بـ $count وسم',
      many: 'مرتبط بـ $count وسمًا',
      few: 'مرتبط بـ $count وسوم',
      two: 'مرتبط بوسمين',
      one: 'مرتبط بوسم واحد',
      zero: 'لا روابط بعد',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'نقل';

  @override
  String tag_move_title(String name) {
    return 'نقل #$name';
  }

  @override
  String get tag_moved => 'تم نقل الوسم';

  @override
  String get tag_add_nested => 'إضافة وسم فرعي';

  @override
  String get tag_nested_tags => 'الوسوم الفرعية';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يشمل $count وسم فرعي',
      many: 'يشمل $count وسمًا فرعيًا',
      few: 'يشمل $count وسوم فرعية',
      two: 'يشمل وسمين فرعيين',
      one: 'يشمل وسمًا فرعيًا واحدًا',
      zero: 'بدون وسوم فرعية',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ستتم إزالته مع $count وسم فرعي من كل المعاملات. تبقى المعاملات نفسها.',
      many:
          'ستتم إزالته مع $count وسمًا فرعيًا من كل المعاملات. تبقى المعاملات نفسها.',
      few:
          'ستتم إزالته مع $count وسوم فرعية من كل المعاملات. تبقى المعاملات نفسها.',
      two:
          'ستتم إزالته مع وسميه الفرعيين من كل المعاملات. تبقى المعاملات نفسها.',
      one: 'ستتم إزالته مع وسمه الفرعي من كل المعاملات. تبقى المعاملات نفسها.',
      zero: 'ستتم إزالته من كل المعاملات. تبقى المعاملات نفسها.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'تُعاد تسمية الوسوم الفرعية أيضًا. استخدم / لنقله تحت وسم آخر.';

  @override
  String get tag_top_level => 'المستوى الأعلى';

  @override
  String get tag_nested_empty => 'لا توجد وسوم فرعية بعد';

  @override
  String get settings_help => 'تحتاج مساعدة؟';

  @override
  String get help_title => 'تحتاج مساعدة؟';

  @override
  String get help_subtitle => 'أدلة قصيرة لتستفيد من Wumbi إلى أقصى حد.';

  @override
  String get help_tags_title => 'كيف تستخدم الوسوم؟';

  @override
  String get help_tags_subtitle => 'الوسوم والوسوم الفرعية والخريطة';

  @override
  String get help_tags_intro =>
      'الوسوم تسميات قصيرة مثل #قهوة تضيفها إلى معاملاتك. يمكن للمعاملة أن تحمل عدة وسوم، فترى أموالك من أي زاوية، لا حسب المحفظة فقط.';

  @override
  String get help_tags_add_title => 'إضافة وسم';

  @override
  String get help_tags_add_body =>
      'عند إدخال معاملة، اكتب اسمًا في حقل الوسوم ثم اختر اقتراحًا أو أنشئ وسمًا جديدًا. لا مسافات في الوسوم — اكتب coffee-shop أو coffee_shop. الأحرف الكبيرة والصغيرة تعطي الوسم نفسه.';

  @override
  String get help_tags_nested_title => 'الوسوم الفرعية';

  @override
  String get help_tags_nested_body =>
      'استخدم الشرطة المائلة / لتضع وسمًا داخل آخر مثل المجلدات: طعام/قهوة وطعام/بقالة كلاهما داخل طعام. يُنشأ الوسم الأب تلقائيًا.';

  @override
  String get help_tags_parent_title => 'الوسم الأب يشمل وسومه الفرعية';

  @override
  String get help_tags_parent_body =>
      'عند فتح #طعام تظهر كل معاملة موسومة بـ #طعام أو #طعام/قهوة أو #طعام/بقالة. المجاميع والمرشحات والميزانيات على الوسم الأب تحسب وسومه الفرعية أيضًا. المعاملة التي تحمل الوسمين تُحسب مرة واحدة فقط.';

  @override
  String get help_tags_multi_title => 'عدة وسوم على معاملة واحدة';

  @override
  String get help_tags_multi_body =>
      'عشاء في العطلة يمكن أن يكون #سفر و#طعام/مطعم في الوقت نفسه. عندها يُحسب في كليهما ويرتبط الوسمان على الخريطة.';

  @override
  String get help_tags_manage_title => 'إنشاء، إعادة تسمية، نقل';

  @override
  String get help_tags_manage_body =>
      'في صفحة الوسوم اضغط + لإنشاء وسم واختر وسمًا أبًا لتضعه داخله. افتح وسمًا لإعادة تسميته أو نقله تحت وسم آخر أو إضافة وسم فرعي أو حذفه. إعادة تسمية الوسم الأب تعيد تسمية وسومه الفرعية، وإعادة التسمية إلى وسم موجود تدمجهما.';

  @override
  String get help_tags_map_title => 'قراءة الخريطة';

  @override
  String get help_tags_map_body =>
      'كل دائرة وسم: كلما كبرت مرّ عبرها مال أكثر. تُظهر حلقتها حصة المصروفات والدخل. الخطوط المتصلة تربط الوسم الأب بوسومه الفرعية، والخطوط الباهتة تربط الوسوم المستخدمة في المعاملة نفسها. اضغط على دائرة لترى أرقامها.';

  @override
  String get help_tags_tips_title => 'نصائح';

  @override
  String get help_tags_tip1 =>
      'ابدأ بوسوم عامة — طعام، منزل، مواصلات — ولا تستخدم الوسوم الفرعية إلا عند الحاجة إلى تفاصيل أكثر.';

  @override
  String get help_tags_tip2 =>
      'استخدم الوسوم لما يمتد عبر محافظك: #عطلة، #هدايا، #سيارة.';

  @override
  String get help_tags_tip3 => 'اجعل الأسماء قصيرة؛ مستويان أو ثلاثة تكفي.';

  @override
  String get help_tags_example => 'مثال';

  @override
  String get help_tags_example_total => 'مجموع #طعام';

  @override
  String get help_tags_ex_parent => 'طعام';

  @override
  String get help_tags_ex_child1 => 'قهوة';

  @override
  String get help_tags_ex_child2 => 'بقالة';

  @override
  String get help_tags_ex_travel => 'سفر';

  @override
  String get help_tags_ex_restaurant => 'مطعم';

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
  String get progress_by_day => 'يومًا بيوم';

  @override
  String get progress_by_month => 'شهرًا بشهر';

  @override
  String get progress_other => 'أخرى';

  @override
  String get progress_month => 'شهر';

  @override
  String get progress_year => 'سنة';

  @override
  String get progress_income => 'دخل';

  @override
  String get progress_all_wallets => 'كل المحافظ';

  @override
  String get progress_scope_title => 'عرض البيانات لـ';

  @override
  String progress_not_included(String codes) {
    return '$codes غير مشمولة';
  }

  @override
  String get progress_empty_title => 'لا يوجد ما يمكن تحليله بعد';

  @override
  String get progress_untagged => 'بدون وسم';

  @override
  String get progress_no_expenses => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get progress_empty_subtitle => 'أضف بعض المعاملات وسيظهر تقدمك هنا.';

  @override
  String get progress_spent => 'المصروف';

  @override
  String get progress_spending => 'المصروفات';

  @override
  String get progress_saved => 'المدّخر';

  @override
  String get progress_overspent => 'تجاوز';

  @override
  String progress_vs(String label) {
    return 'مقارنة بـ $label';
  }

  @override
  String progress_kept_share(int percent) {
    return 'احتفظت بـ $percent% من دخلك';
  }

  @override
  String progress_overspent_by(String amount) {
    return 'أنفقت $amount أكثر مما كسبت';
  }

  @override
  String progress_nothing_in(String period) {
    return 'لا توجد معاملات في $period';
  }

  @override
  String get progress_compare_title => 'قارن مع';

  @override
  String get progress_baseline_previous_month => 'الشهر السابق';

  @override
  String get progress_baseline_previous_year => 'السنة السابقة';

  @override
  String get progress_baseline_last_year => 'نفس الشهر من العام الماضي';

  @override
  String progress_baseline_average_months(int count) {
    return 'متوسط آخر $count أشهر';
  }

  @override
  String progress_baseline_average_years(int count) {
    return 'متوسط آخر $count سنوات';
  }

  @override
  String get progress_baseline_pick_month => 'اختر شهرًا';

  @override
  String get progress_baseline_pick_year => 'اختر سنة';

  @override
  String progress_average_months(int count) {
    return 'متوسط $count أشهر';
  }

  @override
  String progress_average_years(int count) {
    return 'متوسط $count سنوات';
  }

  @override
  String get progress_pace_title => 'وتيرة الإنفاق';

  @override
  String progress_pace_less(String amount, String baseline) {
    return '$amount أقل من $baseline حتى الآن';
  }

  @override
  String progress_pace_more(String amount, String baseline) {
    return '$amount أكثر من $baseline حتى الآن';
  }

  @override
  String progress_pace_same(String baseline) {
    return 'نفس وتيرة $baseline';
  }

  @override
  String progress_total_less(String amount, String baseline) {
    return '$amount أقل من $baseline';
  }

  @override
  String progress_total_more(String amount, String baseline) {
    return '$amount أكثر من $baseline';
  }

  @override
  String progress_total_same(String baseline) {
    return 'تقريبًا مثل $baseline';
  }

  @override
  String progress_forecast_month(String amount) {
    return 'بهذه الوتيرة ≈ $amount بنهاية الشهر';
  }

  @override
  String progress_forecast_year(String amount) {
    return 'بهذه الوتيرة ≈ $amount بنهاية السنة';
  }

  @override
  String progress_day(int day) {
    return 'اليوم $day';
  }

  @override
  String get progress_changes_title => 'ما الذي تغيّر';

  @override
  String progress_now_was(String now, String was) {
    return 'الآن $now · كان $was';
  }

  @override
  String get progress_new => 'جديد';

  @override
  String get progress_breakdown_title => 'حسب الوسم';

  @override
  String get progress_no_income => 'لا يوجد دخل في هذه الفترة';

  @override
  String progress_show_all(int count) {
    return 'عرض الكل ($count)';
  }

  @override
  String get progress_show_less => 'عرض أقل';

  @override
  String get progress_overlap_hint =>
      'تُحتسب المعاملة التي تحمل وسومًا من عدة مجموعات في كل منها.';

  @override
  String get progress_habits_title => 'العادات';

  @override
  String get progress_daily_average => 'المتوسط اليومي';

  @override
  String get progress_biggest_expense => 'أكبر مصروف';

  @override
  String get progress_recurring => 'المدفوعات المتكررة';

  @override
  String progress_recurring_share(int percent) {
    return '$percent% من مصروفاتك';
  }

  @override
  String get progress_average_expense => 'متوسط المصروف';

  @override
  String progress_peak_weekday(String weekday) {
    return 'أكثر يوم تنفق فيه: $weekday';
  }

  @override
  String get progress_weekday_hint => 'متوسط الإنفاق حسب أيام الأسبوع';

  @override
  String progress_history_months(int count) {
    return 'آخر $count شهرًا';
  }

  @override
  String progress_history_years(int count) {
    return 'آخر $count سنوات';
  }

  @override
  String progress_average_per_month(String amount) {
    return 'بمتوسط $amount شهريًا';
  }

  @override
  String progress_average_per_year(String amount) {
    return 'بمتوسط $amount سنويًا';
  }

  @override
  String progress_to_date_hint(String baseline) {
    return 'مقارنة بالأيام نفسها من $baseline';
  }

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
  String debt_error_owes_you_only(String name, String amount) {
    return '$name مدين لك بـ $amount فقط';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return 'أنت مدين لـ $name بـ $amount فقط';
  }

  @override
  String get person_error_has_debts => 'سدّد ديون هذا الشخص أو احذفها أولًا.';

  @override
  String get debt_error_closed => 'تمت تسوية هذا الدين بالفعل.';

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
  String get dashboard_budgets => 'الميزانيات';

  @override
  String get budget_new => 'ميزانية جديدة';

  @override
  String get budget_empty_hint => 'حدّد سقفًا للإنفاق لمحفظة أو #وسم';

  @override
  String get budgets_all => 'كل الميزانيات';

  @override
  String get budgets_title => 'الميزانيات';

  @override
  String budget_left(String amount) {
    return 'متبقٍ $amount';
  }

  @override
  String budget_over(String amount) {
    return 'تجاوز $amount';
  }

  @override
  String budget_starts(String date) {
    return 'يبدأ في $date';
  }

  @override
  String get budget_ended => 'انتهت';

  @override
  String budget_per_day(String amount) {
    return '$amount/يوم';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return 'أُنفق $spent من $limit';
  }

  @override
  String get budget_this_week => 'هذا الأسبوع';

  @override
  String get budget_set_limit => 'حدّد سقف إنفاق';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name: متبقٍ $amount';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name: تجاوز $amount';
  }

  @override
  String get budget_all_spending => 'كل النفقات';

  @override
  String get budget_name => 'الاسم';

  @override
  String get budget_name_placeholder => 'الاسم';

  @override
  String budget_name_hint(String name) {
    return 'اسم الميزانية: $name';
  }

  @override
  String get budget_what_counts => 'ما الذي يُحتسب';

  @override
  String get budget_wallets => 'المحافظ';

  @override
  String get budget_all_wallets => 'كل المحافظ';

  @override
  String get budget_tags => 'الوسوم';

  @override
  String get budget_any_tag => 'أي وسم';

  @override
  String get budget_scope_all => 'يحتسب كل النفقات.';

  @override
  String budget_scope_wallets(String wallets) {
    return 'يحتسب النفقات من $wallets.';
  }

  @override
  String budget_scope_tags(String tags) {
    return 'يحتسب النفقات الموسومة $tags.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return 'يحتسب النفقات من $wallets الموسومة $tags.';
  }

  @override
  String get budget_scope_or => 'أو';

  @override
  String get budget_period_section => 'الفترة';

  @override
  String get budget_repeats => 'التكرار';

  @override
  String get budget_period_weekly => 'أسبوعيًا';

  @override
  String get budget_period_monthly => 'شهريًا';

  @override
  String get budget_period_yearly => 'سنويًا';

  @override
  String get budget_period_custom => 'لمرة واحدة';

  @override
  String get budget_starts_on => 'يبدأ في';

  @override
  String get budget_first_day => 'اليوم الأول';

  @override
  String get budget_last_day => 'اليوم الأخير';

  @override
  String budget_day_of_month(int day) {
    return 'اليوم $day';
  }

  @override
  String get budget_start_day_title => 'يوم البدء';

  @override
  String get budget_start_day_hint => 'تبدأ الأشهر الأقصر في يومها الأخير.';

  @override
  String get budget_start_weekday_title => 'أول أيام الأسبوع';

  @override
  String get budget_carry_over => 'الترحيل';

  @override
  String get budget_rollover_none => 'لا ترحيل';

  @override
  String get budget_rollover_surplus => 'ترحيل المتبقي';

  @override
  String get budget_rollover_both => 'ترحيل المتبقي والتجاوز';

  @override
  String get budget_count_planned => 'احتساب المخطط';

  @override
  String get budget_count_planned_hint => 'يشمل القادمة والاشتراكات';

  @override
  String get budget_count_planned_desc =>
      'تُحتسب الدفعات القادمة والاشتراكات من الحد قبل دفعها.';

  @override
  String budget_suggested_months(String amount) {
    return 'مقترح: $amount · متوسط آخر 3 أشهر';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'مقترح: $amount · متوسط آخر 3 أسابيع';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'مقترح: $amount · متوسط آخر 3 سنوات';
  }

  @override
  String get budget_deleted => 'حُذفت الميزانية';

  @override
  String budget_delete_title(String name) {
    return 'حذف $name؟';
  }

  @override
  String get budget_delete_message => 'تبقى معاملاتك كما هي.';

  @override
  String get budget_error_name => 'اسم حتى 40 حرفًا';

  @override
  String get budget_error_dates => 'يجب أن يأتي اليوم الأخير بعد الأول';

  @override
  String get budget_left_caption => 'متبقٍ';

  @override
  String get budget_over_caption => 'تجاوز';

  @override
  String get budget_under_caption => 'دون الحد';

  @override
  String budget_spent(String amount) {
    return 'المُنفق $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'المخطط $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'الحد $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount مُرحَّل';
  }

  @override
  String get budget_on_track => 'على المسار';

  @override
  String budget_ahead_of_pace(String amount) {
    return '$amount أقل من الوتيرة';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return '$amount أسرع من المخطط';
  }

  @override
  String budget_forecast(String amount) {
    return 'التوقع $amount';
  }

  @override
  String get budget_no_spending => 'لا نفقات بعد في هذه الفترة';

  @override
  String get budgets_active => 'نشطة';

  @override
  String get budgets_upcoming => 'قادمة';

  @override
  String get budgets_empty_title => 'لا ميزانيات بعد';

  @override
  String get budgets_empty_subtitle => 'حدّد سقفًا وتابع المتبقي';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count ميزانيات أخرى',
      one: '+ميزانية أخرى',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أيام',
      one: 'يوم واحد',
    );
    return '$amount/يوم لمدة $_temp0';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اشتراكات',
      one: 'اشتراك واحد',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المنتهية ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حُذفت $count ميزانيات',
      one: 'حُذفت ميزانية واحدة',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'الديون';

  @override
  String get debts_owed_to_me => 'مستحق لي';

  @override
  String get debts_i_owe => 'عليّ';

  @override
  String get debts_empty_owed_title => 'لا أحد مدين لك';

  @override
  String get debts_empty_owe_title => 'لستَ مدينًا لأحد';

  @override
  String get debts_empty_subtitle =>
      'اضغط «دين جديد» أو استخدم تحويل ← الديون في شاشة المعاملة';

  @override
  String get debt_new => 'دين جديد';

  @override
  String get debt_edit_title => 'تعديل الدين';

  @override
  String get debts_all => 'كل الديون';

  @override
  String get debts_empty_hint => 'تتبّع المال الذي أقرضته أو اقترضته';

  @override
  String get dashboard_reorder_hint => 'اضغط مطولاً لإعادة الترتيب';

  @override
  String dashboard_debts_to_receive(String amount) {
    return 'لك $amount';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return 'عليك $amount';
  }

  @override
  String get dashboard_new => 'جديد';

  @override
  String get debt_they_owe_me => 'مدين لي';

  @override
  String get debt_i_owe_them => 'أنا مدين';

  @override
  String get debt_person => 'مع من';

  @override
  String get debt_person_chip => 'مع من';

  @override
  String get debt_person_title => 'مع من؟';

  @override
  String get debt_person_search => 'الاسم — شخص، بنك، متجر…';

  @override
  String get debt_person_empty => 'لا أحد بعد — اكتب اسمًا';

  @override
  String get debt_person_none => 'لا أحد';

  @override
  String get debt_choose => 'اختر';

  @override
  String get debt_amount => 'المبلغ';

  @override
  String get debt_note_hint => 'ملاحظة (اختياري)';

  @override
  String get debt_note_placeholder => 'ملاحظة';

  @override
  String get debt_due_date => 'تاريخ الاستحقاق';

  @override
  String get debt_due_title => 'تاريخ الاستحقاق';

  @override
  String get debt_add_due => 'الاستحقاق';

  @override
  String get debt_due_change => 'تغيير التاريخ';

  @override
  String get debt_due_remove => 'إزالة تاريخ الاستحقاق';

  @override
  String get debt_none => 'لا يوجد';

  @override
  String get debt_money_moved => 'حركة المال';

  @override
  String get debt_not_in_wallet => 'خارج المحافظ';

  @override
  String get debt_error_person => 'اختر مع من';

  @override
  String get debt_gave => 'أعطيت';

  @override
  String get debt_got => 'استلمت';

  @override
  String get debt_badge_loan => 'دين';

  @override
  String get debt_badge_return => 'سداد';

  @override
  String get debt_overdue => 'متأخر';

  @override
  String get debt_settled_label => 'مُسدَّد';

  @override
  String get debt_forgiven_label => 'مُعفى';

  @override
  String get debt_returned_in_full => 'أُعيد بالكامل';

  @override
  String get debt_paid_in_full => 'سُدّد بالكامل';

  @override
  String get debt_part => 'جزء';

  @override
  String get debt_forgive => 'إعفاء';

  @override
  String get debt_remind => 'تذكير';

  @override
  String get debt_history => 'السجل';

  @override
  String get debt_edit_note => 'تعديل الملاحظة';

  @override
  String get debt_rename_person => 'إعادة تسمية';

  @override
  String get debt_delete => 'حذف الدين';

  @override
  String get debt_delete_title => 'حذف هذا الدين؟';

  @override
  String get debt_deleted => 'حُذف الدين';

  @override
  String get debt_payment_deleted => 'حُذفت الدفعة';

  @override
  String get debt_return_deleted => 'حُذف السداد';

  @override
  String debt_due(String date) {
    return 'يستحق $date';
  }

  @override
  String debt_left(String amount) {
    return 'متبقٍ $amount';
  }

  @override
  String debt_left_of(String amount) {
    return 'متبقٍ من $amount';
  }

  @override
  String debt_of(String amount) {
    return 'من $amount';
  }

  @override
  String debt_to_wallet(String wallet) {
    return 'إلى $wallet';
  }

  @override
  String debt_from_wallet(String wallet) {
    return 'من $wallet';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name مدين لك بـ $amount';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return 'أنت مدين لـ $name بـ $amount';
  }

  @override
  String debt_overall(String text) {
    return 'الإجمالي: $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'الإجمالي: $name مدين لك بـ $owed · وأنت مدين بـ $owe';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name مدين لك بـ $amount · «استلمت» تُحتسب سدادًا';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return 'أنت مدين لـ $name بـ $amount · «أعطيت» تُحتسب سدادًا';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name مدين لك بـ $owed · وأنت مدين بـ $owe';
  }

  @override
  String debt_hint_none(String name) {
    return 'لا ديون مفتوحة مع $name · «أعطيت» إقراض، «استلمت» اقتراض';
  }

  @override
  String debt_person_add(String name) {
    return 'إضافة «$name»';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'مدين لك بـ $amount';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'أنت مدين بـ $amount';
  }

  @override
  String debt_title_lent_to(String name) {
    return 'أقرضت $name';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return 'اقترضت من $name';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name سدّد';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return 'سدّدت لـ $name';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return 'أقرضت $amount لـ $name';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return 'اقترضت $amount من $name';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name أعاد $amount · متبقٍ $left';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name أعاد $amount · سُدّد بالكامل';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return 'سدّدت $amount لـ $name · متبقٍ $left';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return 'سدّدت $amount لـ $name · سُدّد بالكامل';
  }

  @override
  String debt_forgive_title(String name) {
    return 'إعفاء $name؟';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'سيُشطب المتبقي $amount. لا يتحرك أي مال.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'أُعفي الدين · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'مرحبًا $name! تذكير بمبلغ $amount مقابل $note ($date). شكرًا!';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'مرحبًا $name! تذكير بمبلغ $amount ($date). شكرًا!';
  }

  @override
  String debt_history_lent(String amount) {
    return 'أقرضت $amount';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return 'أقرضت $amount من $wallet';
  }

  @override
  String debt_history_borrowed(String amount) {
    return 'اقترضت $amount';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return 'اقترضت $amount إلى $wallet';
  }

  @override
  String debt_history_returned(String amount) {
    return 'أُعيد $amount';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return 'أُعيد $amount ← $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return 'سدّدت $amount';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return 'سدّدت $amount من $wallet';
  }

  @override
  String debt_history_forgiven(String amount) {
    return 'أُعفي $amount';
  }

  @override
  String debts_overdue_count(int count) {
    return '$count متأخرة';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ديون',
      one: 'دين واحد',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص',
      one: 'شخص واحد',
      zero: 'لا أحد',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المُسدَّدة ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'حُذف الدين مع $count سدادات',
      one: 'حُذف الدين مع سداد واحد',
      zero: 'حُذف الدين',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ستُحذف $count معاملات أيضًا.',
      one: 'ستُحذف معاملة واحدة أيضًا.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'اشتراك جديد';

  @override
  String subscriptions_active_count(int count) {
    return 'نشط: $count';
  }

  @override
  String subscriptions_paused_count(int count) {
    return 'متوقّف: $count';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'حدّد سقف إنفاق لتبقى هذه المحفظة تحت السيطرة.';

  @override
  String get wallet_include_in_total => 'احتسابها في الرصيد الإجمالي';

  @override
  String get wallet_include_in_total_on =>
      'يُضاف رصيد هذه المحفظة إلى الإجمالي في الشاشة الرئيسية.';

  @override
  String get wallet_include_in_total_off =>
      'لا تُحتسب في الإجمالي في الشاشة الرئيسية — مفيد للمدخرات أو المحافظ المشتركة أو محافظ المتابعة فقط.';

  @override
  String get dashboard_wallets_not_counted => 'غير محتسبة في الرصيد الإجمالي';

  @override
  String dashboard_wallets_excluded(int count) {
    return 'غير محتسبة: $count';
  }

  @override
  String get budget_rollover_none_desc =>
      'تبدأ كل فترة من جديد بالحد نفسه. لا يُرحَّل المتبقي ولا التجاوز.';

  @override
  String get budget_rollover_surplus_desc =>
      'ما لم تنفقه يُضاف إلى حد الفترة التالية.';

  @override
  String get budget_rollover_both_desc =>
      'المتبقي يرفع حد الفترة التالية، والتجاوز يخفضه.';

  @override
  String get budget_planned_title => 'المدفوعات المخططة';

  @override
  String get budget_planned_exclude => 'عدم احتساب المخطط';

  @override
  String get budget_planned_exclude_desc =>
      'تُحتسب من الحد المدفوعات المنفذة فقط. تُحتسب الدفعات القادمة والاشتراكات بعد دفعها.';

  @override
  String budget_used_percent(int percent) {
    return 'مُستخدم $percent%';
  }

  @override
  String get budget_stat_spent => 'المُنفق';

  @override
  String get budget_stat_limit => 'الحد';

  @override
  String get budget_stat_planned => 'المخطط';

  @override
  String get budget_stat_per_day => 'يوميًا';

  @override
  String get budget_stat_forecast => 'التوقع';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يتبقى $count يوم',
      many: 'يتبقى $count يومًا',
      few: 'يتبقى $count أيام',
      two: 'يتبقى يومان',
      one: 'يتبقى يوم واحد',
      zero: 'لم يتبقَّ أي يوم',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_monthly_spend => 'الإنفاق الشهري';

  @override
  String get subscriptions_active_empty => 'لا توجد اشتراكات نشطة';

  @override
  String get subscriptions_paused_empty => 'لا توجد اشتراكات متوقّفة';

  @override
  String budgets_summary_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تجاوزت $count ميزانيات',
      one: 'تجاوزت ميزانية واحدة',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_close(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ميزانيات قريبة من حدودها',
      one: 'ميزانية واحدة قريبة من حدها',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_ok(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أنت ضمن ميزانياتك',
      one: 'أنت ضمن ميزانيتك',
    );
    return '$_temp0';
  }

  @override
  String get budget_edit_title => 'تعديل الميزانية';

  @override
  String get wallet_edit_title => 'تعديل المحفظة';

  @override
  String get budget_tab_overview => 'نظرة عامة';

  @override
  String get budget_back_to_current => 'العودة إلى اليوم';

  @override
  String get budget_row_starts => 'يبدأ في';

  @override
  String debt_story_lent_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return 'لا يزال $name مدينًا لك بـ $left من أصل $total أقرضته في $date.';
  }

  @override
  String debt_story_borrowed_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return 'لا تزال مدينًا لـ $name بـ $left من أصل $total اقترضته في $date.';
  }

  @override
  String debt_story_lent_settled(String name, String total, String date) {
    return 'أعاد $name كامل مبلغ $total الذي أقرضته في $date.';
  }

  @override
  String debt_story_borrowed_settled(String name, String total, String date) {
    return 'سددت كامل مبلغ $total الذي اقترضته من $name في $date.';
  }

  @override
  String debt_story_forgiven(String total, String date) {
    return 'أُغلق في $date — تم التنازل عن باقي مبلغ $total.';
  }

  @override
  String get debt_stat_lent => 'المُقرَض';

  @override
  String get debt_stat_borrowed => 'المُقترَض';

  @override
  String get debt_stat_paid_back => 'المُسدَّد';

  @override
  String get debt_stat_date => 'التاريخ';

  @override
  String get debt_stat_due => 'الاستحقاق';

  @override
  String get debt_note => 'ملاحظة';

  @override
  String get debt_add_note => 'إضافة ملاحظة';

  @override
  String get debt_got_part_back => 'استرددت جزءًا';

  @override
  String get debt_paid_part => 'سددت جزءًا';

  @override
  String get debt_section_details => 'التفاصيل';

  @override
  String get debts_to_receive => 'لك';

  @override
  String get debts_to_pay => 'عليك';

  @override
  String get debts_settled_empty => 'لا توجد ديون مسددة بعد';

  @override
  String get transfer_debt_pay_back => 'سداد';

  @override
  String get transfer_debt_lend => 'إقراض';

  @override
  String get transfer_debt_lend_someone => 'إقراض…';

  @override
  String transfer_debt_lend_to(String name) {
    return 'إقراض $name';
  }

  @override
  String transfer_debt_only_left(String amount) {
    return 'المتبقي $amount فقط';
  }

  @override
  String get transfer_debt_locked =>
      'لا يمكن للدين أن يتكرر أو يكون بتاريخ مستقبلي';

  @override
  String transfer_debt_summary_repay(
    String wallet,
    String amount,
    String name,
  ) {
    return '$wallet −$amount → سداد لـ $name';
  }

  @override
  String transfer_debt_summary_lend(String wallet, String amount, String name) {
    return '$wallet −$amount → إقراض $name';
  }

  @override
  String get debt_wallet_title_in => 'أين وصل المال؟';

  @override
  String get debt_wallet_title_out => 'من أين دفعت؟';

  @override
  String debt_wallet_explain_in(String name, String amount) {
    return 'أعاد لك $name مبلغ $amount. إلى أي محفظة دخل المال؟ سنضيفه إليها. إن كان نقدًا لا تتابعه، اختر «خارج المحافظ».';
  }

  @override
  String debt_wallet_explain_out(String name, String amount) {
    return 'أنت تسدد لـ $name مبلغ $amount. من أي محفظة يخرج المال؟ سنخصمه منها. إن دفعت نقدًا لا تتابعه، اختر «خارج المحافظ».';
  }

  @override
  String get debt_wallet_only_debt => 'لا تتغير أي محفظة، الدين فقط';

  @override
  String debt_wallet_confirm_in(String wallet) {
    return 'إضافة إلى $wallet';
  }

  @override
  String debt_wallet_confirm_out(String wallet) {
    return 'الدفع من $wallet';
  }

  @override
  String get debt_wallet_confirm_none => 'حفظ بدون محفظة';

  @override
  String get debt_history_swipe_hint => 'اسحب الدفعة لليسار لحذفها';

  @override
  String get debt_form_person => 'شخص';

  @override
  String get debt_form_wallet => 'المحفظة';

  @override
  String get menu_open => 'فتح القائمة';

  @override
  String get menu_close => 'إغلاق القائمة';

  @override
  String get settings_mascot_talks => 'Wumbi يتكلّم';

  @override
  String get mascot_label => 'الهامستر Wumbi. اضغط للدردشة';

  @override
  String get mascot_dismiss => 'دع Wumbi يعود إلى زاويته';

  @override
  String get mascot_action_view => 'أرني';

  @override
  String get mascot_action_add => 'إضافة';

  @override
  String mascot_month_flow(String month, String income, String expense) {
    return '$month: ‎+$income · ‎−$expense';
  }

  @override
  String get mascot_greeting_morning => 'صباح الخير يا سيدي!';

  @override
  String get mascot_greeting_afternoon => 'أهلًا يا سيدي!';

  @override
  String get mascot_greeting_evening => 'مساء الخير يا سيدي!';

  @override
  String get mascot_all_calm => 'كل شيء هادئ، والبذور في مكانها';

  @override
  String get mascot_all_for_now => 'هذا كل ما أعرفه الآن 🙂';

  @override
  String get mascot_quiet_today => 'فهمت يا سيدي، سأصمت اليوم';

  @override
  String mascot_flow_up(String amount, String month) {
    return '$month: نما المخزون بمقدار $amount. استمر هكذا!';
  }

  @override
  String mascot_flow_down(String amount, String month) {
    return '$month: خرج $amount أكثر مما دخل. لا بأس، سنعوّض';
  }

  @override
  String mascot_reserve_full(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'الخدّان ممتلئان! بذور تكفي $months شهرًا',
      few: 'الخدّان ممتلئان! بذور تكفي $months أشهر',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'سيدي، موعد الدين مع $name مضى عليه $days يومًا',
      few: 'سيدي، موعد الدين مع $name مضى عليه $days أيام',
      two: 'سيدي، موعد الدين مع $name مضى عليه يومان',
      one: 'سيدي، موعد الدين مع $name كان أمس',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue_nudge(String name) {
    return 'الدين مع $name ما زال معلّقًا يا سيدي. نلقي نظرة؟';
  }

  @override
  String mascot_budget_over(String name) {
    return 'سيدي، «$name» تجاوز الحد. لنرَ من أين تسرّبت البذور';
  }

  @override
  String mascot_budget_over_by(String name, String amount) {
    return '«$name» تجاوز بـ $amount. نفهم الأمر معًا يا سيدي؟';
  }

  @override
  String mascot_budget_near_left(String name, String amount) {
    return 'بقي $amount فقط في «$name» لهذه الفترة يا سيدي';
  }

  @override
  String mascot_budget_near_percent(String name, int percent) {
    return '«$name» وصل إلى $percent%. نخفّف قليلًا؟';
  }

  @override
  String mascot_sleep_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'غفوت يا سيدي… $days يومًا بلا تسجيل. نعوّض ما فات؟',
      few: 'غفوت يا سيدي… $days أيام بلا تسجيل. نعوّض ما فات؟',
    );
    return '$_temp0';
  }

  @override
  String get mascot_sleep_quiet =>
      'الجو هادئ جدًا هنا. ألم تنسَ تسجيل شيء يا سيدي؟';

  @override
  String get mascot_sigh_month =>
      'سيدي، هذا الشهر تخرج بذور أكثر مما يدخل. نبحث عن التسريب؟';

  @override
  String get mascot_sigh_ahead =>
      'المصاريف تسبق الدخل. لنرَ معًا ما يمكن تقليله';

  @override
  String mascot_welcome_back(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدت يا سيدي! $count تسجيلًا جديدًا منذ آخر مرة',
      few: 'عدت يا سيدي! $count تسجيلات جديدة منذ آخر مرة',
      two: 'عدت يا سيدي! تسجيلان جديدان منذ آخر مرة',
      one: 'عدت يا سيدي! تسجيل جديد واحد منذ آخر مرة',
      zero: 'عدت يا سيدي! كان المكان هادئًا بدونك',
    );
    return '$_temp0';
  }

  @override
  String get mascot_evening_waited => 'سيدي! انتظرتك طوال اليوم!';

  @override
  String get mascot_evening_missed => 'اشتقت إليك…';

  @override
  String get mascot_evening_log => 'نسجّل مصاريف اليوم قبل أن ننساها؟';

  @override
  String get mascot_evening_count => 'تساعدني نعدّ بذور اليوم؟';

  @override
  String get mascot_event_reserve =>
      'سيدي، لدينا بذور تكفي ثلاثة أشهر! الآن ننام مطمئنين';

  @override
  String mascot_event_best_month(String amount) {
    return 'أفضل شهر منذ نصف عام! دخل المخزون $amount. فخور بك يا سيدي';
  }

  @override
  String mascot_event_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days يومًا ونحن نعدّ البذور معًا. شكرًا يا سيدي!',
      few: '$days أيام ونحن نعدّ البذور معًا. شكرًا يا سيدي!',
    );
    return '$_temp0';
  }

  @override
  String get mascot_event_records =>
      'التسجيل رقم 100! العدّ معًا أمتع بكثير يا سيدي';

  @override
  String mascot_event_streak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days يومًا متتاليًا بلا انقطاع يا سيدي! هذا هو الانضباط',
      few: '$days أيام متتالية بلا انقطاع يا سيدي! هذا هو الانضباط',
    );
    return '$_temp0';
  }

  @override
  String mascot_charge_today(String name, String amount) {
    return 'سيدي، اليوم يأخذ $name مبلغ $amount';
  }

  @override
  String mascot_charge_tomorrow(String name, String amount) {
    return 'غدًا يأخذ $name مبلغ $amount يا سيدي';
  }

  @override
  String mascot_charge_soon(String name, String amount) {
    return 'خلال أيام يأخذ $name مبلغ $amount';
  }

  @override
  String get mascot_charge_unnamed => 'اشتراك';

  @override
  String mascot_debt_due_today(String name) {
    return 'سيدي، اليوم موعد الدين مع $name';
  }

  @override
  String mascot_debt_due_tomorrow(String name) {
    return 'غدًا موعد الدين مع $name. لا ننسَ؟';
  }

  @override
  String mascot_debt_due_soon(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بقي $days يومًا على موعد الدين مع $name',
      few: 'بقيت $days أيام على موعد الدين مع $name',
      two: 'بقي يومان على موعد الدين مع $name',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_mover(String name, int percent) {
    return 'سيدي، «$name» يأكل بذورًا أكثر بـ $percent% من الشهر الماضي. نلقي نظرة؟';
  }

  @override
  String mascot_insight_untagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروفًا بلا وسم هذا الشهر. نرتّبها؟',
      few: '$count مصاريف بلا وسم هذا الشهر. نرتّبها؟',
      two: 'مصروفان بلا وسم هذا الشهر. نرتّبهما؟',
      one: 'مصروف واحد بلا وسم هذا الشهر. نرتّبه؟',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_peak_day(String weekday) {
    return 'يوم $weekday هو أكثر أيامك جوعًا يا سيدي';
  }

  @override
  String mascot_insight_reserve(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'الخدّان بخير: بذور تكفي نحو $months شهرًا',
      few: 'الخدّان بخير: بذور تكفي نحو $months أشهر',
      two: 'الخدّان بخير: بذور تكفي نحو شهرين',
      one: 'الخدّان بخير: بذور تكفي نحو شهر',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_top_expense(String name, String amount) {
    return 'أكبر لقمة هذا الشهر: «$name»، $amount';
  }

  @override
  String mascot_insight_top_expense_amount(String amount) {
    return 'أكبر لقمة منفردة هذا الشهر: $amount';
  }

  @override
  String mascot_insight_daily_average(String amount) {
    return 'سيدي، يخرج هذا الشهر نحو $amount يوميًا';
  }

  @override
  String mascot_insight_daily_below(int percent) {
    return 'بذور أقل بـ $percent% يوميًا من المعتاد. أحسنت يا سيدي!';
  }

  @override
  String mascot_insight_daily_above(int percent) {
    return 'سيدي، بذور أكثر بـ $percent% يوميًا من المعتاد. نرى أين تذهب؟';
  }

  @override
  String mascot_insight_weekend(int percent) {
    return 'في عطلة الأسبوع تطير البذور أسرع بـ $percent% من أيام العمل';
  }

  @override
  String mascot_insight_frequent_tag(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرة في «$name» هذا الشهر. صارت عادة يا سيدي؟',
      few: '$count مرات في «$name» هذا الشهر. صارت عادة يا سيدي؟',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_small_spends(String amount) {
    return 'المشتريات الصغيرة بلغت $amount هذا الشهر. بذرة فوق بذرة يا سيدي';
  }

  @override
  String mascot_insight_savings_rate(int percent) {
    return 'سيدي، $percent% من دخل هذا الشهر يبقى في المخزون. خدّان سعيدان!';
  }

  @override
  String get mascot_insight_no_income =>
      'لم تدخل بذرة واحدة هذا الشهر يا سيدي. نسيت تسجيل راتبك؟';

  @override
  String mascot_insight_forecast_over(String amount) {
    return 'بهذه الوتيرة سيكلّف الشهر نحو $amount. أكثر من المعتاد يا سيدي';
  }

  @override
  String mascot_insight_forecast_under(String amount) {
    return 'هذا الشهر خفيف: نحو $amount. المخزون يشكرك';
  }

  @override
  String mascot_insight_owed_to_me(String amount) {
    return 'سيدي، لك ديون بقيمة $amount. ربما حان وقت تذكير لطيف؟';
  }

  @override
  String mascot_insight_negative_wallet(String name) {
    return '«$name» نزل تحت الصفر يا سيدي. ننقل إليه بعض البذور؟';
  }

  @override
  String mascot_insight_no_rate(String codes) {
    return 'لا أستطيع تحويل $codes بعد، لا يوجد سعر. سأكمل العدّ عند الاتصال';
  }

  @override
  String mascot_insight_income_up(int percent) {
    return 'سيدي، دخلت بذور أكثر بـ $percent% من المعتاد! نخبّئ نصف الزيادة فورًا؟';
  }

  @override
  String mascot_insight_tag_yearly(String name, String amount) {
    return 'بهذه الوتيرة سيأكل «$name» نحو $amount في السنة';
  }

  @override
  String get mascot_insight_no_spend_yesterday =>
      'لا مصروف واحد أمس! خدّاي فخوران بك يا سيدي';

  @override
  String get mascot_tip_budget =>
      'سيدي، الميزانية مجرد سياج صغير حول البذور. نضع الأول؟';

  @override
  String get mascot_tip_subscriptions =>
      'لديك مدفوعات منتظمة؟ أضفها مرة واحدة وسأراقبها';

  @override
  String mascot_tip_subs_yearly(String amount) {
    return 'سيدي، الاشتراكات تأكل $amount في السنة. هل منها ما لا تستخدمه؟';
  }

  @override
  String mascot_tip_recurring_share(int percent) {
    return '$percent% من مصاريف الشهر مدفوعات منتظمة. تدور مثل عجلتي';
  }

  @override
  String get mascot_tip_new_month =>
      'شهر جديد يا سيدي! الكيس نظيف. نضع ميزانيات؟';

  @override
  String mascot_tip_monday_recap(String amount) {
    return 'الأسبوع الماضي خرج $amount. لنرَ كيف نبلي هذا الأسبوع يا سيدي';
  }

  @override
  String mascot_tip_month_end(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'بقيت $days أيام على نهاية الشهر. أداؤك رائع يا سيدي',
      two: 'بقي يومان على نهاية الشهر. أداؤك رائع يا سيدي',
      one: 'بقي يوم واحد على نهاية الشهر. أداؤك رائع يا سيدي',
    );
    return '$_temp0';
  }

  @override
  String get mascot_tip_tags =>
      'الوسوم تساعدني أرى أين تذهب البذور يا سيدي. جرّب #طعام أو #منزل';

  @override
  String mascot_tip_debt_due_date(String name) {
    return 'ضع موعدًا للدين مع $name وسأذكّرك في الوقت المناسب';
  }

  @override
  String mascot_tip_budget_for(String name, int percent) {
    return 'سيدي، «$name» يأخذ $percent% من كل المصاريف. نضع له ميزانية؟';
  }

  @override
  String get mascot_tip_rainy_day =>
      'سيدي، أنشئ محفظة منفصلة للأيام الصعبة. هكذا لا تفاجئنا المفاجآت';

  @override
  String get mascot_tip_pay_yourself_first =>
      'وصلت البذور! خبّئ جزءًا فورًا يا سيدي قبل أن تتبعثر';

  @override
  String get mascot_tip_treat =>
      'المخزون بخير يا سيدي. لا بأس أن تدلّل نفسك أحيانًا، بلا تأنيب ضمير';

  @override
  String mascot_tip_future_self(String amount, String amount2) {
    return '$amount فقط يوميًا تساوي $amount2 في السنة. تخيّل الخدّين يا سيدي!';
  }

  @override
  String get mascot_joke_friday =>
      'إنها الجمعة يا سيدي! استمتع، وأنا أحرس البذور';

  @override
  String get mascot_joke_late_night =>
      'تأخر الوقت يا سيدي… نسجّل ثم ننام؟ أنا أتثاءب أصلًا';

  @override
  String get mascot_joke_cheeks =>
      'هل تعلم يا سيدي؟ الهامستر يحمل البذور في خدّيه. وأنا أحمل ميزانيتك';

  @override
  String get mascot_joke_trees =>
      'حتى لو نمت البذور على الأشجار، لخبّأتها في خدّيّ';

  @override
  String get mascot_joke_twice =>
      'عددت بذورك مرتين. العدد نفسه يا سيدي. علامة جيدة';

  @override
  String get mascot_joke_secret =>
      'بسّ يا سيدي… قرّب كل مصروف للأعلى في ذهنك. الفرق هو مخبؤك السري';

  @override
  String mascot_reaction_income(String amount) {
    return 'التقطت $amount! إلى المخزون يا سيدي';
  }

  @override
  String mascot_reaction_big_income(String amount) {
    return 'واو يا سيدي! ‎+$amount. سينفجر خدّاي!';
  }

  @override
  String mascot_reaction_transfer(String amount) {
    return 'نقلت $amount';
  }

  @override
  String mascot_reaction_lent(String amount) {
    return 'أقرضنا $amount. سأتذكّر يا سيدي';
  }

  @override
  String get mascot_reaction_debt_closed => 'أُغلق الدين! كفوف نظيفة يا سيدي';

  @override
  String get mascot_reaction_forgiven => 'سامحت… قلبك طيب يا سيدي';

  @override
  String get mascot_reaction_first_wallet =>
      'المحفظة الأولى يا سيدي! لنبدأ التخزين';

  @override
  String get mascot_reaction_budget => 'الميزانية جاهزة. سأقف حارسًا يا سيدي';

  @override
  String get mascot_wallet_negative => 'سيدي، هذه المحفظة نزلت تحت الصفر';

  @override
  String mascot_wallet_down(int percent) {
    return 'ذهب $percent% من البذور هنا منذ بداية الشهر';
  }

  @override
  String mascot_wallet_up(String amount) {
    return 'زاد $amount منذ بداية الشهر. رائع يا سيدي!';
  }

  @override
  String get mascot_wallet_sleeping => 'هذه المحفظة نائمة منذ شهر. صه…';

  @override
  String get mascot_wallet_calm => 'كل شيء هادئ هنا يا سيدي';

  @override
  String mascot_budgets_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيدي، $count ميزانية تجاوزت حدودها',
      few: 'سيدي، $count ميزانيات تجاوزت حدودها',
      two: 'سيدي، ميزانيتان تجاوزتا حدّهما',
      one: 'سيدي، ميزانية واحدة تجاوزت حدّها',
    );
    return '$_temp0';
  }

  @override
  String mascot_budgets_near(String name) {
    return '«$name» أوشك على النفاد يا سيدي';
  }

  @override
  String get mascot_budgets_calm => 'كل الأسيجة صامدة يا سيدي. الميزانيات بخير';

  @override
  String mascot_budget_detail_over(String amount) {
    return 'تجاوز بـ $amount. نرفع الحد في المرة القادمة يا سيدي؟';
  }

  @override
  String mascot_budget_detail_pace(String date) {
    return 'بهذه الوتيرة ينتهي الحد في $date';
  }

  @override
  String get mascot_budget_detail_within => 'بقينا ضمن الحد! فخور بك يا سيدي';

  @override
  String get mascot_budget_detail_calm => 'كل شيء حسب الخطة يا سيدي';

  @override
  String mascot_debts_overdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيدي، $count دينًا متأخرًا',
      few: 'سيدي، $count ديون متأخرة',
      two: 'سيدي، دينان متأخران',
      one: 'سيدي، دين واحد متأخر',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debts_all_closed => 'أُغلقت كل الديون! كفوف نظيفة يا سيدي';

  @override
  String get mascot_debts_tracking => 'أتابع من يدين لمن بالبذور';

  @override
  String mascot_debt_detail_overdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'مضى على موعده $days يومًا يا سيدي',
      few: 'مضى على موعده $days أيام يا سيدي',
      two: 'مضى على موعده يومان يا سيدي',
      one: 'كان موعده أمس يا سيدي',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debt_detail_lent => 'أتذكّر من استعار بذورنا يا سيدي';

  @override
  String mascot_debt_detail_due(String date) {
    return 'يُسدَّد قبل $date';
  }

  @override
  String mascot_subs_spinning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اشتراكًا يأخذ نصيبه من البذور كل شهر',
      few: '$count اشتراكات تأخذ نصيبها من البذور كل شهر',
      two: 'اشتراكان يأخذان نصيبهما من البذور كل شهر',
      one: 'اشتراك واحد يأخذ نصيبه من البذور كل شهر',
    );
    return '$_temp0';
  }

  @override
  String mascot_tags_top(String name) {
    return 'ذهبت معظم البذور هذا الشهر إلى «$name»';
  }

  @override
  String mascot_tag_up(int percent) {
    return 'هنا أكثر بـ $percent% من الشهر الماضي';
  }

  @override
  String mascot_tag_down(int percent) {
    return 'أقل بـ $percent% من الشهر الماضي. أحسنت يا سيدي!';
  }

  @override
  String mascot_progress_saved(String amount) {
    return 'دخل المخزون $amount. عمل رائع يا سيدي!';
  }

  @override
  String mascot_progress_over(String amount) {
    return 'خرجت بذور أكثر بـ $amount مما دخل';
  }

  @override
  String mascot_progress_over_tag(String amount, String name) {
    return 'خرجت بذور أكثر بـ $amount مما دخل، معظمها على «$name»';
  }

  @override
  String mascot_progress_forecast(String amount) {
    return 'بهذه الوتيرة سيخرج نحو $amount في هذه الفترة';
  }

  @override
  String get mascot_progress_counting => 'ما زلت أعدّ هذه الفترة يا سيدي';

  @override
  String get mascot_screen_wallet_filter =>
      'صفِّ حسب الوسم وسترى أين تذهب بذور هذه المحفظة';

  @override
  String get mascot_screen_wallet_switch =>
      'اضغط اسم المحفظة في الأعلى لتقفز إلى أخرى';

  @override
  String get mascot_screen_wallet_limit =>
      'من تبويب الميزانيات يمكنك وضع حد لهذه المحفظة';

  @override
  String get mascot_screen_budgets_rollover =>
      'يمكن للميزانية نقل الباقي إلى الفترة التالية. لا تضيع بذرة';

  @override
  String get mascot_screen_budgets_tags =>
      'يمكن للميزانية مراقبة الوسوم التي تختارها فقط. مثلًا #مقهى';

  @override
  String get mascot_screen_budget_periods =>
      'تنقّل بين الفترات لتقارن مع السابقة';

  @override
  String get mascot_screen_debts_due =>
      'أضف موعدًا وسأذكّرك في الوقت المناسب يا سيدي';

  @override
  String get mascot_screen_debts_quick =>
      'أسرع طريقة للسداد: تحويل ← الديون في شاشة المعاملة';

  @override
  String get mascot_screen_subs_pause =>
      'يمكنك إيقاف الاشتراك مؤقتًا بدل حذفه. يبقى سجلّه';

  @override
  String get mascot_screen_tags_nest =>
      'اجعل الوسوم متداخلة بشرطة مائلة: طعام/قهوة';

  @override
  String get mascot_screen_tags_map =>
      'افتح الخريطة يا سيدي وسترى كيف ترتبط وسومك';

  @override
  String get mascot_screen_tag_rename =>
      'أعد تسمية الوسم أو انقله، وستتبعه الوسوم المتداخلة';

  @override
  String get mascot_screen_progress_baseline =>
      'اضغط «vs …» للمقارنة مع العام الماضي أو متوسط 3 أشهر';

  @override
  String mascot_ans_spent_today(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اليوم: $amount في $count مصروفًا',
      few: 'اليوم: $amount في $count مصاريف',
      two: 'اليوم: $amount، مصروفان',
      one: 'اليوم: $amount، مصروف واحد فقط',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_today =>
      'لا مصروف واحد اليوم يا سيدي. البذور سليمة!';

  @override
  String mascot_ans_spent_yesterday(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أمس: $amount في $count مصروفًا',
      few: 'أمس: $amount في $count مصاريف',
      two: 'أمس: $amount، مصروفان',
      one: 'أمس: $amount، مصروف واحد فقط',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_yesterday => 'أمس لم تنفق بذرة واحدة. مرحى!';

  @override
  String mascot_ans_spent_week(String amount) {
    return 'هذا الأسبوع حتى الآن: $amount';
  }

  @override
  String mascot_ans_spent_month(String expense, String income) {
    return 'هذا الشهر خرج $expense ودخل $income';
  }

  @override
  String get mascot_ans_no_expenses => 'لا مصاريف هذا الشهر بعد. رائع يا سيدي';

  @override
  String mascot_ans_upcoming(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دفعة خلال 7 أيام: $amount',
      few: '$count دفعات خلال 7 أيام: $amount',
      two: 'دفعتان خلال 7 أيام: $amount',
      one: 'دفعة واحدة خلال 7 أيام: $amount',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_upcoming => 'لا شيء للدفع خلال الأسبوع القادم';

  @override
  String mascot_ans_owed(String amount, String name) {
    return 'لك ديون بقيمة $amount، أكثرها عند $name';
  }

  @override
  String get mascot_ans_nobody_owes => 'لا أحد يدين لك بشيء الآن';

  @override
  String get mascot_ans_reserve_low =>
      'بذور أقل من شهر يا سيدي. لنملأ هذين الخدّين معًا';

  @override
  String get mascot_ans_reserve_unknown =>
      'أحتاج نحو شهر من التسجيلات لأجيب بدقة';

  @override
  String mascot_ans_where(String name, int percent, String name2) {
    return 'ذهبت معظم البذور إلى «$name» ($percent%)، ثم «$name2»';
  }

  @override
  String mascot_ans_where_one(String name, int percent) {
    return 'ذهبت كل البذور تقريبًا إلى «$name»، $percent%';
  }

  @override
  String mascot_ans_where_untagged(int percent) {
    return 'سيدي، $percent% من المصاريف بلا وسوم، فلا أرى أين ذهبت. نرتّبها؟';
  }

  @override
  String get mascot_q_today => 'كم أنفقت اليوم؟';

  @override
  String get mascot_q_yesterday => 'وأمس؟';

  @override
  String get mascot_q_week => 'هذا الأسبوع؟';

  @override
  String get mascot_q_month => 'هذا الشهر؟';

  @override
  String get mascot_q_where => 'أين ذهبت البذور؟';

  @override
  String get mascot_q_biggest => 'أكبر مصروف؟';

  @override
  String get mascot_q_budgets => 'هل أنا ضمن الميزانية؟';

  @override
  String get mascot_q_upcoming => 'ماذا سأدفع قريبًا؟';

  @override
  String get mascot_q_owed => 'من يدين لي؟';

  @override
  String get mascot_q_reserve => 'كم سيكفي؟';

  @override
  String get mascot_q_tip => 'نصيحة؟';

  @override
  String get mascot_q_joke => 'أضحكني';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
