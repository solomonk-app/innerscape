import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_ids.dart';

class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialRetryCount = 0;
  int _rewardedRetryCount = 0;
  static const int _maxRetries = 3;
  Completer<void>? _initCompleter;

  Future<void> waitForInit() async {
    if (_initCompleter != null) await _initCompleter!.future;
  }

  Future<void> initialize() async {
    _initCompleter = Completer<void>();
    await MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: [
        'E596C1B641F44DBF4C1341466876FA43', // Android
        'e9d4bbac3bc7a050bcd2915a00c2538f', // iOS
      ]),
    );
    debugPrint('AdService: MobileAds initialized');
    _initCompleter!.complete();
    loadInterstitial();
    loadRewarded();
  }

  // --- Banner ---

  Future<BannerAd?> createAdaptiveBanner(BuildContext context) async {
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );
    if (size == null) return null;

    final completer = Completer<BannerAd?>();
    final bannerAd = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => completer.complete(ad as BannerAd),
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdService: Banner failed: ${error.message}');
          ad.dispose();
          completer.complete(null);
        },
      ),
    );
    bannerAd.load();
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('AdService: Banner load timed out');
        bannerAd.dispose();
        return null;
      },
    );
  }

  // --- Interstitial ---

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialRetryCount = 0;
          debugPrint('AdService: Interstitial loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial failed to load: ${error.message}');
          _interstitialAd = null;
          _retryInterstitial();
        },
      ),
    );
  }

  void _retryInterstitial() {
    if (_interstitialRetryCount >= _maxRetries) return;
    _interstitialRetryCount++;
    final delay = Duration(seconds: pow(2, _interstitialRetryCount).toInt());
    debugPrint('AdService: Retrying interstitial in ${delay.inSeconds}s (attempt $_interstitialRetryCount)');
    Future.delayed(delay, loadInterstitial);
  }

  Future<bool> showInterstitial() async {
    if (_interstitialAd == null) return false;

    final completer = Completer<bool>();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Interstitial failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
        completer.complete(false);
      },
    );
    _interstitialAd!.show();
    return completer.future;
  }

  // --- Rewarded ---

  void loadRewarded() {
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedRetryCount = 0;
          debugPrint('AdService: Rewarded loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Rewarded failed to load: ${error.message}');
          _rewardedAd = null;
          _retryRewarded();
        },
      ),
    );
  }

  void _retryRewarded() {
    if (_rewardedRetryCount >= _maxRetries) return;
    _rewardedRetryCount++;
    final delay = Duration(seconds: pow(2, _rewardedRetryCount).toInt());
    debugPrint('AdService: Retrying rewarded in ${delay.inSeconds}s (attempt $_rewardedRetryCount)');
    Future.delayed(delay, loadRewarded);
  }

  Future<RewardItem?> showRewarded() async {
    if (_rewardedAd == null) return null;

    final completer = Completer<RewardItem?>();
    RewardItem? earnedReward;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
        completer.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Rewarded failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
        completer.complete(null);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        earnedReward = reward;
      },
    );

    return completer.future;
  }
}
