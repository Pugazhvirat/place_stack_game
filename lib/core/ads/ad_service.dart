import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:place_stack/app/config/app_config.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/core/ads/ad_configuration.dart';
import 'package:place_stack/core/storage/storage_service.dart';

class AdService {
  AdService(this._storage);
  final StorageService _storage;

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  int _gameOvers = 0;
  final ValueNotifier<bool> rewardedReady = ValueNotifier<bool>(false);
  Timer? _retryTimer;
  bool _loadingRewarded = false;

  bool get adsEnabled => !_storage.adsRemoved;
  bool get isRewardedReady => _rewarded != null;

  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      _loadInterstitial();
      _loadRewarded();
    } catch (e) {
      debugPrint('[ads] init failed: $e');
    }
  }

  void _loadInterstitial() {
    if (!adsEnabled) return;
    InterstitialAd.load(
      adUnitId: AdConfiguration.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  // void _loadRewarded() {
  //   RewardedAd.load(
  //     adUnitId: AdConfiguration.rewardedUnitId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (ad) => _rewarded = ad,
  //       onAdFailedToLoad: (_) => _rewarded = null,
  //     ),
  //   );
  // }

  void loadRewardedIfNeeded() {
    if (_rewarded == null) _loadRewarded();
  }

  void _loadRewarded() {
    if (_loadingRewarded) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdConfiguration.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingRewarded = false;
          _retryTimer?.cancel();
          _rewarded = ad;
          rewardedReady.value = true;
        },
        onAdFailedToLoad: (_) {
          _loadingRewarded = false;
          _rewarded = null;
          rewardedReady.value = false;
          _retryTimer?.cancel();
          _retryTimer = Timer(const Duration(seconds: 4), _loadRewarded);
        },
      ),
    );
  }

  /// Shows an interstitial every N game overs (never when ads were purchased away).
  /// Shows an interstitial every N game overs. Returns true if an ad was shown.
  Future<bool> maybeShowInterstitial() async {
    if (!adsEnabled) return false;
    _gameOvers++;
    if (_gameOvers < AppConfig.interstitialEveryNGameOvers) return false;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return false;
    }
    _gameOvers = 0;
    final done = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
        if (!done.isCompleted) done.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
        if (!done.isCompleted) done.complete();
      },
    );
    await ad.show();
    await done.future;
    return true;
  }

  /// Returns true only when the user earned the reward.
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    var earned = false;
    final done = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        rewardedReady.value = false;
        _loadRewarded();
        if (!done.isCompleted) done.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _rewarded = null;
        rewardedReady.value = false;
        _loadRewarded();
        if (!done.isCompleted) done.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => earned = true);
    return done.future;
  }
}

final adServiceProvider = Provider<AdService>(
  (ref) => AdService(ref.watch(storageServiceProvider)),
);

class AdsRemovedNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(storageServiceProvider).adsRemoved;

  Future<void> setRemoved(bool value) async {
    await ref.read(storageServiceProvider).setAdsRemoved(value);
    state = value;
  }
}

final adsRemovedProvider = NotifierProvider<AdsRemovedNotifier, bool>(AdsRemovedNotifier.new);

/// Fixed-height banner slot (reserves space so layout never jumps).
class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    _ad = BannerAd(
      adUnitId: AdConfiguration.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   final ad = _ad;
  //   return SizedBox(
  //     height: AppDimensions.bannerHeight,
  //     width: double.infinity,
  //     child: (_loaded && ad != null)
  //         ? Center(
  //             child: SizedBox(
  //               width: ad.size.width.toDouble(),
  //               child: AdWidget(ad: ad),
  //             ),
  //           )
  //         : null,
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      height: AppDimensions.bannerHeight,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
