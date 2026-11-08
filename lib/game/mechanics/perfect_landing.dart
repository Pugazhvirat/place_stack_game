import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

abstract final class PerfectLanding {
  static bool isPerfect(Block base, Block moving) =>
      (base.x - moving.x).abs() <= GameConstants.perfectTolerance;
}
