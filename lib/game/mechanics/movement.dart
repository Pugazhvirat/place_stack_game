import 'dart:math' as math;

import 'package:place_stack/game/entities/moving_block.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

abstract final class Movement {
  /// Moves the block and bounces it at the track ends.
  static void advance(MovingBlock moving, double dt) {
    final b = moving.block;
    b.x += moving.direction * moving.speed * dt;
    if (b.x <= moving.minX) {
      b.x = moving.minX;
      moving.direction = 1;
    } else if (b.x >= moving.maxX) {
      b.x = moving.maxX;
      moving.direction = -1;
    }
  }

  static double speedFor(int score) =>
      math.min(GameConstants.maxSpeed, GameConstants.baseSpeed + GameConstants.speedStep * score);
}
