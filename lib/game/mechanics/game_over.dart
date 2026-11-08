import 'package:place_stack/game/mechanics/placement.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

abstract final class GameOverRule {
  static bool isGameOver(PlacementResult result) => result.type == PlacementType.miss;
}

/// Waits for the missed block to fall for a moment, then signals game over once.
class GameOverTracker {
  bool _active = false;
  double _timer = 0;

  bool get isActive => _active;

  void begin() {
    _active = true;
    _timer = 0;
  }

  /// Returns true exactly once when the delay has elapsed.
  bool update(double dt) {
    if (!_active) return false;
    _timer += dt;
    if (_timer >= GameConstants.missGameOverDelay) {
      _active = false;
      return true;
    }
    return false;
  }

  void reset() {
    _active = false;
    _timer = 0;
  }
}
