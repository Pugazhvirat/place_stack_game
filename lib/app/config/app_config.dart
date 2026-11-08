abstract final class AppConfig {
  /// Leaderboard backend. Empty string = use local demo data.
  static const String apiBaseUrl = '';
  static const String removeAdsProductId = 'remove_ads';
  //static const String removeAdsFallbackPrice = '0.99';v
  static const String removeAdsFallbackPrice = '\$1.00';
  static const int continueCoinCost = 50;
  static const int interstitialEveryNGameOvers = 3;
  static const bool analyticsEnabled = true;
}
