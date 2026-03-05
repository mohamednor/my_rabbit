import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdRewardType {
  biggerRadius,
  slowerObstacles,
  doublePoints,
}

extension AdRewardTypeExt on AdRewardType {
  String get displayName {
    switch (this) {
      case AdRewardType.biggerRadius:
        return '🧲 Mega Magnet!';
      case AdRewardType.slowerObstacles:
        return '🐢 Slow Motion!';
      case AdRewardType.doublePoints:
        return '✨ Double Points!';
    }
  }
  
  static const int boostDurationSeconds = 12;
}

class AdService {
  static const String _bannerAdUnitId = 'ca-app-pub-4380269071153281/4882324106';
  static const List<String> _rewardedAdUnitIds = [
    'ca-app-pub-4380269071153281/5629117921',
    'ca-app-pub-4380269071153281/3562667293',
  ];
  
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  
  bool _isBannerLoaded = false;
  bool _isRewardedLoaded = false;
  
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  BannerAd? get bannerAd => _bannerAd;
  
  final Random _random = Random();
  
  void initialize() {
    loadBannerAd();
    loadRewardedAd();
  }
  
  void loadBannerAd({Function? onLoaded}) {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerLoaded = false;
          Future.delayed(const Duration(seconds: 30), loadBannerAd);
        },
      ),
    );
    _bannerAd!.load();
  }
  
  void loadRewardedAd({Function? onLoaded}) {
    final adUnitId = _rewardedAdUnitIds[_random.nextInt(_rewardedAdUnitIds.length)];
    
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          Future.delayed(const Duration(seconds: 30), loadRewardedAd);
        },
      ),
    );
  }
  
  void showRewardedAd({
    required void Function(AdRewardType) onRewarded,
    Function? onAdClosed,
    Function? onAdNotReady,
  }) {
    if (_rewardedAd == null || !_isRewardedLoaded) {
      onAdNotReady?.call();
      loadRewardedAd();
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
        loadRewardedAd();
      },
    );
    
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        final rewardType = AdRewardType.values[_random.nextInt(AdRewardType.values.length)];
        onRewarded(rewardType);
      },
    );
  }
  
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
  }
}
