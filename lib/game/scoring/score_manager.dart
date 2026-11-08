import 'dart:math' as math;

import 'package:place_stack/shared/constants/game_constants.dart';

abstract final class ScoreManager {
  static const int basePoints = 1;

  /// Bonus for the current perfect streak (1, 2, ... capped).
  static int perfectBonus(int streak) =>
      streak <= 0 ? 0 : math.min(streak, GameConstants.maxPerfectBonus);

  static int pointsFor({required bool perfect, required int streak}) =>
      basePoints + (perfect ? perfectBonus(streak) : 0);
}
