import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // 캐시된 번역 저장
  final Map<String, Map<String, String>> _cache = {};

  // 로컬 번역 캐시 로드
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString('translation_cache');
    if (cacheJson != null) {
      final decoded = json.decode(cacheJson) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _cache[key] = Map<String, String>.from(value);
      });
    }
  }

  // 캐시 저장
  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('translation_cache', json.encode(_cache));
  }

  // 번역 가져오기 (캐시 우선)
  Future<String?> getTranslation(String text, String targetLang) async {
    // 영어면 번역 필요 없음
    if (targetLang == 'en') return null;

    final cacheKey = '${text.hashCode}_$targetLang';
    
    // 캐시에서 확인
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]?['translation'];
    }

    // 실제 번역 API 호출 (여기서는 무료 API 사용)
    try {
      final translation = await _translateWithFreeAPI(text, targetLang);
      if (translation != null) {
        _cache[cacheKey] = {'translation': translation};
        await _saveCache();
      }
      return translation;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }

  // 무료 번역 API (LibreTranslate 또는 MyMemory)
  Future<String?> _translateWithFreeAPI(String text, String targetLang) async {
    try {
      // MyMemory API (무료, 일일 제한 있음)
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$targetLang'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translation = data['responseData']['translatedText'];
        
        // 번역 품질 체크
        if (translation != null && 
            translation != text && 
            !translation.toString().toUpperCase().contains('MYMEMORY WARNING')) {
          return translation;
        }
      }
    } catch (e) {
      print('MyMemory API error: $e');
    }
    
    return null;
  }

  // 미리 정의된 인기 명언 번역 (오프라인 지원)
  static final Map<String, Map<String, String>> popularQuoteTranslations = {
    'The only way to do great work is to love what you do.': {
      'ko': '위대한 일을 하는 유일한 방법은 당신이 하는 일을 사랑하는 것이다.',
      'ja': '偉大な仕事をする唯一の方法は、自分のしていることを愛することだ。',
      'zh': '成就伟大事业的唯一方法就是热爱你所做的事情。',
      'es': 'La única manera de hacer un gran trabajo es amar lo que haces.',
    },
    'Be the change you wish to see in the world.': {
      'ko': '당신이 세상에서 보고 싶은 변화가 되어라.',
      'ja': '世界で見たい変化に、あなた自身がなりなさい。',
      'zh': '成为你希望在世界上看到的改变。',
      'es': 'Sé el cambio que deseas ver en el mundo.',
    },
    'In the middle of difficulty lies opportunity.': {
      'ko': '어려움 속에 기회가 있다.',
      'ja': '困難の中にこそ、機会がある。',
      'zh': '困难之中蕴含着机遇。',
      'es': 'En medio de la dificultad yace la oportunidad.',
    },
  };

  // 인기 명언에서 미리 저장된 번역 가져오기
  String? getOfflineTranslation(String text, String targetLang) {
    return popularQuoteTranslations[text]?[targetLang];
  }
}
