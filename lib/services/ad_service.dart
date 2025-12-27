import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedInterstitialAd? _rewardedAd;
  bool _isInitialized = false;
  bool _isPremium = false;
  bool _isLoading = false;
  DateTime? _unlockedUntil; // 잠금 해제 시간

  // 보상형 광고 콜백
  Function(int rewardAmount, String rewardType)? _onRewarded;

  // 프리미엄 상태 확인
  bool get isPremium => _isPremium;

  // 잠금 해제 상태 확인 (자정까지 무료)
  bool get isUnlocked {
    if (_isPremium) return true;
    if (_unlockedUntil == null) return false;
    return DateTime.now().isBefore(_unlockedUntil!);
  }

  // 자정까지 남은 시간
  Duration get timeUntilLock {
    if (_unlockedUntil == null) return Duration.zero;
    final remaining = _unlockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // 프리미엄 상태 설정 (IAP에서 호출)
  set isPremium(bool value) {
    _isPremium = value;
    _savePremiumStatus(value);
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;

    // 잠금 해제 시간 로드
    final unlockTime = prefs.getInt('unlocked_until');
    if (unlockTime != null) {
      _unlockedUntil = DateTime.fromMillisecondsSinceEpoch(unlockTime);
      // 이미 지났으면 null로
      if (_unlockedUntil!.isBefore(DateTime.now())) {
        _unlockedUntil = null;
      }
    }
  }

  Future<void> _savePremiumStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
  }

  // 자정까지 잠금 해제
  Future<void> unlockUntilMidnight() async {
    final now = DateTime.now();
    _unlockedUntil = DateTime(now.year, now.month, now.day + 1); // 다음날 자정

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'unlocked_until', _unlockedUntil!.millisecondsSinceEpoch);
  }

  // 보상형 광고 ID (Rewarded Interstitial)
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-5837885590326347/5844122459'; // Android 보상형 전면 광고
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5837885590326347/5443214505'; // iOS 보상형 전면 광고
    }
    return '';
  }

  // 플랫폼이 광고를 지원하는지 확인 (프리미엄이면 광고 안 보임)
  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
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

    // 보상형 광고 미리 로드
    await loadRewardedAd();
  }

  // 보상형 광고 로드
  Future<void> loadRewardedAd() async {
    if (!shouldShowAds) return;
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    await RewardedInterstitialAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          print('보상형 전면 광고 로드됨');
        },
        onAdFailedToLoad: (error) {
          print('보상형 전면 광고 로드 실패: $error');
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  // 보상형 광고 준비 여부 확인
  bool get isRewardedAdReady => _rewardedAd != null;

  // 보상형 광고 표시
  Future<void> showRewardedAd({
    required Function(int rewardAmount, String rewardType) onRewarded,
  }) async {
    if (!shouldShowAds) {
      // 프리미엄 사용자에게는 보상 제공
      onRewarded(10, 'quotes');
      return;
    }

    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) {
        // 광고 로드 실패 - 사용자에게 다시 시도 요청
        return;
      }
    }

    _onRewarded = onRewarded;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        // 광고 표시 실패 - 보상 없음
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        // 보상 지급
        if (_onRewarded != null) {
          _onRewarded!(reward.amount.toInt(), reward.type);
        }
      },
    );
    _rewardedAd = null;
    _onRewarded = null;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
