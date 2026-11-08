import 'dart:math' as math;

import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

class Overlap {
  const Overlap(this.left, this.right);
  final double left;
  final double right;
  double get width => right - left;
}

abstract final class OverlapCalculator {
  /// Exact horizontal overlap, or null when the blocks do not meaningfully overlap.
  static Overlap? calculate({required Block base, required Block moving}) {
    final left = math.max(base.left, moving.left);
    final right = math.min(base.right, moving.right);
    if (right - left < GameConstants.minOverlapWidth) return null;
    return Overlap(left, right);
  }
}
