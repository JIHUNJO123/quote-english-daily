import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;
  int _quoteViewCount = 0;
  bool _isPremium = false;

  // 프리미엄 상태 확인
  bool get isPremium => _isPremium;
  
  // 프리미엄 상태 설정 (IAP에서 호출)
  set isPremium(bool value) {
    _isPremium = value;
    _savePremiumStatus(value);
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
  }

  Future<void> _savePremiumStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
  }

  // 실제 광고 ID
  static String get bannerAdUnitId {
    if (kIsWeb) return ''; // 웹은 지원 안함
    if (Platform.isAndroid) {
      return 'ca-app-pub-5837885590326347/9922573116'; // Android 배너
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5837885590326347/7915179264'; // iOS 배너
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-5837885590326347/5847596734'; // Android 전면
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5837885590326347/3664286522'; // iOS 전면
    }
    return '';
  }

  // 플랫폼이 광고를 지원하는지 확인 (프리미엄이면 광고 안 보임)
  static bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get shouldShowAds => isSupported && !_isPremium;

  Future<void> initialize() async {
    if (!isSupported || _isInitialized) return;

    await _loadPremiumStatus();
    
    if (_isPremium) {
      _isInitialized = true;
      return; // 프리미엄 사용자는 광고 로드 안함
    }

    await MobileAds.instance.initialize();
    _isInitialized = true;
    
    // 배너 광고 미리 로드
    await loadBannerAd();
    // 전면 광고 미리 로드
    await loadInterstitialAd();
  }

  // 배너 광고 로드
  Future<void> loadBannerAd() async {
    if (!shouldShowAds) return;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('배너 광고 로드됨');
        },
        onAdFailedToLoad: (ad, error) {
          print('배너 광고 로드 실패: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    );

    await _bannerAd?.load();
  }

  // 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    if (!shouldShowAds) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('전면 광고 로드됨');
        },
        onAdFailedToLoad: (error) {
          print('전면 광고 로드 실패: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  // 배너 광고 가져오기
  BannerAd? get bannerAd => _bannerAd;

  // 명언 조회 수 증가 및 전면 광고 표시 (5번마다)
  Future<void> incrementQuoteView() async {
    if (!shouldShowAds) return;

    _quoteViewCount++;
    
    // 5번 명언 볼 때마다 전면 광고
    if (_quoteViewCount >= 5) {
      await showInterstitialAd();
      _quoteViewCount = 0;
    }
  }

  // 전면 광고 표시
  Future<void> showInterstitialAd() async {
    if (!shouldShowAds) return;
    
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
