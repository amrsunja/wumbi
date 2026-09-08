// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appLanguage => 'Türkçe';

  @override
  String get l10nCommon =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ COMMON ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get common_continue => 'Devam';

  @override
  String get common_cancel => 'Vazgeç';

  @override
  String get common_save => 'Kaydet';

  @override
  String get common_delete => 'Sil';

  @override
  String get common_confirm => 'Onayla';

  @override
  String get common_undo => 'Geri al';

  @override
  String get common_ok => 'Tamam';

  @override
  String get common_retry => 'Tekrar dene';

  @override
  String get common_today => 'Bugün';

  @override
  String get common_yesterday => 'Dün';

  @override
  String get common_income => 'Gelir';

  @override
  String get common_expense => 'Gider';

  @override
  String get common_transfer => 'Transfer';

  @override
  String get common_edit => 'Düzenle';

  @override
  String get common_all => 'Tümü';

  @override
  String get common_clear => 'Temizle';

  @override
  String get common_apply => 'Uygula';

  @override
  String get common_done => 'Bitti';

  @override
  String get common_close => 'Kapat';

  @override
  String get common_search => 'Ara';

  @override
  String get l10nOnboarding =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ONBOARDING ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get onboarding_welcome_title => 'Wumbi ile tanış';

  @override
  String get onboarding_welcome_subtitle =>
      'Paranı saniyeler içinde takip et. Kategori yok, sadece etiket.';

  @override
  String get onboarding_currency_title => 'Ana para birimin';

  @override
  String get onboarding_currency_subtitle =>
      'Toplamlar bu para biriminde gösterilir. Sonra Ayarlar\'dan değiştirebilirsin.';

  @override
  String get onboarding_wallet_title => 'İlk cüzdanın';

  @override
  String get onboarding_wallet_subtitle =>
      'Her cüzdanın tek bir para birimi olur. Sonra başka cüzdanlar ekleyebilirsin.';

  @override
  String get onboarding_create_wallet => 'Cüzdan oluştur';

  @override
  String get common_skip => 'Atla';

  @override
  String get onboarding_welcome_start => 'Başla';

  @override
  String get onboarding_benefit_wallets_title => 'Her para biriminde cüzdan';

  @override
  String get onboarding_benefit_wallets_body =>
      'Dolar, euro, bitcoin — her cüzdan kendi para birimini korur. Toplamın ise senin seçtiğin birimde görünür.';

  @override
  String get onboarding_benefit_tags_title => 'Kategori değil, etiket';

  @override
  String get onboarding_benefit_tags_body =>
      'Katı kategorileri unut. İstediğin etiketi ekle — #coffee, #trip, #work — sonra da her şeyi kolayca bul.';

  @override
  String get onboarding_benefit_one_tap_title => 'Tek dokunuşla kaydet';

  @override
  String get onboarding_benefit_one_tap_body =>
      'Tutarı yaz, Gelir ya da Gider\'e dokun. Bitti. Ekran bir sonraki için açık kalır.';

  @override
  String get onboarding_how_title => 'Nasıl çalışır';

  @override
  String get onboarding_how_body =>
      'Bir cüzdan oluştur, para hareket ettikçe kaydet ve toplamların anında güncellensin.';

  @override
  String get onboarding_how_step_wallet => 'Cüzdan ekle';

  @override
  String get onboarding_how_step_tap => 'Dokun, kaydet';

  @override
  String get onboarding_how_step_totals => 'Toplamları gör';

  @override
  String get onboarding_wallet_hero_prefix => 'İlk';

  @override
  String get onboarding_wallet_hero_accent => 'Cüzdanın';

  @override
  String get onboarding_final_title => 'Her şey hazır!';

  @override
  String get onboarding_final_body =>
      'İlk cüzdanın hazır. Gerisini Wumbi basit tutacak.';

  @override
  String get onboarding_final_button => 'Hadi başlayalım';

  @override
  String get l10nDashboard =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DASHBOARD ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get dashboard_title => 'Param';

  @override
  String dashboard_across_wallets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cüzdan genelinde',
      zero: 'Henüz cüzdan yok',
    );
    return '$_temp0';
  }

  @override
  String dashboard_not_included(String codes) {
    return '$codes dahil değil';
  }

  @override
  String get dashboard_wallets => 'Cüzdanlar';

  @override
  String get dashboard_new_wallet => 'Yeni Cüzdan';

  @override
  String get dashboard_empty_title => 'İlk cüzdanını oluştur';

  @override
  String get dashboard_empty_subtitle =>
      'Wumbi\'nin paranı tutacak bir cüzdana ihtiyacı var.';

  @override
  String get dashboard_tags => 'Etiketler';

  @override
  String get dashboard_subscriptions => 'Abonelikler';

  @override
  String get l10nWallet =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ WALLET ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get wallet_name_placeholder => 'Cüzdan Adı';

  @override
  String get wallet_currency => 'Para Birimi';

  @override
  String get wallet_primary => 'Ana Cüzdan';

  @override
  String get wallet_has_transactions => 'İşlemleri var';

  @override
  String get wallet_pick_another_primary =>
      'Ana cüzdan olarak başka bir cüzdan seç';

  @override
  String wallet_delete_title(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get wallet_delete_message =>
      'İşlemleri de silinecek. Diğer cüzdanlarla yapılan transferler görünür kalır.';

  @override
  String get wallet_deleted => 'Cüzdan silindi';

  @override
  String wallet_deleted_paused_rules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cüzdan silindi · $count tekrar duraklatıldı',
    );
    return '$_temp0';
  }

  @override
  String get wallet_empty_title => 'Henüz işlem yok';

  @override
  String get wallet_empty_subtitle => 'İlkini eklemek için + simgesine dokun';

  @override
  String get wallet_switch_title => 'Cüzdan değiştir';

  @override
  String wallet_transfer_to(String name) {
    return '$name cüzdanına transfer';
  }

  @override
  String wallet_transfer_from(String name) {
    return '$name cüzdanından transfer';
  }

  @override
  String get wallet_deleted_suffix => '(silindi)';

  @override
  String wallet_repeating_summary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tekrar',
    );
    return '$_temp0';
  }

  @override
  String get wallet_not_found => 'Bu cüzdan artık yok';

  @override
  String get wallet_filter => 'Filtre';

  @override
  String get wallet_sort => 'Sırala';

  @override
  String get wallet_filter_title => 'İşlemleri filtrele';

  @override
  String get wallet_filter_type => 'Tür';

  @override
  String get wallet_filter_date => 'Tarih';

  @override
  String get wallet_filter_tags => 'Etiketler';

  @override
  String get wallet_filter_from => 'Başlangıç';

  @override
  String get wallet_filter_to => 'Bitiş';

  @override
  String get wallet_filter_any_date => 'Her tarih';

  @override
  String get wallet_filter_this_month => 'Bu ay';

  @override
  String get wallet_filter_last_month => 'Geçen ay';

  @override
  String get wallet_filter_last_30_days => 'Son 30 gün';

  @override
  String get wallet_filter_this_year => 'Bu yıl';

  @override
  String get wallet_filter_custom_range => 'Özel aralık';

  @override
  String get wallet_filter_upcoming_only => 'Sadece yaklaşan';

  @override
  String get wallet_filter_clear => 'Filtreleri temizle';

  @override
  String get wallet_filter_no_tags => 'Bu cüzdanda henüz etiket yok';

  @override
  String get wallet_filter_no_results_title => 'Eşleşme yok';

  @override
  String get wallet_filter_no_results_subtitle =>
      'Bir filtreyi kaldırmayı dene.';

  @override
  String wallet_filter_active(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtre',
    );
    return '$_temp0';
  }

  @override
  String get wallet_sort_title => 'Sıralama';

  @override
  String get sort_date_newest => 'Önce en yeni';

  @override
  String get sort_date_oldest => 'Önce en eski';

  @override
  String get sort_amount_high => 'En yüksek tutar';

  @override
  String get sort_amount_low => 'En düşük tutar';

  @override
  String get wallet_upcoming_section => 'Yaklaşan';

  @override
  String wallet_upcoming_hint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yaklaşan işlem henüz sayılmıyor',
    );
    return '$_temp0';
  }

  @override
  String get l10nTransaction =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TRANSACTION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get transaction_edit_title => 'Düzenle';

  @override
  String get transaction_description_placeholder => 'açıklama';

  @override
  String get transaction_tags_placeholder => '#tags';

  @override
  String get transaction_repeat => 'Tekrar';

  @override
  String transaction_repeat_part_of(String frequency) {
    return '$frequency · bir tekrarın parçası';
  }

  @override
  String transaction_hint_added(String amount, String wallet) {
    return '≈ $amount · $wallet cüzdanına eklenecek';
  }

  @override
  String transaction_hint_stale(String date) {
    return '$date tarihli kur';
  }

  @override
  String get transaction_rate_unavailable =>
      'Kur yok — güncellemek için bağlan';

  @override
  String transaction_saved(String amount, String wallet) {
    return '$amount · $wallet cüzdanına eklendi';
  }

  @override
  String transaction_moved(String amount, String wallet) {
    return '$amount · $wallet cüzdanına taşındı';
  }

  @override
  String get transaction_deleted => 'İşlem silindi';

  @override
  String get transaction_upcoming_badge => 'Yaklaşan';

  @override
  String transaction_upcoming_hint(String date) {
    return '$date tarihinde sayılacak';
  }

  @override
  String transaction_scheduled(String amount, String date) {
    return '$amount · $date için planlandı';
  }

  @override
  String get transaction_delete_title => 'Bu işlem silinsin mi?';

  @override
  String get transaction_delete_this_one => 'Sadece bunu sil';

  @override
  String get transaction_delete_and_stop => 'Sil ve tekrarı durdur';

  @override
  String get transaction_need_second_wallet_title =>
      'Transfer için ikinci bir cüzdan oluştur';

  @override
  String get transaction_need_second_wallet_message =>
      'Transferler parayı iki cüzdanın arasında taşır.';

  @override
  String get transaction_different_currency => 'Farklı para birimi';

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
    return '$wallet cüzdanından $amount transfer';
  }

  @override
  String get transfer_amount_received => 'Alınan tutar';

  @override
  String get transfer_confirm => 'Transferi onayla';

  @override
  String get l10nRepeat =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ REPEAT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get repeat_never => 'Asla';

  @override
  String get repeat_every_day => 'Her gün';

  @override
  String get repeat_every_week => 'Her hafta';

  @override
  String get repeat_every_month => 'Her ay';

  @override
  String get repeat_every_year => 'Her yıl';

  @override
  String get repeat_daily => 'Günlük';

  @override
  String get repeat_weekly => 'Haftalık';

  @override
  String get repeat_monthly => 'Aylık';

  @override
  String get repeat_yearly => 'Yıllık';

  @override
  String get repeat_rules_title => 'Abonelikler';

  @override
  String get repeat_rules_hint =>
      'Düzenlemek için bir aboneliğe dokun. Mevcut işlemler hiç değişmez.';

  @override
  String repeat_next(String date) {
    return 'Sonraki: $date';
  }

  @override
  String get repeat_paused => 'Duraklatıldı';

  @override
  String get repeat_delete_title => 'Bu tekrar durdurulsun mu?';

  @override
  String get repeat_delete_message =>
      'Mevcut işlemler kalır. Yeni işlem oluşturulmaz.';

  @override
  String get repeat_stop => 'Durdur';

  @override
  String get l10nDate =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ DATE ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get date_pick_title => 'Tarih seç';

  @override
  String get date_pick_from => 'Başlangıç';

  @override
  String get date_pick_to => 'Bitiş';

  @override
  String get l10nSearch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SEARCH ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get search_title => 'Arama';

  @override
  String get search_placeholder => 'Açıklama, tutar, cüzdan veya etiket';

  @override
  String get search_hint =>
      'Tüm cüzdanlarda açıklama, tutar, cüzdan adı veya etikete göre ara.';

  @override
  String get search_no_results_title => 'Sonuç yok';

  @override
  String get search_no_results_subtitle =>
      'Başka bir kelime, tutar veya etiket dene.';

  @override
  String search_results_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sonuç',
    );
    return '$_temp0';
  }

  @override
  String get l10nTags =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ TAGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get tags_title => 'Etiketler';

  @override
  String get tags_view_list => 'Liste';

  @override
  String get tags_view_graph => 'Harita';

  @override
  String get tags_search_placeholder => 'Etiket ara';

  @override
  String get tags_empty_title => 'Henüz etiket yok';

  @override
  String get tags_empty_subtitle =>
      'Bir işleme #tags ekle, burada görünecekler.';

  @override
  String get tags_search_no_results => 'Aramanla eşleşen etiket yok';

  @override
  String tags_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etiket',
    );
    return '$_temp0';
  }

  @override
  String tags_usage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count işlem',
      zero: 'Henüz kullanılmadı',
    );
    return '$_temp0';
  }

  @override
  String get tags_spent => 'Harcanan';

  @override
  String get tags_earned => 'Kazanılan';

  @override
  String get tags_net => 'Net';

  @override
  String tags_not_included(String codes) {
    return '$codes dahil değil';
  }

  @override
  String get tags_graph_hint =>
      'Büyük daireler daha çok para hareketi demek. Çizgiler birlikte kullanılan etiketleri bağlar.';

  @override
  String get tags_graph_empty =>
      'Haritayı görmek için birkaç işleme etiket ekle.';

  @override
  String get tag_wallets => 'Cüzdanlar';

  @override
  String get tag_transactions => 'İşlemler';

  @override
  String get tag_no_transactions => 'Bu etiketin olduğu işlem yok';

  @override
  String get tag_rename => 'Etiketi yeniden adlandır';

  @override
  String get tag_name_placeholder => 'Etiket adı';

  @override
  String get tag_delete => 'Etiketi sil';

  @override
  String tag_delete_title(String name) {
    return '#$name silinsin mi?';
  }

  @override
  String get tag_delete_message =>
      'Her işlemden kaldırılacak. İşlemlerin kendisi kalır.';

  @override
  String get tag_deleted => 'Etiket silindi';

  @override
  String get tag_renamed => 'Etiket yeniden adlandırıldı';

  @override
  String tag_merged(String name) {
    return '#$name etiketiyle birleştirildi';
  }

  @override
  String get tag_not_found => 'Bu etiket artık yok';

  @override
  String get tag_wallet_deleted => '(silindi)';

  @override
  String get l10nSubscriptions =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SUBSCRIPTIONS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get subscriptions_title => 'Abonelikler';

  @override
  String subscriptions_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Abonelik',
      zero: 'Abonelik yok',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_empty_title => 'Henüz abonelik yok';

  @override
  String get subscriptions_empty_subtitle =>
      'Bir işlemde Tekrar\'ı ayarla, burada görünsün.';

  @override
  String get subscriptions_all_wallets => 'Tüm cüzdanlar';

  @override
  String get subscriptions_active => 'Aktif';

  @override
  String get subscriptions_paused => 'Duraklatıldı';

  @override
  String subscriptions_monthly_total(String amount) {
    return '≈ $amount / ay';
  }

  @override
  String get subscriptions_edit_title => 'Aboneliği düzenle';

  @override
  String get subscriptions_amount => 'Tutar';

  @override
  String get subscriptions_wallet => 'Cüzdan';

  @override
  String get subscriptions_from_wallet => 'Kaynak cüzdan';

  @override
  String get subscriptions_to_wallet => 'Hedef cüzdan';

  @override
  String get subscriptions_frequency => 'Sıklık';

  @override
  String get subscriptions_description => 'Açıklama';

  @override
  String get subscriptions_tags => 'Etiketler';

  @override
  String get subscriptions_pause => 'Duraklat';

  @override
  String get subscriptions_resume => 'Devam et';

  @override
  String get subscriptions_stop => 'Aboneliği durdur';

  @override
  String get subscriptions_saved => 'Abonelik güncellendi';

  @override
  String get subscriptions_stopped => 'Abonelik durduruldu';

  @override
  String get subscriptions_type_hint => 'Bir aboneliğin türü değiştirilemez.';

  @override
  String get l10nCurrency =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ CURRENCY ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get currency_pick_title => 'Para Birimi';

  @override
  String get currency_no_results => 'Para birimi bulunamadı';

  @override
  String get currency_base_title => 'Ana para birimi';

  @override
  String get currency_base_hint => 'Toplam bakiyen bu para birimine çevrilir.';

  @override
  String get l10nSettings =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ SETTINGS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_preferences => 'Tercihler';

  @override
  String get settings_notifications => 'Bildirimler';

  @override
  String get settings_currency => 'Para Birimi';

  @override
  String get settings_dark_mode => 'Koyu Tema';

  @override
  String get settings_show_mascot => 'Maskotu göster';

  @override
  String get settings_data_privacy => 'Veri ve Gizlilik';

  @override
  String get settings_export_transactions => 'İşlemleri Dışa Aktar';

  @override
  String get settings_reset_all_data => 'Tüm Verileri Sıfırla';

  @override
  String get settings_reset_title => 'Tüm veriler sıfırlansın mı?';

  @override
  String get settings_reset_message =>
      'Bu cihazdaki her cüzdan, işlem ve ayar silinecek. Bu geri alınamaz.';

  @override
  String get settings_reset_action => 'Sıfırla';

  @override
  String get settings_reset_done => 'Tüm veriler silindi';

  @override
  String settings_version(String version, String build) {
    return 'Sürüm: $version ($build)';
  }

  @override
  String get settings_language => 'Dil';

  @override
  String get settings_manage => 'Yönet';

  @override
  String get settings_tags => 'Etiketler';

  @override
  String get settings_subscriptions => 'Abonelikler';

  @override
  String get settings_language_info =>
      'Uygulama arayüzü için tercih ettiğin dili seç.';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_theme_system => 'Sistem';

  @override
  String get settings_theme_light => 'Açık';

  @override
  String get settings_theme_dark => 'Koyu';

  @override
  String get l10nAbout =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ABOUT ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get about => 'Wumbi Hakkında';

  @override
  String get about_project => 'Proje Hakkında';

  @override
  String get about_text =>
      'Wumbi minimalist, yerel öncelikli bir bütçe uygulamasıdır. Verilerin şifrelenir ve cihazından asla çıkmaz.';

  @override
  String get about_support => 'Desteğe ulaş';

  @override
  String get l10nValidation =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ VALIDATION ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get validation_enter_amount => 'Bir tutar gir';

  @override
  String validation_up_to_tags(int count) {
    return 'En fazla $count etiket';
  }

  @override
  String get validation_rate_unavailable => 'Kur yok';

  @override
  String get l10nErrors =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ ERRORS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get error_db_failure => 'Veritabanı hatası, tekrar dene.';

  @override
  String get error_unknown => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get error_rate_unavailable =>
      'Döviz kuru yok. İnternete bağlan ve tekrar dene.';

  @override
  String get error_validation => 'Lütfen girdiğin değerleri kontrol et.';

  @override
  String get error_wallet_has_transactions =>
      'Bir cüzdanda işlem varsa para birimi değiştirilemez.';

  @override
  String get error_not_found => 'Bu öğe artık yok.';

  @override
  String get error_tag_name => 'Bir etiket adı gir (en fazla 30 karakter).';

  @override
  String get error_open_db_title => 'Verilerin açılamadı';

  @override
  String get error_open_db_message =>
      'Wumbi bu cihazdaki veritabanının kilidini açamadı.';

  @override
  String get error_reset_app => 'Uygulamayı sıfırla';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
