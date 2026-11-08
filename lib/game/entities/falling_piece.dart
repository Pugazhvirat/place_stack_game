import 'package:place_stack/game/entities/block.dart';

/// A cut-off (or missed) block falling out of the play area.
class FallingPiece {
  FallingPiece({
    required this.block,
    required this.velocityX,
    required this.angularVelocity,
    this.velocityY = 0,
  });

  final Block block;
  double velocityX;
  double velocityY;
  double angularVelocity;
  double rotation = 0;
}
