import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/game/state/game_status.dart';
import 'package:place_stack/shared/models/skin.dart';

class GameState {
  const GameState({
    required this.score,
    required this.bestScore,
    required this.coins,
    required this.status,
  });

  final int score;
  final int bestScore;
  final int coins;
  final GameStatus status;

  GameState copyWith({int? score, int? bestScore, int? coins, GameStatus? status}) => GameState(
    score: score ?? this.score,
    bestScore: bestScore ?? this.bestScore,
    coins: coins ?? this.coins,
    status: status ?? this.status,
  );
}

class GameStateNotifier extends Notifier<GameState> {
  StorageService get _storage => ref.read(storageServiceProvider);

  @override
  GameState build() => GameState(
    score: 0,
    bestScore: _storage.bestScore,
    coins: _storage.coins,
    status: GameStatus.ready,
  );

  void setScore(int score) {
    final best = math.max(state.bestScore, score);
    if (best != state.bestScore) _storage.setBestScore(best);
    state = state.copyWith(score: score, bestScore: best);
  }

  void addCoins(int amount) {
    final total = state.coins + amount;
    _storage.setCoins(total);
    state = state.copyWith(coins: total);
  }

  /// Returns false (and changes nothing) when the player cannot afford it.
  bool spendCoins(int amount) {
    if (state.coins < amount) return false;
    final total = state.coins - amount;
    _storage.setCoins(total);
    state = state.copyWith(coins: total);
    return true;
  }

  void setStatus(GameStatus status) => state = state.copyWith(status: status);

  void resetRun() => state = state.copyWith(score: 0, status: GameStatus.ready);
}

final gameStateProvider = NotifierProvider<GameStateNotifier, GameState>(GameStateNotifier.new);

class RunColorNotifier extends Notifier<Color> {
  final math.Random _random = math.Random();

  Color? get _fixed => Skin.byId(ref.read(storageServiceProvider).selectedSkin).fixedColor;

  //Color _randomColor() => AppColors.runColors[_random.nextInt(AppColors.runColors.length)];
  Color _randomColor() {
    final palette = Skin.byId(ref.read(storageServiceProvider).selectedSkin).palette;
    return palette[_random.nextInt(palette.length)];
  }

  @override
  Color build() => _fixed ?? _randomColor();

  /// New random color for the next run (skins with a fixed color keep theirs).
  void pickNext() {
    final fixed = _fixed;
    if (fixed != null) {
      state = fixed;
      return;
    }
    var next = state;
    while (next == state) {
      next = _randomColor();
    }
    state = next;
  }
}

final runColorProvider = NotifierProvider<RunColorNotifier, Color>(RunColorNotifier.new);
