import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/config/app_config.dart';

typedef AnalyticsSink = void Function(String name, Map<String, Object?> params);

class AnalyticsService {
  AnalyticsService({AnalyticsSink? sink}) : _sink = sink;
  final AnalyticsSink? _sink;

  void log(String name, [Map<String, Object?> params = const <String, Object?>{}]) {
    if (!AppConfig.analyticsEnabled) return;
    _sink?.call(name, params);
    if (kDebugMode) debugPrint('[analytics] $name $params');
  }

  void gameStarted() => log('game_started');
  void gameRestarted() => log('game_restarted');
  void blockPlaced(int score) => log('block_placed', {'score': score});
  void perfectLanding(int streak) => log('perfect_landing', {'streak': streak});
  void gameOver(int score) => log('game_over', {'score': score});
  void rewardedAd(String placement) => log('rewarded_ad', {'placement': placement});
  void purchase(String productId) => log('purchase', {'product': productId});
  void skinSelected(String id) => log('skin_selected', {'skin': id});
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) => AnalyticsService());
