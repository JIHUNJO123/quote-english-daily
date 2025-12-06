import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;
  static Map<String, Map<String, String>> _dynamicTranslations = {};
  static bool _isInitialized = false;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // 앱 시작 시 번역 로드
  static Future<void> initialize(String langCode) async {
    if (_isInitialized && _dynamicTranslations.containsKey(langCode)) return;
    
    // 수동 번역이 있는 언어는 스킵
    if (_localizedValues.containsKey(langCode)) {
      _isInitialized = true;
      return;
    }
    
    // 캐시에서 로드 시도
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('ui_translations_$langCode');
    
    if (cached != null) {
      _dynamicTranslations[langCode] = Map<String, String>.from(json.decode(cached));
      _isInitialized = true;
      return;
    }
    
    // API로 번역
    await _translateUIStrings(langCode);
    _isInitialized = true;
  }

  // UI 문자열 자동 번역
  static Future<void> _translateUIStrings(String langCode) async {
    final englishStrings = _localizedValues['en']!;
    final translated = <String, String>{};
    
    // 배치로 번역 (API 호출 최소화)
    for (final entry in englishStrings.entries) {
      try {
        final result = await _translateText(entry.value, langCode);
        translated[entry.key] = result ?? entry.value;
      } catch (e) {
        translated[entry.key] = entry.value; // 실패 시 영어 유지
      }
    }
    
    _dynamicTranslations[langCode] = translated;
    
    // 캐시에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ui_translations_$langCode', json.encode(translated));
  }

  static Future<String?> _translateText(String text, String targetLang) async {
    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$targetLang'
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translation = data['responseData']['translatedText'];
        
        if (translation != null && 
            !translation.toString().toUpperCase().contains('MYMEMORY WARNING')) {
          return translation;
        }
      }
    } catch (e) {
      // 무시
    }
    return null;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'home': 'Home',
      'categories': 'Categories',
      'favorites': 'Favorites',
      'settings': 'Settings',
      
      // Home Screen
      'daily_quote': "Today's Quote",
      'random_quote': 'Random Quote',
      'new_quote': 'New Quote',
      'view_daily_quote': 'View Daily Quote',
      
      // Categories
      'happiness': 'Happiness',
      'inspiration': 'Inspiration',
      'love': 'Love',
      'success': 'Success',
      'truth': 'Truth',
      'poetry': 'Poetry',
      'death': 'Life & Death',
      'romance': 'Romance',
      'science': 'Science',
      'time': 'Time',
      'quotes_count': 'quotes',
      
      // Favorites
      'no_favorites': 'No favorite quotes yet',
      'add_favorites_hint': 'Tap the heart icon on quotes you love',
      
      // Actions
      'share': 'Share',
      'copy': 'Copy',
      'copied_to_clipboard': 'Copied to clipboard',
      
      // Settings
      'notifications': 'Notifications',
      'daily_notification': 'Daily Quote Notification',
      'notification_time': 'Notification Time',
      'notification_on': 'Notification enabled',
      'notification_off': 'Notification disabled',
      'notification_time_changed': 'Notification time changed to',
      'notification_permission_required': 'Notification permission required',
      'app_info': 'App Info',
      'version': 'Version',
      'quote_data': 'Quote Data',
      'quotes_available': 'quotes available',
      
      // Translation
      'translation': 'Translation',
      'show_translation': 'Show Translation',
      'translating': 'Translating...',
      'notification_web_unavailable': 'Notifications are only available on mobile devices',
      
      // IAP
      'premium': 'Premium',
      'remove_ads': 'Remove Ads',
      'remove_ads_desc': 'Enjoy ad-free experience',
      'restore_purchases': 'Restore Purchases',
      'purchase_success': 'Purchase successful! Ads removed.',
      'purchase_failed': 'Purchase failed. Please try again.',
      'already_premium': 'You already have premium!',
      'restoring': 'Restoring purchases...',
    },
    'ko': {
      // Navigation
      'home': '홈',
      'categories': '카테고리',
      'favorites': '즐겨찾기',
      'settings': '설정',
      
      // Home Screen
      'daily_quote': '오늘의 명언',
      'random_quote': '랜덤 명언',
      'new_quote': '새로운 명언 보기',
      'view_daily_quote': '오늘의 명언 보기',
      
      // Categories
      'happiness': '행복',
      'inspiration': '영감',
      'love': '사랑',
      'success': '성공',
      'truth': '진실',
      'poetry': '시',
      'death': '삶과 죽음',
      'romance': '로맨스',
      'science': '과학',
      'time': '시간',
      'quotes_count': '개의 명언',
      
      // Favorites
      'no_favorites': '즐겨찾기한 명언이 없습니다',
      'add_favorites_hint': '마음에 드는 명언에 하트를 눌러보세요',
      
      // Actions
      'share': '공유',
      'copy': '복사',
      'copied_to_clipboard': '클립보드에 복사되었습니다',
      
      // Settings
      'notifications': '알림',
      'daily_notification': '매일 명언 알림',
      'notification_time': '알림 시간',
      'notification_on': '알림이 설정되었습니다',
      'notification_off': '알림이 해제되었습니다',
      'notification_time_changed': '알림 시간이 변경되었습니다:',
      'notification_permission_required': '알림 권한이 필요합니다',
      'app_info': '앱 정보',
      'version': '버전',
      'quote_data': '명언 데이터',
      'quotes_available': '개의 명언',
      
      // Translation
      'translation': '번역',
      'show_translation': '번역 보기',
      'translating': '번역 중...',
      'notification_web_unavailable': '알림은 모바일 기기에서만 사용 가능합니다',
      
      // IAP
      'premium': '프리미엄',
      'remove_ads': '광고 제거',
      'remove_ads_desc': '광고 없이 앱을 즐기세요',
      'restore_purchases': '구매 복원',
      'purchase_success': '구매 완료! 광고가 제거되었습니다.',
      'purchase_failed': '구매 실패. 다시 시도해주세요.',
      'already_premium': '이미 프리미엄 사용자입니다!',
      'restoring': '구매 복원 중...',
    },
    'ja': {
      'home': 'ホーム',
      'categories': 'カテゴリー',
      'favorites': 'お気に入り',
      'settings': '設定',
      'daily_quote': '今日の名言',
      'random_quote': 'ランダム名言',
      'new_quote': '新しい名言を見る',
      'view_daily_quote': '今日の名言を見る',
      'happiness': '幸福',
      'inspiration': 'インスピレーション',
      'love': '愛',
      'success': '成功',
      'truth': '真実',
      'poetry': '詩',
      'death': '生と死',
      'romance': 'ロマンス',
      'science': '科学',
      'time': '時間',
      'quotes_count': '件の名言',
      'no_favorites': 'お気に入りの名言がありません',
      'add_favorites_hint': '好きな名言のハートをタップしてください',
      'share': '共有',
      'copy': 'コピー',
      'copied_to_clipboard': 'クリップボードにコピーしました',
      'notifications': '通知',
      'daily_notification': '毎日の名言通知',
      'notification_time': '通知時間',
      'notification_on': '通知が設定されました',
      'notification_off': '通知が解除されました',
      'notification_time_changed': '通知時間が変更されました:',
      'notification_permission_required': '通知権限が必要です',
      'app_info': 'アプリ情報',
      'version': 'バージョン',
      'quote_data': '名言データ',
      'quotes_available': '件の名言',
      'translation': '翻訳',
      'show_translation': '翻訳を表示',
      'translating': '翻訳中...',
      'notification_web_unavailable': '通知はモバイル端末でのみ利用可能です',
      'premium': 'プレミアム',
      'remove_ads': '広告を削除',
      'remove_ads_desc': '広告なしでアプリをお楽しみください',
      'restore_purchases': '購入を復元',
      'purchase_success': '購入完了！広告が削除されました。',
      'purchase_failed': '購入に失敗しました。もう一度お試しください。',
      'already_premium': 'すでにプレミアムです！',
      'restoring': '購入を復元中...',
    },
    'zh': {
      'home': '首页',
      'categories': '分类',
      'favorites': '收藏',
      'settings': '设置',
      'daily_quote': '今日名言',
      'random_quote': '随机名言',
      'new_quote': '查看新名言',
      'view_daily_quote': '查看今日名言',
      'happiness': '幸福',
      'inspiration': '灵感',
      'love': '爱情',
      'success': '成功',
      'truth': '真理',
      'poetry': '诗歌',
      'death': '生死',
      'romance': '浪漫',
      'science': '科学',
      'time': '时间',
      'quotes_count': '条名言',
      'no_favorites': '还没有收藏的名言',
      'add_favorites_hint': '点击喜欢的名言的心形图标',
      'share': '分享',
      'copy': '复制',
      'copied_to_clipboard': '已复制到剪贴板',
      'notifications': '通知',
      'daily_notification': '每日名言通知',
      'notification_time': '通知时间',
      'notification_on': '通知已开启',
      'notification_off': '通知已关闭',
      'notification_time_changed': '通知时间已更改为:',
      'notification_permission_required': '需要通知权限',
      'app_info': '应用信息',
      'version': '版本',
      'quote_data': '名言数据',
      'quotes_available': '条名言',
      'translation': '翻译',
      'show_translation': '显示翻译',
      'translating': '翻译中...',
      'notification_web_unavailable': '通知仅在移动设备上可用',
      'premium': '高级版',
      'remove_ads': '移除广告',
      'remove_ads_desc': '享受无广告体验',
      'restore_purchases': '恢复购买',
      'purchase_success': '购买成功！广告已移除。',
      'purchase_failed': '购买失败，请重试。',
      'already_premium': '您已经是高级用户！',
      'restoring': '正在恢复购买...',
    },
    'es': {
      'home': 'Inicio',
      'categories': 'Categorías',
      'favorites': 'Favoritos',
      'settings': 'Ajustes',
      'daily_quote': 'Cita del día',
      'random_quote': 'Cita aleatoria',
      'new_quote': 'Nueva cita',
      'view_daily_quote': 'Ver cita del día',
      'happiness': 'Felicidad',
      'inspiration': 'Inspiración',
      'love': 'Amor',
      'success': 'Éxito',
      'truth': 'Verdad',
      'poetry': 'Poesía',
      'death': 'Vida y muerte',
      'romance': 'Romance',
      'science': 'Ciencia',
      'time': 'Tiempo',
      'quotes_count': 'citas',
      'no_favorites': 'No hay citas favoritas',
      'add_favorites_hint': 'Toca el corazón en las citas que te gusten',
      'share': 'Compartir',
      'copy': 'Copiar',
      'copied_to_clipboard': 'Copiado al portapapeles',
      'notifications': 'Notificaciones',
      'daily_notification': 'Notificación diaria',
      'notification_time': 'Hora de notificación',
      'notification_on': 'Notificación activada',
      'notification_off': 'Notificación desactivada',
      'notification_time_changed': 'Hora cambiada a:',
      'notification_permission_required': 'Se requiere permiso de notificación',
      'app_info': 'Info de la app',
      'version': 'Versión',
      'quote_data': 'Datos de citas',
      'quotes_available': 'citas disponibles',
      'translation': 'Traducción',
      'show_translation': 'Mostrar traducción',
      'translating': 'Traduciendo...',
      'notification_web_unavailable': 'Las notificaciones solo están disponibles en dispositivos móviles',
      'premium': 'Premium',
      'remove_ads': 'Eliminar anuncios',
      'remove_ads_desc': 'Disfruta sin anuncios',
      'restore_purchases': 'Restaurar compras',
      'purchase_success': '¡Compra exitosa! Anuncios eliminados.',
      'purchase_failed': 'Compra fallida. Inténtalo de nuevo.',
      'already_premium': '¡Ya tienes premium!',
      'restoring': 'Restaurando compras...',
    },
  };

  String get(String key) {
    final langCode = locale.languageCode;
    
    // 1. 수동 번역 확인
    if (_localizedValues.containsKey(langCode)) {
      return _localizedValues[langCode]?[key] ?? 
             _localizedValues['en']?[key] ?? 
             key;
    }
    
    // 2. 동적 번역 확인
    if (_dynamicTranslations.containsKey(langCode)) {
      return _dynamicTranslations[langCode]?[key] ?? 
             _localizedValues['en']?[key] ?? 
             key;
    }
    
    // 3. 기본값 (영어)
    return _localizedValues['en']?[key] ?? key;
  }

  String getCategory(String category) {
    return get(category.toLowerCase());
  }

  // 모든 언어 지원 (동적 번역 포함)
  static List<Locale> get supportedLocales {
    return _allLanguageCodes.map((code) => Locale(code)).toList();
  }

  // 수동 번역된 언어
  static List<String> get manuallyTranslatedLanguages => ['en', 'ko', 'ja', 'zh', 'es'];
  
  // 모든 지원 언어 코드
  static List<String> get _allLanguageCodes => _languageNames.keys.toList();
  
  static List<String> get supportedLanguageCodes => _allLanguageCodes;

  // 전 세계 175개국 언어 이름 (각 언어의 모국어 표기)
  static const Map<String, String> _languageNames = {
    // 주요 언어
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'zh': '中文',
    'es': 'Español',
    
    // 유럽 언어
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'pl': 'Polski',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'no': 'Norsk',
    'da': 'Dansk',
    'fi': 'Suomi',
    'el': 'Ελληνικά',
    'cs': 'Čeština',
    'sk': 'Slovenčina',
    'hu': 'Magyar',
    'ro': 'Română',
    'bg': 'Български',
    'hr': 'Hrvatski',
    'sr': 'Српски',
    'sl': 'Slovenščina',
    'uk': 'Українська',
    'be': 'Беларуская',
    'lt': 'Lietuvių',
    'lv': 'Latviešu',
    'et': 'Eesti',
    'is': 'Íslenska',
    'ga': 'Gaeilge',
    'cy': 'Cymraeg',
    'mt': 'Malti',
    'lb': 'Lëtzebuergesch',
    'mk': 'Македонски',
    'sq': 'Shqip',
    'bs': 'Bosanski',
    'ca': 'Català',
    'gl': 'Galego',
    'eu': 'Euskara',
    
    // 아시아 언어
    'hi': 'हिन्दी',
    'bn': 'বাংলা',
    'pa': 'ਪੰਜਾਬੀ',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ',
    'ml': 'മലയാളം',
    'or': 'ଓଡ଼ିଆ',
    'as': 'অসমীয়া',
    'ne': 'नेपाली',
    'si': 'සිංහල',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu',
    'tl': 'Tagalog',
    'my': 'မြန်မာဘာသာ',
    'km': 'ភាសាខ្មែរ',
    'lo': 'ລາວ',
    'mn': 'Монгол',
    'bo': 'བོད་སྐད།',
    'dz': 'རྫོང་ཁ།',
    'ka': 'ქართული',
    'hy': 'Հայdelays',
    'az': 'Azərbaycan',
    'kk': 'Қазақша',
    'ky': 'Кыргызча',
    'uz': 'Oʻzbekcha',
    'tk': 'Türkmençe',
    'tg': 'Тоҷикӣ',
    
    // 중동/아랍 언어
    'ar': 'العربية',
    'fa': 'فارسی',
    'he': 'עברית',
    'tr': 'Türkçe',
    'ur': 'اردو',
    'ps': 'پښتو',
    'ku': 'Kurdî',
    
    // 아프리카 언어
    'sw': 'Kiswahili',
    'am': 'አማርኛ',
    'ha': 'Hausa',
    'yo': 'Yorùbá',
    'ig': 'Igbo',
    'zu': 'isiZulu',
    'xh': 'isiXhosa',
    'af': 'Afrikaans',
    'so': 'Soomaali',
    'rw': 'Kinyarwanda',
    'mg': 'Malagasy',
    'sn': 'chiShona',
    'ny': 'Chichewa',
    'lg': 'Luganda',
    'wo': 'Wolof',
    
    // 태평양/오세아니아
    'mi': 'Te Reo Māori',
    'sm': 'Gagana Samoa',
    'to': 'Lea Fakatonga',
    'fj': 'Na Vosa Vakaviti',
    'haw': 'ʻŌlelo Hawaiʻi',
    
    // 기타
    'eo': 'Esperanto',
    'la': 'Latina',
    'jv': 'Basa Jawa',
    'su': 'Basa Sunda',
    'ceb': 'Cebuano',
    'ht': 'Kreyòl Ayisyen',
    'yi': 'ייִדיש',
    'fy': 'Frysk',
    'gd': 'Gàidhlig',
    'co': 'Corsu',
    'oc': 'Occitan',
    'br': 'Brezhoneg',
  };

  String get languageName {
    return _languageNames[locale.languageCode] ?? 
           _languageNames['en'] ?? 
           locale.languageCode.toUpperCase();
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
