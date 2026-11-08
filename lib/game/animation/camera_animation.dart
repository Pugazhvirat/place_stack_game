import 'dart:math' as math;

import 'package:place_stack/shared/constants/game_constants.dart';

/// Smoothly scrolls the world downward as the stack grows.
class CameraAnimation {
  double offset = 0;
  double target = 0;

  void update(double dt) {
    final k = math.min(1.0, GameConstants.cameraSmoothing * dt);
    offset += (target - offset) * k;
    if ((target - offset).abs() < 0.01) offset = target;
  }

  void reset() {
    offset = 0;
    target = 0;
  }
}
