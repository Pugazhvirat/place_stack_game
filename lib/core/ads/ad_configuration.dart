import 'package:flutter/foundation.dart';

/// Google's public TEST unit IDs. Replace with real IDs before release.
abstract final class AdConfiguration {
  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  static String get bannerUnitId =>
      _ios ? 'ca-app-pub-3940256099942544/2934735716' : 'ca-app-pub-3940256099942544/6300978111';
  static String get interstitialUnitId =>
      _ios ? 'ca-app-pub-3940256099942544/4411468910' : 'ca-app-pub-3940256099942544/1033173712';
  static String get rewardedUnitId =>
      _ios ? 'ca-app-pub-3940256099942544/1712485313' : 'ca-app-pub-3940256099942544/5224354917';
}
