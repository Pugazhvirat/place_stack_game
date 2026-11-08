import 'dart:math' as math;

import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/game/entities/falling_piece.dart';
import 'package:place_stack/game/mechanics/cutoff.dart';
import 'package:place_stack/game/mechanics/overlap.dart';
import 'package:place_stack/game/mechanics/perfect_landing.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

enum PlacementType { perfect, partial, miss }

class PlacementResult {
  const PlacementResult({required this.type, this.placed, this.piece});
  final PlacementType type;

  /// New top block (null on miss).
  final Block? placed;

  /// Falling remainder (partial) or the whole block (miss).
  final FallingPiece? piece;
}

abstract final class Placement {
  /// Resolves where [moving] (frozen at its tap x) ends up on [base].
  static PlacementResult resolve({
    required Block base,
    required Block moving,
    required double targetY,
    required math.Random random,
  }) {
    final overlap = OverlapCalculator.calculate(base: base, moving: moving);

    if (overlap == null) {
      final away = moving.centerX < base.centerX ? -1.0 : 1.0;
      return PlacementResult(
        type: PlacementType.miss,
        piece: FallingPiece(
          block: moving.copyWith(),
          // velocityX: away * GameConstants.fallKickX,
          velocityX: away * GameConstants.fallKickX,
          //velocityY: GameConstants.dropInitialVelocity,
          velocityY: 0,
          // angularVelocity:
          //     away *
          //     (GameConstants.fallMinSpin + random.nextDouble() * GameConstants.fallExtraSpin),
          angularVelocity:
              away *
              (GameConstants.fallMinSpin + random.nextDouble() * GameConstants.fallExtraSpin),
        ),
      );
    }

    if (PerfectLanding.isPerfect(base, moving)) {
      return PlacementResult(
        type: PlacementType.perfect,
        placed: Block(
          x: base.x,
          y: targetY,
          width: base.width,
          height: moving.height,
          colorIndex: moving.colorIndex,
        ),
      );
    }

    final cut = Cutoff.apply(moving: moving, overlap: overlap, landedY: targetY, random: random);
    return PlacementResult(type: PlacementType.partial, placed: cut.kept, piece: cut.piece);
  }
}
