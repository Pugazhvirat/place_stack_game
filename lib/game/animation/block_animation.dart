import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

/// Accelerating drop of the moving block down to the stack.
class BlockDropAnimation {
  BlockDropAnimation({required this.block, required this.targetY});
  final Block block;
  final double targetY;
  double _velocity = GameConstants.dropInitialVelocity;

  /// Advances the drop; returns true once the block has landed.
  bool update(double dt) {
    _velocity += GameConstants.dropGravity * dt;
    block.y += _velocity * dt;
    if (block.y >= targetY) {
      block.y = targetY;
      return true;
    }
    return false;
  }
}

/// Short squash-and-settle on the block that was just placed.
class BlockPlaceAnimation {
  static const double duration = 0.22;
  double _t = 0;

  bool get isDone => _t >= duration;

  void update(double dt) => _t += dt;

  /// 0.8 -> 1.0 with a little overshoot.
  double get heightScale {
    final p = (_t / duration).clamp(0.0, 1.0).toDouble();
    final eased = 1 - (1 - p) * (1 - p);
    return 0.8 + 0.2 * eased + (p < 1 ? 0.06 * (1 - p) * p * 4 : 0);
  }
}
