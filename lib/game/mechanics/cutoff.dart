import 'dart:math' as math;

import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/game/entities/falling_piece.dart';
import 'package:place_stack/game/mechanics/overlap.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

class CutoffResult {
  const CutoffResult({required this.kept, this.piece});
  final Block kept;
  final FallingPiece? piece;
}

abstract final class Cutoff {
  /// Really changes the geometry: [kept] is the overlapping part (new top block),
  /// [piece] is the sliced-off remainder that will fall.
  static CutoffResult apply({
    required Block moving,
    required Overlap overlap,
    required double landedY,
    required math.Random random,
  }) {
    final kept = Block(
      x: overlap.left,
      y: landedY,
      width: overlap.width,
      height: moving.height,
      colorIndex: moving.colorIndex,
    );
    final cutWidth = moving.width - overlap.width;
    if (cutWidth <= 0.001) return CutoffResult(kept: kept);

    final cutOnLeft = moving.left < overlap.left - 0.001;
    final piece = FallingPiece(
      block: Block(
        x: cutOnLeft ? moving.left : overlap.right,
        y: landedY,
        width: cutWidth,
        height: moving.height,
        colorIndex: moving.colorIndex,
      ),
      velocityX: (cutOnLeft ? -1 : 1) * GameConstants.fallKickX,
      angularVelocity: (cutOnLeft ? -1 : 1) *
          (GameConstants.fallMinSpin + random.nextDouble() * GameConstants.fallExtraSpin),
    );
    return CutoffResult(kept: kept, piece: piece);
  }
}
