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
  String get wallet_tab_transactions => 'İşlemler';

  @override
  String get wallet_tab_budgets => 'Bütçeler';

  @override
  String get wallet_tab_subscriptions => 'Abonelikler';

  @override
  String get wallet_budgets_empty => 'Bu cüzdan için henüz harcama limiti yok';

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
  String get transaction_edit_title => 'İşlemi düzenle';

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
  String get tags_new => 'Yeni etiket';

  @override
  String get tags_create => 'Etiket oluştur';

  @override
  String tags_created(String name) {
    return '#$name oluşturuldu';
  }

  @override
  String tags_exists(String name) {
    return '#$name zaten var';
  }

  @override
  String get tags_parent => 'Üst etiket';

  @override
  String get tags_parent_none => 'Yok';

  @override
  String get tags_name_hint => 'ör. kahve';

  @override
  String get tags_create_tip =>
      'İpucu: bir etiketi hemen iç içe koymak için yemek/kahve yazın.';

  @override
  String tags_nested_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alt',
    );
    return '$_temp0';
  }

  @override
  String get tags_help => 'Etiketler nasıl kullanılır?';

  @override
  String get tags_graph_mode_all => 'Tümü';

  @override
  String get tags_graph_mode_spending => 'Harcama';

  @override
  String get tags_graph_mode_income => 'Gelir';

  @override
  String get tags_graph_legend_size => 'Büyük = daha çok para';

  @override
  String get tags_graph_legend_nested => 'Alt etiket';

  @override
  String get tags_graph_legend_together => 'Birlikte kullanılan';

  @override
  String get tags_graph_tap_hint => 'Rakamları görmek için bir daireye dokunun';

  @override
  String get tags_graph_open => 'Aç';

  @override
  String tags_graph_linked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count etikete bağlı',
      zero: 'Henüz bağlantı yok',
    );
    return '$_temp0';
  }

  @override
  String get tag_move => 'Taşı';

  @override
  String tag_move_title(String name) {
    return '#$name etiketini taşı';
  }

  @override
  String get tag_moved => 'Etiket taşındı';

  @override
  String get tag_add_nested => 'Alt etiket ekle';

  @override
  String get tag_nested_tags => 'Alt etiketler';

  @override
  String tag_includes_nested(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alt etiket içerir',
    );
    return '$_temp0';
  }

  @override
  String tag_delete_nested_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Bu etiket ve $count alt etiketi tüm işlemlerden kaldırılacak. İşlemlerin kendisi kalır.',
    );
    return '$_temp0';
  }

  @override
  String get tag_rename_nested_hint =>
      'Alt etiketler de yeniden adlandırılır. Başka bir etiketin altına taşımak için / kullanın.';

  @override
  String get tag_top_level => 'En üst düzey';

  @override
  String get tag_nested_empty => 'Henüz alt etiket yok';

  @override
  String get settings_help => 'Yardım mı lazım?';

  @override
  String get help_title => 'Yardım mı lazım?';

  @override
  String get help_subtitle =>
      'Wumbi\'den en iyi şekilde yararlanmak için kısa rehberler.';

  @override
  String get help_tags_title => 'Etiketler nasıl kullanılır?';

  @override
  String get help_tags_subtitle => 'Etiketler, alt etiketler ve harita';

  @override
  String get help_tags_intro =>
      'Etiketler, işlemlerinize eklediğiniz #kahve gibi kısa adlardır. Bir işlemde birden çok etiket olabilir; böylece paranıza yalnızca cüzdan bazında değil, her açıdan bakabilirsiniz.';

  @override
  String get help_tags_add_title => 'Etiket ekleme';

  @override
  String get help_tags_add_body =>
      'Bir işlem girerken etiket alanına bir ad yazın, ardından bir öneri seçin ya da yenisini oluşturun. Etiketlerde boşluk olmaz — coffee-shop veya coffee_shop yazın. Büyük ve küçük harf aynı etiketi verir.';

  @override
  String get help_tags_nested_title => 'Alt etiketler';

  @override
  String get help_tags_nested_body =>
      'Bir etiketi klasör gibi başka birinin içine koymak için eğik çizgi / kullanın: yemek/kahve ve yemek/market ikisi de yemek içindedir. Üst etiket sizin için oluşturulur.';

  @override
  String get help_tags_parent_title => 'Üst etiket, alt etiketlerini kapsar';

  @override
  String get help_tags_parent_body =>
      '#yemek açıldığında #yemek, #yemek/kahve veya #yemek/market etiketli tüm işlemler görünür. Bir üst etiketin toplamları, filtreleri ve bütçeleri alt etiketlerini de sayar. İki etiketi birden taşıyan bir işlem yalnızca bir kez sayılır.';

  @override
  String get help_tags_multi_title => 'Bir işlemde birden çok etiket';

  @override
  String get help_tags_multi_body =>
      'Tatildeki bir akşam yemeği aynı anda hem #seyahat hem #yemek/restoran olabilir. O zaman ikisinde de sayılır ve iki etiket haritada birbirine bağlanır.';

  @override
  String get help_tags_manage_title => 'Oluştur, yeniden adlandır, taşı';

  @override
  String get help_tags_manage_body =>
      'Etiketler sayfasında etiket oluşturmak için + simgesine dokunun ve iç içe koymak için bir üst etiket seçin. Bir etiketi açarak yeniden adlandırabilir, başka bir üst etiketin altına taşıyabilir, alt etiket ekleyebilir veya silebilirsiniz. Üst etiketi yeniden adlandırmak alt etiketlerini de yeniden adlandırır; var olan bir etiketin adını vermek ikisini birleştirir.';

  @override
  String get help_tags_map_title => 'Haritayı okuma';

  @override
  String get help_tags_map_body =>
      'Her daire bir etikettir: ne kadar büyükse o kadar çok para hareket etmiştir. Halkası harcama ve gelirin payını gösterir. Düz çizgiler üst etiketi alt etiketlerine, soluk çizgiler aynı işlemde kullanılan etiketleri birbirine bağlar. Rakamları görmek için bir daireye dokunun.';

  @override
  String get help_tags_tips_title => 'İpuçları';

  @override
  String get help_tags_tip1 =>
      'Geniş başlayın — yemek, ev, ulaşım — ve yalnızca daha fazla ayrıntı istediğinizde iç içe koyun.';

  @override
  String get help_tags_tip2 =>
      'Cüzdanlar arasında kesişen şeyler için etiket kullanın: #tatil, #hediyeler, #araba.';

  @override
  String get help_tags_tip3 =>
      'Adları kısa tutun; iki ya da üç düzey yeterlidir.';

  @override
  String get help_tags_example => 'Örnek';

  @override
  String get help_tags_example_total => '#yemek toplamı';

  @override
  String get help_tags_ex_parent => 'yemek';

  @override
  String get help_tags_ex_child1 => 'kahve';

  @override
  String get help_tags_ex_child2 => 'market';

  @override
  String get help_tags_ex_travel => 'seyahat';

  @override
  String get help_tags_ex_restaurant => 'restoran';

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
  String get l10nProgress =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠ PROGRESS ☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠☠';

  @override
  String get progress_title => 'İlerleme';

  @override
  String get progress_by_day => 'Gün gün';

  @override
  String get progress_by_month => 'Ay ay';

  @override
  String get progress_other => 'Diğer';

  @override
  String get progress_month => 'Ay';

  @override
  String get progress_year => 'Yıl';

  @override
  String get progress_income => 'Gelir';

  @override
  String get progress_all_wallets => 'Tüm cüzdanlar';

  @override
  String get progress_scope_title => 'Verileri göster';

  @override
  String progress_not_included(String codes) {
    return '$codes dahil değil';
  }

  @override
  String get progress_empty_title => 'Henüz analiz edilecek bir şey yok';

  @override
  String get progress_untagged => 'Etiketsiz';

  @override
  String get progress_no_expenses => 'Bu dönemde gider yok';

  @override
  String get progress_empty_subtitle =>
      'Birkaç işlem ekleyin, ilerlemeniz burada görünsün.';

  @override
  String get progress_spent => 'Harcanan';

  @override
  String get progress_spending => 'Harcamalar';

  @override
  String get progress_saved => 'Biriken';

  @override
  String get progress_overspent => 'Aşım';

  @override
  String progress_vs(String label) {
    return '$label ile';
  }

  @override
  String progress_kept_share(int percent) {
    return 'Gelirinizin %$percent kadarını biriktirdiniz';
  }

  @override
  String progress_overspent_by(String amount) {
    return 'Kazandığınızdan $amount fazla harcadınız';
  }

  @override
  String progress_nothing_in(String period) {
    return '$period döneminde işlem yok';
  }

  @override
  String get progress_compare_title => 'Karşılaştır';

  @override
  String get progress_baseline_previous_month => 'Önceki ay';

  @override
  String get progress_baseline_previous_year => 'Önceki yıl';

  @override
  String get progress_baseline_last_year => 'Geçen yılın aynı ayı';

  @override
  String progress_baseline_average_months(int count) {
    return 'Son $count ayın ortalaması';
  }

  @override
  String progress_baseline_average_years(int count) {
    return 'Son $count yılın ortalaması';
  }

  @override
  String get progress_baseline_pick_month => 'Bir ay seçin';

  @override
  String get progress_baseline_pick_year => 'Bir yıl seçin';

  @override
  String progress_average_months(int count) {
    return '$count aylık ortalama';
  }

  @override
  String progress_average_years(int count) {
    return '$count yıllık ortalama';
  }

  @override
  String get progress_pace_title => 'Harcama temposu';

  @override
  String progress_pace_less(String amount, String baseline) {
    return 'Şu ana kadar $baseline dönemine göre $amount daha az';
  }

  @override
  String progress_pace_more(String amount, String baseline) {
    return 'Şu ana kadar $baseline dönemine göre $amount daha fazla';
  }

  @override
  String progress_pace_same(String baseline) {
    return '$baseline ile aynı tempo';
  }

  @override
  String progress_total_less(String amount, String baseline) {
    return '$baseline dönemine göre $amount daha az';
  }

  @override
  String progress_total_more(String amount, String baseline) {
    return '$baseline dönemine göre $amount daha fazla';
  }

  @override
  String progress_total_same(String baseline) {
    return '$baseline ile hemen hemen aynı';
  }

  @override
  String progress_forecast_month(String amount) {
    return 'Bu tempoyla ay sonunda ≈ $amount';
  }

  @override
  String progress_forecast_year(String amount) {
    return 'Bu tempoyla yıl sonunda ≈ $amount';
  }

  @override
  String progress_day(int day) {
    return '$day. gün';
  }

  @override
  String get progress_changes_title => 'Neler değişti';

  @override
  String progress_now_was(String now, String was) {
    return 'şimdi $now · önce $was';
  }

  @override
  String get progress_new => 'Yeni';

  @override
  String get progress_breakdown_title => 'Etikete göre';

  @override
  String get progress_no_income => 'Bu dönemde gelir yok';

  @override
  String progress_show_all(int count) {
    return 'Tümünü göster ($count)';
  }

  @override
  String get progress_show_less => 'Daha az göster';

  @override
  String get progress_overlap_hint =>
      'Birden fazla gruptan etiket taşıyan bir işlem her grupta sayılır.';

  @override
  String get progress_habits_title => 'Alışkanlıklar';

  @override
  String get progress_daily_average => 'Günlük ortalama';

  @override
  String get progress_biggest_expense => 'En büyük harcama';

  @override
  String get progress_recurring => 'Düzenli ödemeler';

  @override
  String progress_recurring_share(int percent) {
    return 'Harcamalarınızın %$percent kadarı';
  }

  @override
  String get progress_average_expense => 'Ortalama harcama';

  @override
  String progress_peak_weekday(String weekday) {
    return 'En çok harcadığınız gün: $weekday';
  }

  @override
  String get progress_weekday_hint =>
      'Haftanın günlerine göre ortalama harcama';

  @override
  String progress_history_months(int count) {
    return 'Son $count ay';
  }

  @override
  String progress_history_years(int count) {
    return 'Son $count yıl';
  }

  @override
  String progress_average_per_month(String amount) {
    return 'Ayda ortalama $amount';
  }

  @override
  String progress_average_per_year(String amount) {
    return 'Yılda ortalama $amount';
  }

  @override
  String progress_to_date_hint(String baseline) {
    return '$baseline döneminin aynı günleriyle karşılaştırıldı';
  }

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
      'Wumbi paranı telefonunda tutar. Tutarı yaz, Gelir ya da Gider\'e dokun, bitti. Hesap gerekmiyor ve sen açmadıkça hiçbir şey yüklenmiyor.';

  @override
  String get about_support => 'Desteğe ulaş';

  @override
  String get about_read_more => 'Devamını wumbi.app\'te oku';

  @override
  String get settings_about_section => 'Hakkında';

  @override
  String get settings_privacy_policy => 'Gizlilik Politikası';

  @override
  String get settings_terms => 'Kullanım Koşulları';

  @override
  String get settings_press => 'Basın Kiti';

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
  String debt_error_owes_you_only(String name, String amount) {
    return '$name size yalnızca $amount borçlu';
  }

  @override
  String debt_error_you_owe_only(String name, String amount) {
    return '$name kişisine yalnızca $amount borçlusunuz';
  }

  @override
  String get person_error_has_debts =>
      'Önce bu kişinin borçlarını kapatın veya silin.';

  @override
  String get debt_error_closed => 'Bu borç zaten kapatıldı.';

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
  String get dashboard_budgets => 'Bütçeler';

  @override
  String get budget_new => 'Yeni bütçe';

  @override
  String get budget_empty_hint =>
      'Bir cüzdan veya #etiket için harcama limiti belirleyin';

  @override
  String get budgets_all => 'Tüm bütçeler';

  @override
  String get budgets_title => 'Bütçeler';

  @override
  String budget_left(String amount) {
    return '$amount kaldı';
  }

  @override
  String budget_over(String amount) {
    return '$amount aşıldı';
  }

  @override
  String budget_starts(String date) {
    return '$date tarihinde başlar';
  }

  @override
  String get budget_ended => 'Bitti';

  @override
  String budget_per_day(String amount) {
    return '$amount/gün';
  }

  @override
  String budget_spent_of(String spent, String limit) {
    return '$limit bütçenin $spent kadarı harcandı';
  }

  @override
  String get budget_this_week => 'Bu hafta';

  @override
  String get budget_set_limit => 'Harcama limiti belirle';

  @override
  String budget_toast_suffix(String name, String amount) {
    return '$name: $amount kaldı';
  }

  @override
  String budget_toast_suffix_over(String name, String amount) {
    return '$name: $amount aşıldı';
  }

  @override
  String get budget_all_spending => 'Tüm harcamalar';

  @override
  String get budget_name => 'Ad';

  @override
  String get budget_name_placeholder => 'ad';

  @override
  String budget_name_hint(String name) {
    return 'Bütçe adı: $name';
  }

  @override
  String get budget_what_counts => 'Neler sayılır';

  @override
  String get budget_wallets => 'Cüzdanlar';

  @override
  String get budget_all_wallets => 'Tüm cüzdanlar';

  @override
  String get budget_tags => 'Etiketler';

  @override
  String get budget_any_tag => 'Herhangi bir etiket';

  @override
  String get budget_scope_all => 'Tüm harcamaları sayar.';

  @override
  String budget_scope_wallets(String wallets) {
    return '$wallets cüzdanındaki harcamaları sayar.';
  }

  @override
  String budget_scope_tags(String tags) {
    return '$tags etiketli harcamaları sayar.';
  }

  @override
  String budget_scope_both(String wallets, String tags) {
    return '$wallets cüzdanındaki $tags etiketli harcamaları sayar.';
  }

  @override
  String get budget_scope_or => 'veya';

  @override
  String get budget_period_section => 'Dönem';

  @override
  String get budget_repeats => 'Tekrar';

  @override
  String get budget_period_weekly => 'Haftalık';

  @override
  String get budget_period_monthly => 'Aylık';

  @override
  String get budget_period_yearly => 'Yıllık';

  @override
  String get budget_period_custom => 'Tek seferlik';

  @override
  String get budget_starts_on => 'Başlangıç';

  @override
  String get budget_first_day => 'İlk gün';

  @override
  String get budget_last_day => 'Son gün';

  @override
  String budget_day_of_month(int day) {
    return 'Ayın $day. günü';
  }

  @override
  String get budget_start_day_title => 'Başlangıç günü';

  @override
  String get budget_start_day_hint => 'Kısa aylarda son günde başlar.';

  @override
  String get budget_start_weekday_title => 'Haftanın ilk günü';

  @override
  String get budget_carry_over => 'Devretme';

  @override
  String get budget_rollover_none => 'Devretme';

  @override
  String get budget_rollover_surplus => 'Kalanı devret';

  @override
  String get budget_rollover_both => 'Kalanı ve aşımı devret';

  @override
  String get budget_count_planned => 'Planlananı say';

  @override
  String get budget_count_planned_hint => 'Yaklaşanlar ve abonelikler dahil';

  @override
  String get budget_count_planned_desc =>
      'Yaklaşan ödemeler ve abonelikler, ödenmeden önce limitten düşer.';

  @override
  String budget_suggested_months(String amount) {
    return 'Öneri: $amount · son 3 ay ort.';
  }

  @override
  String budget_suggested_weeks(String amount) {
    return 'Öneri: $amount · son 3 hafta ort.';
  }

  @override
  String budget_suggested_years(String amount) {
    return 'Öneri: $amount · son 3 yıl ort.';
  }

  @override
  String get budget_deleted => 'Bütçe silindi';

  @override
  String budget_delete_title(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get budget_delete_message => 'İşlemleriniz olduğu gibi kalır.';

  @override
  String get budget_error_name => 'Ad en fazla 40 karakter';

  @override
  String get budget_error_dates => 'Son gün ilk günden sonra olmalı';

  @override
  String get budget_left_caption => 'kaldı';

  @override
  String get budget_over_caption => 'aşıldı';

  @override
  String get budget_under_caption => 'altında';

  @override
  String budget_spent(String amount) {
    return 'Harcanan $amount';
  }

  @override
  String budget_planned(String amount) {
    return 'Planlanan $amount';
  }

  @override
  String budget_limit(String amount) {
    return 'Limit $amount';
  }

  @override
  String budget_carried(String amount) {
    return '$amount devredildi';
  }

  @override
  String get budget_on_track => 'Planlandığı gibi';

  @override
  String budget_ahead_of_pace(String amount) {
    return 'plandan $amount geride';
  }

  @override
  String budget_faster_than_planned(String amount) {
    return 'plandan $amount hızlı';
  }

  @override
  String budget_forecast(String amount) {
    return 'tahmin $amount';
  }

  @override
  String get budget_no_spending => 'Bu dönemde henüz harcama yok';

  @override
  String get budgets_active => 'Etkin';

  @override
  String get budgets_upcoming => 'Yaklaşan';

  @override
  String get budgets_empty_title => 'Henüz bütçe yok';

  @override
  String get budgets_empty_subtitle =>
      'Bir limit belirleyin, kalanı takip edin';

  @override
  String budgets_more_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count bütçe daha',
    );
    return '$_temp0';
  }

  @override
  String budget_per_day_for(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
    );
    return '$_temp0 boyunca $amount/gün';
  }

  @override
  String budget_subscriptions_planned(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonelik',
    );
    return '$_temp0 · $amount';
  }

  @override
  String budgets_finished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Biten ($count)',
    );
    return '$_temp0';
  }

  @override
  String wallet_deleted_removed_budgets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bütçe kaldırıldı',
    );
    return '$_temp0';
  }

  @override
  String get debts_title => 'Borçlar';

  @override
  String get debts_owed_to_me => 'Bana borçlu';

  @override
  String get debts_i_owe => 'Borcum';

  @override
  String get debts_empty_owed_title => 'Kimse size borçlu değil';

  @override
  String get debts_empty_owe_title => 'Kimseye borcunuz yok';

  @override
  String get debts_empty_subtitle =>
      '“Yeni borç”a dokunun veya işlem ekranında Transfer → Borçlar’ı kullanın';

  @override
  String get debt_new => 'Yeni borç';

  @override
  String get debt_edit_title => 'Borcu düzenle';

  @override
  String get debts_all => 'Tüm borçlar';

  @override
  String get debts_empty_hint => 'Verdiğin ve aldığın borçları takip et';

  @override
  String get dashboard_reorder_hint => 'Sıralamak için basılı tut';

  @override
  String dashboard_debts_to_receive(String amount) {
    return 'alacak $amount';
  }

  @override
  String dashboard_debts_to_pay(String amount) {
    return 'borç $amount';
  }

  @override
  String get dashboard_new => 'Yeni';

  @override
  String get debt_they_owe_me => 'Bana borçlu';

  @override
  String get debt_i_owe_them => 'Ben borçluyum';

  @override
  String get debt_person => 'Kim';

  @override
  String get debt_person_chip => 'Kim';

  @override
  String get debt_person_title => 'Kiminle?';

  @override
  String get debt_person_search => 'Ad — kişi, banka, mağaza…';

  @override
  String get debt_person_empty => 'Henüz kimse yok — bir ad yazın';

  @override
  String get debt_person_none => 'Kimse';

  @override
  String get debt_choose => 'Seç';

  @override
  String get debt_amount => 'Tutar';

  @override
  String get debt_note_hint => 'Not (isteğe bağlı)';

  @override
  String get debt_note_placeholder => 'not';

  @override
  String get debt_due_date => 'Vade';

  @override
  String get debt_due_title => 'Vade';

  @override
  String get debt_add_due => 'Vade';

  @override
  String get debt_due_change => 'Tarihi değiştir';

  @override
  String get debt_due_remove => 'Vadeyi kaldır';

  @override
  String get debt_none => 'Yok';

  @override
  String get debt_money_moved => 'Para hareketi';

  @override
  String get debt_not_in_wallet => 'Cüzdan dışında';

  @override
  String get debt_error_person => 'Kiminle olduğunu seçin';

  @override
  String get debt_gave => 'Verdim';

  @override
  String get debt_got => 'Aldım';

  @override
  String get debt_badge_loan => 'Borç';

  @override
  String get debt_badge_return => 'İade';

  @override
  String get debt_overdue => 'gecikmiş';

  @override
  String get debt_settled_label => 'Kapandı';

  @override
  String get debt_forgiven_label => 'Affedildi';

  @override
  String get debt_returned_in_full => 'Tamamı iade edildi';

  @override
  String get debt_paid_in_full => 'Tamamı ödendi';

  @override
  String get debt_part => 'Kısmi';

  @override
  String get debt_forgive => 'Affet';

  @override
  String get debt_remind => 'Hatırlat';

  @override
  String get debt_history => 'Geçmiş';

  @override
  String get debt_edit_note => 'Notu düzenle';

  @override
  String get debt_rename_person => 'Yeniden adlandır';

  @override
  String get debt_delete => 'Borcu sil';

  @override
  String get debt_delete_title => 'Bu borç silinsin mi?';

  @override
  String get debt_deleted => 'Borç silindi';

  @override
  String get debt_payment_deleted => 'Ödeme silindi';

  @override
  String get debt_return_deleted => 'İade silindi';

  @override
  String debt_due(String date) {
    return 'vade $date';
  }

  @override
  String debt_left(String amount) {
    return '$amount kaldı';
  }

  @override
  String debt_left_of(String amount) {
    return '$amount içinden kalan';
  }

  @override
  String debt_of(String amount) {
    return '$amount içinden';
  }

  @override
  String debt_to_wallet(String wallet) {
    return '$wallet cüzdanına';
  }

  @override
  String debt_from_wallet(String wallet) {
    return '$wallet cüzdanından';
  }

  @override
  String debt_owes_you(String name, String amount) {
    return '$name size $amount borçlu';
  }

  @override
  String debt_you_owe(String name, String amount) {
    return '$name kişisine $amount borçlusunuz';
  }

  @override
  String debt_overall(String text) {
    return 'Toplamda: $text';
  }

  @override
  String debt_overall_both(String name, String owed, String owe) {
    return 'Toplamda: $name size $owed borçlu · siz $owe borçlusunuz';
  }

  @override
  String debt_hint_owes_you(String name, String amount) {
    return '$name size $amount borçlu · \"Aldım\" iade sayılır';
  }

  @override
  String debt_hint_you_owe(String name, String amount) {
    return '$name kişisine $amount borçlusunuz · \"Verdim\" geri ödeme sayılır';
  }

  @override
  String debt_hint_both(String name, String owed, String owe) {
    return '$name size $owed borçlu · siz $owe borçlusunuz';
  }

  @override
  String debt_hint_none(String name) {
    return '$name ile açık borç yok · \"Verdim\" borç verir, \"Aldım\" borç alır';
  }

  @override
  String debt_person_add(String name) {
    return '\"$name\" ekle';
  }

  @override
  String debt_picker_owes_you(String amount) {
    return 'size $amount borçlu';
  }

  @override
  String debt_picker_you_owe(String amount) {
    return 'siz $amount borçlusunuz';
  }

  @override
  String debt_title_lent_to(String name) {
    return '$name kişisine borç verildi';
  }

  @override
  String debt_title_borrowed_from(String name) {
    return '$name kişisinden borç alındı';
  }

  @override
  String debt_title_paid_back_by(String name) {
    return '$name geri ödedi';
  }

  @override
  String debt_title_paid_back_to(String name) {
    return '$name kişisine geri ödendi';
  }

  @override
  String debt_toast_lent(String amount, String name) {
    return '$name kişisine $amount borç verildi';
  }

  @override
  String debt_toast_borrowed(String amount, String name) {
    return '$name kişisinden $amount borç alındı';
  }

  @override
  String debt_toast_returned(String name, String amount, String left) {
    return '$name $amount geri ödedi · $left kaldı';
  }

  @override
  String debt_toast_returned_settled(String name, String amount) {
    return '$name $amount geri ödedi · hepsi kapandı';
  }

  @override
  String debt_toast_paid_back(String amount, String name, String left) {
    return '$name kişisine $amount geri ödendi · $left kaldı';
  }

  @override
  String debt_toast_paid_back_settled(String amount, String name) {
    return '$name kişisine $amount geri ödendi · hepsi kapandı';
  }

  @override
  String debt_forgive_title(String name) {
    return '$name affedilsin mi?';
  }

  @override
  String debt_forgive_message(String amount) {
    return 'Kalan $amount silinecek. Para hareketi olmaz.';
  }

  @override
  String debt_forgiven_toast(String name) {
    return 'Borç affedildi · $name';
  }

  @override
  String debt_remind_message(
    String name,
    String amount,
    String note,
    String date,
  ) {
    return 'Merhaba $name! $note için $amount ($date) hatırlatması. Teşekkürler!';
  }

  @override
  String debt_remind_message_no_note(String name, String amount, String date) {
    return 'Merhaba $name! $amount ($date) hatırlatması. Teşekkürler!';
  }

  @override
  String debt_history_lent(String amount) {
    return '$amount borç verildi';
  }

  @override
  String debt_history_lent_from(String amount, String wallet) {
    return '$wallet cüzdanından $amount borç verildi';
  }

  @override
  String debt_history_borrowed(String amount) {
    return '$amount borç alındı';
  }

  @override
  String debt_history_borrowed_into(String amount, String wallet) {
    return '$wallet cüzdanına $amount borç alındı';
  }

  @override
  String debt_history_returned(String amount) {
    return '$amount iade edildi';
  }

  @override
  String debt_history_returned_to(String amount, String wallet) {
    return '$amount iade → $wallet';
  }

  @override
  String debt_history_paid(String amount) {
    return '$amount geri ödendi';
  }

  @override
  String debt_history_paid_from(String amount, String wallet) {
    return '$wallet cüzdanından $amount geri ödendi';
  }

  @override
  String debt_history_forgiven(String amount) {
    return '$amount affedildi';
  }

  @override
  String debts_overdue_count(int count) {
    return '$count gecikmiş';
  }

  @override
  String debts_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count borç',
    );
    return '$_temp0';
  }

  @override
  String debts_people_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişi',
      zero: 'Kimse',
    );
    return '$_temp0';
  }

  @override
  String debts_settled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kapananlar ($count)',
    );
    return '$_temp0';
  }

  @override
  String debt_cascade_deleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Borç $count iadeyle birlikte silindi',
      zero: 'Borç silindi',
    );
    return '$_temp0';
  }

  @override
  String debt_delete_message(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cüzdan işlemi de silinecek.',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_new => 'Yeni Abonelik';

  @override
  String subscriptions_active_count(int count) {
    return '$count aktif';
  }

  @override
  String subscriptions_paused_count(int count) {
    return '$count duraklatıldı';
  }

  @override
  String get wallet_budgets_empty_subtitle =>
      'Bu cüzdanı kontrol altında tutmak için bir harcama limiti belirle.';

  @override
  String get wallet_include_in_total => 'Toplam bakiyeye dahil et';

  @override
  String get wallet_include_in_total_on =>
      'Bu cüzdanın bakiyesi ana ekrandaki toplama eklenir.';

  @override
  String get wallet_include_in_total_off =>
      'Ana ekrandaki toplama dahil değil — birikim, ortak veya yalnızca takip cüzdanları için kullanışlı.';

  @override
  String get dashboard_wallets_not_counted => 'Toplam bakiyeye dahil değil';

  @override
  String dashboard_wallets_excluded(int count) {
    return '$count hariç';
  }

  @override
  String get budget_rollover_none_desc =>
      'Her dönem aynı limitle sıfırdan başlar. Kalan ve aşım devredilmez.';

  @override
  String get budget_rollover_surplus_desc =>
      'Harcamadığın tutar bir sonraki dönemin limitine eklenir.';

  @override
  String get budget_rollover_both_desc =>
      'Kalan bir sonraki limiti artırır, aşım ise düşürür.';

  @override
  String get budget_planned_title => 'Planlanan ödemeler';

  @override
  String get budget_planned_exclude => 'Planlananı sayma';

  @override
  String get budget_planned_exclude_desc =>
      'Limitten yalnızca yapılmış ödemeler düşer. Yaklaşan ödemeler ve abonelikler ödendiğinde düşer.';

  @override
  String budget_used_percent(int percent) {
    return '%$percent kullanıldı';
  }

  @override
  String get budget_stat_spent => 'Harcanan';

  @override
  String get budget_stat_limit => 'Limit';

  @override
  String get budget_stat_planned => 'Planlanan';

  @override
  String get budget_stat_per_day => 'Günlük';

  @override
  String get budget_stat_forecast => 'Tahmin';

  @override
  String budget_days_left(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String get subscriptions_monthly_spend => 'Aylık harcama';

  @override
  String get subscriptions_active_empty => 'Aktif abonelik yok';

  @override
  String get subscriptions_paused_empty => 'Duraklatılmış abonelik yok';

  @override
  String budgets_summary_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bütçeyi aştın',
      one: '1 bütçeyi aştın',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_close(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bütçe limitine yakın',
      one: '1 bütçe limitine yakın',
    );
    return '$_temp0';
  }

  @override
  String budgets_summary_ok(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bütçelerine uyuyorsun',
      one: 'Bütçene uyuyorsun',
    );
    return '$_temp0';
  }

  @override
  String get budget_edit_title => 'Bütçeyi düzenle';

  @override
  String get wallet_edit_title => 'Cüzdanı düzenle';

  @override
  String get budget_tab_overview => 'Genel bakış';

  @override
  String get budget_back_to_current => 'Bugüne dön';

  @override
  String get budget_row_starts => 'Başlangıç';

  @override
  String debt_story_lent_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return '$name, $date tarihinde verdiğiniz $total tutarın $left kısmını hâlâ borçlu.';
  }

  @override
  String debt_story_borrowed_open(
    String name,
    String left,
    String total,
    String date,
  ) {
    return '$date tarihinde ödünç aldığınız $total tutarın $left kısmını $name kişisine hâlâ borçlusunuz.';
  }

  @override
  String debt_story_lent_settled(String name, String total, String date) {
    return '$name, $date tarihinde verdiğiniz $total tutarın tamamını geri ödedi.';
  }

  @override
  String debt_story_borrowed_settled(String name, String total, String date) {
    return '$date tarihinde $name kişisinden aldığınız $total tutarın tamamını geri ödediniz.';
  }

  @override
  String debt_story_forgiven(String total, String date) {
    return '$date tarihinde kapandı — $total tutarın kalanı silindi.';
  }

  @override
  String get debt_stat_lent => 'Verilen';

  @override
  String get debt_stat_borrowed => 'Alınan';

  @override
  String get debt_stat_paid_back => 'Geri ödenen';

  @override
  String get debt_stat_date => 'Tarih';

  @override
  String get debt_stat_due => 'Vade';

  @override
  String get debt_note => 'Not';

  @override
  String get debt_add_note => 'Not ekle';

  @override
  String get debt_got_part_back => 'Bir kısmı geldi';

  @override
  String get debt_paid_part => 'Bir kısmını ödedim';

  @override
  String get debt_section_details => 'Ayrıntılar';

  @override
  String get debts_to_receive => 'Alacak';

  @override
  String get debts_to_pay => 'Borç';

  @override
  String get debts_settled_empty => 'Henüz kapanan borç yok';

  @override
  String get transfer_debt_pay_back => 'Geri öde';

  @override
  String get transfer_debt_lend => 'Borç ver';

  @override
  String get transfer_debt_lend_someone => 'Borç ver…';

  @override
  String transfer_debt_lend_to(String name) {
    return '$name kişisine borç ver';
  }

  @override
  String transfer_debt_only_left(String amount) {
    return 'Yalnızca $amount kaldı';
  }

  @override
  String get transfer_debt_locked =>
      'Borç tekrarlanamaz veya ileri tarihli olamaz';

  @override
  String transfer_debt_summary_repay(
    String wallet,
    String amount,
    String name,
  ) {
    return '$wallet −$amount → $name borcu ödenir';
  }

  @override
  String transfer_debt_summary_lend(String wallet, String amount, String name) {
    return '$wallet −$amount → $name kişisine borç';
  }

  @override
  String get debt_wallet_title_in => 'Para nereye geldi?';

  @override
  String get debt_wallet_title_out => 'Nereden ödediniz?';

  @override
  String debt_wallet_explain_in(String name, String amount) {
    return '$name size $amount geri ödedi. Para hangi cüzdana girdi? Oraya ekleyelim. Takip etmediğiniz nakitse “Cüzdan dışında”yı seçin.';
  }

  @override
  String debt_wallet_explain_out(String name, String amount) {
    return '$name kişisine $amount geri ödüyorsunuz. Para hangi cüzdandan çıkıyor? Oradan düşelim. Takip etmediğiniz nakitle ödediyseniz “Cüzdan dışında”yı seçin.';
  }

  @override
  String get debt_wallet_only_debt => 'Cüzdan değişmez, yalnızca borç';

  @override
  String debt_wallet_confirm_in(String wallet) {
    return '$wallet cüzdanına ekle';
  }

  @override
  String debt_wallet_confirm_out(String wallet) {
    return '$wallet cüzdanından öde';
  }

  @override
  String get debt_wallet_confirm_none => 'Cüzdansız kaydet';

  @override
  String get debt_history_swipe_hint => 'Bir ödemeyi silmek için sola kaydırın';

  @override
  String get debt_form_person => 'Kişi';

  @override
  String get debt_form_wallet => 'Cüzdan';

  @override
  String get menu_open => 'Menüyü aç';

  @override
  String get menu_close => 'Menüyü kapat';

  @override
  String get settings_mascot_talks => 'Wumbi konuşsun';

  @override
  String get mascot_label => 'Hamster Wumbi. Sohbet için dokun';

  @override
  String get mascot_dismiss => 'Wumbi köşesine dönsün';

  @override
  String get mascot_action_view => 'Göster';

  @override
  String get mascot_action_add => 'Ekle';

  @override
  String mascot_month_flow(String month, String income, String expense) {
    return '$month: +$income · −$expense';
  }

  @override
  String get mascot_greeting_morning => 'Günaydın patron!';

  @override
  String get mascot_greeting_afternoon => 'Selam patron!';

  @override
  String get mascot_greeting_evening => 'İyi akşamlar patron!';

  @override
  String get mascot_all_calm => 'Her şey sakin, çekirdekler yerli yerinde';

  @override
  String get mascot_all_for_now => 'Şimdilik bildiğim bu kadar 🙂';

  @override
  String get mascot_quiet_today => 'Anladım patron, bugün sesim çıkmayacak';

  @override
  String mascot_flow_up(String amount, String month) {
    return '$month: zula $amount büyüdü. Böyle devam!';
  }

  @override
  String mascot_flow_down(String amount, String month) {
    return '$month: gidenden $amount fazla çıktı. Telafi ederiz';
  }

  @override
  String mascot_reserve_full(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Yanaklar dolu! $months ay yetecek kadar çekirdek var',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Patron, $name ile olan borcun vadesi $days gün önce geçti',
      one: 'Patron, $name ile olan borcun vadesi dün geçti',
    );
    return '$_temp0';
  }

  @override
  String mascot_debt_overdue_nudge(String name) {
    return '$name ile olan borç hâlâ duruyor patron. Bir bakalım mı?';
  }

  @override
  String mascot_budget_over(String name) {
    return 'Patron, “$name” limiti aştı. Çekirdekler nereye kaçmış bakalım';
  }

  @override
  String mascot_budget_over_by(String name, String amount) {
    return '“$name” $amount aştı. Birlikte bakalım mı patron?';
  }

  @override
  String mascot_budget_near_left(String name, String amount) {
    return 'Bu dönem “$name” içinde sadece $amount kaldı patron';
  }

  @override
  String mascot_budget_near_percent(String name, int percent) {
    return '“$name” şimdiden %$percent oldu. Biraz yavaşlayalım mı?';
  }

  @override
  String mascot_sleep_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Uyuyakalmışım patron… $days gündür kayıt yok. Eksikleri ekleyelim mi?',
    );
    return '$_temp0';
  }

  @override
  String get mascot_sleep_quiet =>
      'Burası çok sessiz. Bir şey yazmayı unutmadın mı patron?';

  @override
  String get mascot_sigh_month =>
      'Patron, bu ay giren çekirdekten çok çıkan var. Sızıntıyı bulalım mı?';

  @override
  String get mascot_sigh_ahead =>
      'Harcamalar geliri geçti. Neyi kısabiliriz birlikte bakalım';

  @override
  String mascot_welcome_back(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Döndün patron! Geçen seferden beri $count yeni kayıt var',
      zero: 'Döndün patron! Sen yokken her yer sessizdi',
    );
    return '$_temp0';
  }

  @override
  String get mascot_evening_waited => 'Patron! Bütün gün seni bekledim!';

  @override
  String get mascot_evening_missed => 'Seni özledim…';

  @override
  String get mascot_evening_log =>
      'Unutmadan bugünün harcamalarını yazalım mı?';

  @override
  String get mascot_evening_count =>
      'Bugünün çekirdeklerini saymama yardım eder misin?';

  @override
  String get mascot_event_reserve =>
      'Patron, üç aylık çekirdeğimiz var! Artık rahat uyuyabiliriz';

  @override
  String mascot_event_best_month(String amount) {
    return 'Son altı ayın en iyi ayı! Zulaya $amount girdi. Seninle gurur duyuyorum patron';
  }

  @override
  String mascot_event_days(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gündür birlikte çekirdek sayıyoruz. Teşekkürler patron!',
    );
    return '$_temp0';
  }

  @override
  String get mascot_event_records =>
      '100. kayıt! İkimiz birlikte sayınca çok daha eğlenceli patron';

  @override
  String mascot_event_streak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days gündür hiç aksatmadın patron! İşte disiplin bu',
    );
    return '$_temp0';
  }

  @override
  String mascot_charge_today(String name, String amount) {
    return 'Patron, bugün $name $amount alacak';
  }

  @override
  String mascot_charge_tomorrow(String name, String amount) {
    return 'Yarın $name $amount alacak patron';
  }

  @override
  String mascot_charge_soon(String name, String amount) {
    return 'Birkaç gün içinde $name $amount alacak';
  }

  @override
  String get mascot_charge_unnamed => 'bir abonelik';

  @override
  String mascot_debt_due_today(String name) {
    return 'Patron, $name ile olan borcun vadesi bugün';
  }

  @override
  String mascot_debt_due_tomorrow(String name) {
    return '$name ile olan borcun vadesi yarın. Unutmayalım mı?';
  }

  @override
  String mascot_debt_due_soon(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$name ile olan borcun vadesine $days gün kaldı',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_mover(String name, int percent) {
    return 'Patron, “$name” geçen aydan %$percent fazla çekirdek yiyor. Bakalım mı?';
  }

  @override
  String mascot_insight_untagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu ay $count harcamanın etiketi yok. Bir düzene sokalım mı?',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_peak_day(String weekday) {
    return 'En aç gözlü günün $weekday patron';
  }

  @override
  String mascot_insight_reserve(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: 'Yanaklar fena değil: yaklaşık $months aylık çekirdek var',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_top_expense(String name, String amount) {
    return 'Bu ayın en büyük lokması: “$name”, $amount';
  }

  @override
  String mascot_insight_top_expense_amount(String amount) {
    return 'Bu ayın en büyük tek lokması: $amount';
  }

  @override
  String mascot_insight_daily_average(String amount) {
    return 'Patron, bu ay günde yaklaşık $amount gidiyor';
  }

  @override
  String mascot_insight_daily_below(int percent) {
    return 'Günde her zamankinden %$percent az çekirdek gidiyor. Aferin patron!';
  }

  @override
  String mascot_insight_daily_above(int percent) {
    return 'Patron, günde her zamankinden %$percent fazla çekirdek gidiyor. Nereye, bakalım mı?';
  }

  @override
  String mascot_insight_weekend(int percent) {
    return 'Hafta sonları çekirdekler hafta içinden %$percent daha hızlı uçuyor';
  }

  @override
  String mascot_insight_frequent_tag(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu ay $count kez “$name”. Alışkanlık mı oluyor patron?',
    );
    return '$_temp0';
  }

  @override
  String mascot_insight_small_spends(String amount) {
    return 'Ufak alışverişler bu ay $amount etti. Çekirdek çekirdek patron';
  }

  @override
  String mascot_insight_savings_rate(int percent) {
    return 'Patron, bu ay gelirin %$percent kadarı zulada kalıyor. Yanaklar mutlu!';
  }

  @override
  String get mascot_insight_no_income =>
      'Bu ay tek çekirdek gelmedi patron. Maaşı yazmayı unutmadın mı?';

  @override
  String mascot_insight_forecast_over(String amount) {
    return 'Böyle giderse bu ay yaklaşık $amount gidecek. Her zamankinden fazla patron';
  }

  @override
  String mascot_insight_forecast_under(String amount) {
    return 'Bu ay hafif geçiyor: yaklaşık $amount. Zula teşekkür ediyor';
  }

  @override
  String mascot_insight_owed_to_me(String amount) {
    return 'Patron, sana $amount borç var. Kibarca hatırlatma zamanı mı?';
  }

  @override
  String mascot_insight_negative_wallet(String name) {
    return '“$name” eksiye düştü patron. Biraz çekirdek aktaralım mı?';
  }

  @override
  String mascot_insight_no_rate(String codes) {
    return '$codes için kur yok, çeviremiyorum. İnternet gelince saymayı bitiririm';
  }

  @override
  String mascot_insight_income_up(int percent) {
    return 'Patron, her zamankinden %$percent fazla çekirdek geldi! Fazlanın yarısını hemen zulaya mı atsak?';
  }

  @override
  String mascot_insight_tag_yearly(String name, String amount) {
    return 'Böyle giderse “$name” yılda yaklaşık $amount yiyecek';
  }

  @override
  String get mascot_insight_no_spend_yesterday =>
      'Dün tek bir harcama yok! Yanaklarım seninle gurur duyuyor patron';

  @override
  String get mascot_tip_budget =>
      'Patron, bütçe çekirdeklerin etrafına küçük bir çit. İlkini kuralım mı?';

  @override
  String get mascot_tip_subscriptions =>
      'Düzenli ödemeler var mı? Bir kez ekle, gerisini ben takip ederim';

  @override
  String mascot_tip_subs_yearly(String amount) {
    return 'Patron, abonelikler yılda $amount yiyor. Kullanmadığın var mı?';
  }

  @override
  String mascot_tip_recurring_share(int percent) {
    return 'Bu ayın harcamalarının %$percent kadarı düzenli ödeme. Benim çark gibi dönüp duruyor';
  }

  @override
  String get mascot_tip_new_month =>
      'Yeni ay patron! Kese tertemiz. Bütçe kuralım mı?';

  @override
  String mascot_tip_monday_recap(String amount) {
    return 'Geçen hafta $amount gitti. Bakalım bu hafta nasıl gideceğiz patron';
  }

  @override
  String mascot_tip_month_end(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Ayın bitmesine $days gün kaldı. Harika gidiyorsun patron',
    );
    return '$_temp0';
  }

  @override
  String get mascot_tip_tags =>
      'Etiketler çekirdeklerin nereye gittiğini görmeme yardım ediyor patron. #yemek ya da #ev dene';

  @override
  String mascot_tip_debt_due_date(String name) {
    return '$name ile olan borca vade koy, zamanında hatırlatırım';
  }

  @override
  String mascot_tip_budget_for(String name, int percent) {
    return 'Patron, “$name” tüm harcamaların %$percent kadarını alıyor. Ona bir bütçe koyalım mı?';
  }

  @override
  String get mascot_tip_rainy_day =>
      'Patron, kara gün için ayrı bir cüzdan aç. Sürprizler bizi hazırlıksız yakalamasın';

  @override
  String get mascot_tip_pay_yourself_first =>
      'Çekirdekler geldi! Dağılmadan bir kısmını hemen kenara koy patron';

  @override
  String get mascot_tip_treat =>
      'Zula yerinde patron. Arada bir kendini şımartabilirsin, vicdan azabı yok';

  @override
  String mascot_tip_future_self(String amount, String amount2) {
    return 'Günde sadece $amount, yılda $amount2 eder. O yanakları düşün patron!';
  }

  @override
  String get mascot_joke_friday =>
      'Cuma geldi patron! Sen eğlen, çekirdekleri ben beklerim';

  @override
  String get mascot_joke_late_night =>
      'Geç oldu patron… Yazıp yatalım mı? Ben esniyorum bile';

  @override
  String get mascot_joke_cheeks =>
      'Biliyor musun patron? Hamsterlar çekirdeği yanağında taşır. Ben de senin bütçeni';

  @override
  String get mascot_joke_trees =>
      'Çekirdekler ağaçta yetişse bile yine yanaklarıma saklardım';

  @override
  String get mascot_joke_twice =>
      'Çekirdeklerini iki kez saydım. Aynı çıktı patron. İyiye işaret';

  @override
  String get mascot_joke_secret =>
      'Psst patron… Her harcamayı kafanda yukarı yuvarla. Aradaki fark senin gizli zulan';

  @override
  String mascot_reaction_income(String amount) {
    return '$amount yakaladım! Zulaya patron';
  }

  @override
  String mascot_reaction_big_income(String amount) {
    return 'Vay patron! +$amount. Yanaklarım patlayacak!';
  }

  @override
  String mascot_reaction_transfer(String amount) {
    return '$amount aktardım';
  }

  @override
  String mascot_reaction_lent(String amount) {
    return '$amount borç verdik. Unutmam patron';
  }

  @override
  String get mascot_reaction_debt_closed =>
      'Borç kapandı! Patiler tertemiz patron';

  @override
  String get mascot_reaction_forgiven => 'Bağışladın… Yüreğin güzel patron';

  @override
  String get mascot_reaction_first_wallet =>
      'İlk cüzdan patron! Biriktirmeye başlıyoruz';

  @override
  String get mascot_reaction_budget => 'Bütçe hazır. Nöbetteyim patron';

  @override
  String get mascot_wallet_negative => 'Patron, bu cüzdan eksiye düştü';

  @override
  String mascot_wallet_down(int percent) {
    return 'Ayın başından beri buradaki çekirdeklerin %$percent kadarı gitti';
  }

  @override
  String mascot_wallet_up(String amount) {
    return 'Ay başından beri $amount arttı. Harika patron!';
  }

  @override
  String get mascot_wallet_sleeping => 'Bu cüzdan bir aydır uyuyor. Şşş…';

  @override
  String get mascot_wallet_calm => 'Burada her şey sakin patron';

  @override
  String mascot_budgets_over(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Patron, $count bütçe limiti aştı',
    );
    return '$_temp0';
  }

  @override
  String mascot_budgets_near(String name) {
    return '“$name” neredeyse bitti patron';
  }

  @override
  String get mascot_budgets_calm =>
      'Bütün çitler sağlam patron. Bütçeler yolunda';

  @override
  String mascot_budget_detail_over(String amount) {
    return '$amount aştı. Bir dahaki sefere limiti artıralım mı patron?';
  }

  @override
  String mascot_budget_detail_pace(String date) {
    return 'Böyle giderse limit $date tarihinde biter';
  }

  @override
  String get mascot_budget_detail_within =>
      'Limitin içinde kaldık! Gurur duyuyorum patron';

  @override
  String get mascot_budget_detail_calm => 'Her şey planlandığı gibi patron';

  @override
  String mascot_debts_overdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Patron, $count borcun vadesi geçti',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debts_all_closed =>
      'Bütün borçlar kapandı! Patiler tertemiz patron';

  @override
  String get mascot_debts_tracking =>
      'Kimin kime çekirdek borcu var, ben takip ediyorum';

  @override
  String mascot_debt_detail_overdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vadesi $days gün önce geçti patron',
      one: 'Vadesi dün geçti patron',
    );
    return '$_temp0';
  }

  @override
  String get mascot_debt_detail_lent =>
      'Çekirdeklerimizi kimin ödünç aldığını unutmadım patron';

  @override
  String mascot_debt_detail_due(String date) {
    return 'Son tarih: $date';
  }

  @override
  String mascot_subs_spinning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abonelik her ay çekirdekten payını alıyor',
    );
    return '$_temp0';
  }

  @override
  String mascot_tags_top(String name) {
    return 'Bu ay çekirdeklerin çoğu “$name” için gitti';
  }

  @override
  String mascot_tag_up(int percent) {
    return 'Burada geçen aydan %$percent fazla';
  }

  @override
  String mascot_tag_down(int percent) {
    return 'Geçen aydan %$percent az. Aferin patron!';
  }

  @override
  String mascot_progress_saved(String amount) {
    return 'Zulaya $amount girdi. Harika iş patron!';
  }

  @override
  String mascot_progress_over(String amount) {
    return 'Gelenden $amount fazla çekirdek gitti';
  }

  @override
  String mascot_progress_over_tag(String amount, String name) {
    return 'Gelenden $amount fazla çekirdek gitti, çoğu “$name” için';
  }

  @override
  String mascot_progress_forecast(String amount) {
    return 'Böyle giderse bu dönem yaklaşık $amount gidecek';
  }

  @override
  String get mascot_progress_counting => 'Bu dönemi hâlâ sayıyorum patron';

  @override
  String get mascot_screen_wallet_filter =>
      'Etikete göre filtrele, bu cüzdanın çekirdekleri nereye gidiyor gör';

  @override
  String get mascot_screen_wallet_switch =>
      'Başka cüzdana zıplamak için üstteki adına dokun';

  @override
  String get mascot_screen_wallet_limit =>
      'Bütçeler sekmesinden bu cüzdana sınır koyabilirsin';

  @override
  String get mascot_screen_budgets_rollover =>
      'Bütçe artanı bir sonraki döneme aktarabilir. Tek çekirdek ziyan olmaz';

  @override
  String get mascot_screen_budgets_tags =>
      'Bütçe sadece seçtiğin etiketleri izleyebilir. Mesela #kafe';

  @override
  String get mascot_screen_budget_periods =>
      'Öncekilerle karşılaştırmak için dönemler arasında gez';

  @override
  String get mascot_screen_debts_due =>
      'Vade koy, zamanında hatırlatırım patron';

  @override
  String get mascot_screen_debts_quick =>
      'En hızlı ödeme yolu: işlem ekranında Aktarım → Borçlar';

  @override
  String get mascot_screen_subs_pause =>
      'Aboneliği silmek yerine duraklatabilirsin. Geçmişi kalır';

  @override
  String get mascot_screen_tags_nest =>
      'Etiketleri eğik çizgiyle iç içe koy: yemek/kahve';

  @override
  String get mascot_screen_tags_map =>
      'Haritayı aç patron, etiketlerin nasıl bağlı gör';

  @override
  String get mascot_screen_tag_rename =>
      'Etiketi yeniden adlandır ya da taşı, alt etiketler de peşinden gelir';

  @override
  String get mascot_screen_progress_baseline =>
      'Geçen yılla ya da 3 aylık ortalamayla karşılaştırmak için “vs …” dokun';

  @override
  String mascot_ans_spent_today(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bugün $count harcamada $amount gitti',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_today =>
      'Bugün hiç harcama yok patron. Çekirdekler sapasağlam!';

  @override
  String mascot_ans_spent_yesterday(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dün $count harcamada $amount gitti',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_yesterday =>
      'Dün tek çekirdek harcamadın. Yaşasın!';

  @override
  String mascot_ans_spent_week(String amount) {
    return 'Bu hafta şimdiye kadar $amount gitti';
  }

  @override
  String mascot_ans_spent_month(String expense, String income) {
    return 'Bu ay $expense gitti, $income geldi';
  }

  @override
  String get mascot_ans_no_expenses => 'Bu ay henüz harcama yok. Harika patron';

  @override
  String mascot_ans_upcoming(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Önümüzdeki 7 günde $count ödeme var: $amount',
    );
    return '$_temp0';
  }

  @override
  String get mascot_ans_nothing_upcoming =>
      'Önümüzdeki hafta ödenecek bir şey yok';

  @override
  String mascot_ans_owed(String amount, String name) {
    return 'Sana $amount borç var, en çok $name';
  }

  @override
  String get mascot_ans_nobody_owes => 'Şu an kimsenin sana borcu yok';

  @override
  String get mascot_ans_reserve_low =>
      'Bir aydan az çekirdek var patron. Hadi bu yanakları birlikte dolduralım';

  @override
  String get mascot_ans_reserve_unknown =>
      'Doğru cevap için yaklaşık bir aylık kayıt lazım';

  @override
  String mascot_ans_where(String name, int percent, String name2) {
    return 'Çekirdeklerin çoğu “$name” için gitti (%$percent), sonra “$name2”';
  }

  @override
  String mascot_ans_where_one(String name, int percent) {
    return 'Çekirdeklerin neredeyse hepsi “$name” için gitti, %$percent';
  }

  @override
  String mascot_ans_where_untagged(int percent) {
    return 'Patron, harcamaların %$percent kadarında etiket yok, nereye gittiğini göremiyorum. Düzenleyelim mi?';
  }

  @override
  String get mascot_q_today => 'Bugün ne kadar?';

  @override
  String get mascot_q_yesterday => 'Peki dün?';

  @override
  String get mascot_q_week => 'Bu hafta?';

  @override
  String get mascot_q_month => 'Bu ay?';

  @override
  String get mascot_q_where => 'Çekirdekler nereye gitti?';

  @override
  String get mascot_q_biggest => 'En büyük harcama?';

  @override
  String get mascot_q_budgets => 'Bütçede miyim?';

  @override
  String get mascot_q_upcoming => 'Yakında ne ödeyeceğim?';

  @override
  String get mascot_q_owed => 'Kimin bana borcu var?';

  @override
  String get mascot_q_reserve => 'Ne kadar yeter?';

  @override
  String get mascot_q_tip => 'Bir tavsiye?';

  @override
  String get mascot_q_joke => 'Beni güldür';

  @override
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
