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
  String get progress_month => 'Ay';

  @override
  String get progress_year => 'Yıl';

  @override
  String get progress_income => 'Gelir';

  @override
  String get progress_expense => 'Gider';

  @override
  String get progress_net => 'Net';

  @override
  String get progress_vs_last_month => 'geçen aya göre';

  @override
  String get progress_vs_last_year => 'geçen yıla göre';

  @override
  String get progress_all_wallets => 'Tüm cüzdanlar';

  @override
  String get progress_scope_title => 'Verileri göster';

  @override
  String get progress_chart_title => 'Gelir vs Gider';

  @override
  String progress_not_included(String codes) {
    return '$codes dahil değil';
  }

  @override
  String get progress_empty_title => 'Henüz analiz edilecek bir şey yok';

  @override
  String get progress_trend_title => 'Seyir';

  @override
  String get progress_tags_title => 'Etikete göre gider';

  @override
  String get progress_untagged => 'Etiketsiz';

  @override
  String get progress_other_tags => 'Diğer';

  @override
  String get progress_no_expenses => 'Bu dönemde gider yok';

  @override
  String get progress_empty_subtitle =>
      'Birkaç işlem ekleyin, ilerlemeniz burada görünsün.';

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
      'Borç verirken işlem ekranında bir kişi seçin';

  @override
  String get debt_new => 'Yeni borç';

  @override
  String get debts_all => 'Tüm borçlar';

  @override
  String get debts_empty_hint => 'Verdiğin ve aldığın borçları takip et';

  @override
  String get dashboard_reorder_hint => 'Sıralamak için basılı tut';

  @override
  String dashboard_budgets_over(int count) {
    return 'limit aşan: $count';
  }

  @override
  String dashboard_budgets_at_risk(int count) {
    return 'riskte: $count';
  }

  @override
  String get dashboard_budgets_on_track => 'Hepsi yolunda';

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
  String get debt_person => 'Kişi';

  @override
  String get debt_person_chip => 'Kişi';

  @override
  String get debt_person_title => 'Kişi';

  @override
  String get debt_person_search => 'Ad';

  @override
  String get debt_person_empty => 'Henüz kimse yok — bir ad yazın';

  @override
  String get debt_person_none => 'Kişi yok';

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
  String get debt_error_person => 'Bir kişi seçin';

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
  String get debt_rename_person => 'Kişiyi yeniden adlandır';

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
  String get l10nStopLineDontTouch =>
      '☠☠☠☠☠☠☠☠☠☠☠☠☠ Don\'t touch this line ☠☠☠☠☠☠☠☠☠☠☠☠☠';
}
