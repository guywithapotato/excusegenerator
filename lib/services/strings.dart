import 'package:flutter/widgets.dart';

import '../models/excuse.dart';

class S {
  S(this.language);
  final AppLanguage language;

  static S of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<StringScope>();
    return inherited?.strings ?? S(AppLanguage.en);
  }

  String t(String key) => _values[language]![key] ?? key;

  List<String> get onboardingTitles => language == AppLanguage.tr
      ? ['bahane üretici 3000\'e hoş geldin', '500+ bahane', 'kaydet ve paylaş', 'efsanevi bahaneler', 'hazır mısın?']
      : ['welcome to bahane üretici 3000', '500+ excuses', 'save and share', 'legendary excuses', 'are you ready?'];

  List<String> get onboardingDescriptions => language == AppLanguage.tr
      ? [
          'komik bahaneler üret ve arkadaşlarınla paylaş.',
          'yüzlerce türkçe ve english bahaneye eriş.',
          'favorilerine ekle ve anında paylaş.',
          'nadir ve efsanevi bahaneleri keşfet.',
          'bahane üretmeye başlayalım.',
        ]
      : [
          'generate funny excuses and share them with your friends.',
          'access hundreds of turkish and english excuses.',
          'add favorites and share instantly.',
          'discover rare and legendary excuses.',
          'let us start generating excuses.',
        ];
}

class StringScope extends InheritedWidget {
  const StringScope({super.key, required this.strings, required super.child});
  final S strings;

  @override
  bool updateShouldNotify(StringScope oldWidget) => strings.language != oldWidget.strings.language;
}

final _values = {
  AppLanguage.tr: {
    'app_title': 'bahane üretici 3000',
    'subtitle': 'hayat kurtaran profesyonel bahaneler',
    'home': 'ana sayfa',
    'favorites': 'favoriler',
    'history': 'geçmiş',
    'stats': 'istatistikler',
    'settings': 'ayarlar',
    'generate': 'bahane üret',
    'copy': 'kopyala',
    'share': 'paylaş',
    'copied': 'bahane panoya kopyalandı!',
    'favorite_added': 'favorilere eklendi',
    'favorite_removed': 'favorilerden çıkarıldı',
    'daily': 'günün bahanesi',
    'category': 'kategori',
    'all': 'tümü',
    'search': 'ara',
    'close': 'kapat',
    'empty': 'henüz bir şey yok',
    'clear_all': 'hepsini temizle',
    'language': 'dil',
    'theme': 'tema',
    'light': 'light',
    'dark': 'dark',
    'system': 'system',
    'sound': 'ses',
    'animations': 'animasyonlar',
    'show_onboarding': 'onboarding göster',
    'clear_favorites': 'favorileri temizle',
    'clear_history': 'geçmişi temizle',
    'reset_data': 'uygulama verilerini sıfırla',
    'total_generated': 'üretilen toplam bahane',
    'favorites_count': 'favori sayısı',
    'history_count': 'geçmiş sayısı',
    'legendary_found': 'bulunan efsanevi bahane',
    'achievement_progress': 'başarım ilerlemesi',
    'achievements': 'başarımlar',
    'skip': 'geç',
    'continue': 'devam',
    'start': 'başla',
    'ready': 'bahane üretmeye hazırsın',
    'common': 'sıradan',
    'rare': 'nadir',
    'epic': 'epik',
    'legendary': 'efsanevi',
    'first_excuse': 'ilk bahane',
    'professional_procrastinator': 'profesyonel erteleyici',
    'excuse_master': 'bahane ustası',
    'legendary_hunter': 'efsane avcısı',
    'principal_believes': 'müdür bile inanır',
    'hundred_club': '100 bahane kulübü',
  },
  AppLanguage.en: {
    'app_title': 'bahane üretici 3000',
    'subtitle': 'life-saving professional excuses',
    'home': 'home',
    'favorites': 'favorites',
    'history': 'history',
    'stats': 'statistics',
    'settings': 'settings',
    'generate': 'generate excuse',
    'copy': 'copy',
    'share': 'share',
    'copied': 'excuse copied to clipboard!',
    'favorite_added': 'added to favorites',
    'favorite_removed': 'removed from favorites',
    'daily': 'daily excuse',
    'category': 'category',
    'all': 'all',
    'search': 'search',
    'close': 'close',
    'empty': 'nothing here yet',
    'clear_all': 'clear all',
    'language': 'language',
    'theme': 'theme',
    'light': 'light',
    'dark': 'dark',
    'system': 'system',
    'sound': 'sound',
    'animations': 'animations',
    'show_onboarding': 'show onboarding again',
    'clear_favorites': 'clear favorites',
    'clear_history': 'clear history',
    'reset_data': 'reset app data',
    'total_generated': 'total excuses generated',
    'favorites_count': 'favorites count',
    'history_count': 'history count',
    'legendary_found': 'legendary excuses found',
    'achievement_progress': 'achievement progress',
    'achievements': 'achievements',
    'skip': 'skip',
    'continue': 'continue',
    'start': 'start',
    'ready': 'you\'re ready to generate excuses',
    'common': 'common',
    'rare': 'rare',
    'epic': 'epic',
    'legendary': 'legendary',
    'first_excuse': 'first excuse',
    'professional_procrastinator': 'professional procrastinator',
    'excuse_master': 'excuse master',
    'legendary_hunter': 'legendary hunter',
    'principal_believes': 'even the principal believes it',
    'hundred_club': '100 excuse club',
  },
};
