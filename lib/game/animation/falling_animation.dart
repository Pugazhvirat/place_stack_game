import 'package:place_stack/game/entities/falling_piece.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

/// Physics (gravity + spin) for every falling piece; removes them once off-screen.
class FallingAnimation {
  final List<FallingPiece> pieces = <FallingPiece>[];

  void add(FallingPiece piece) => pieces.add(piece);
  void clear() => pieces.clear();

  void update(double dt, {required double removeBelowY}) {
    for (final p in pieces) {
      p.velocityY += GameConstants.fallGravity * dt;
      p.block.x += p.velocityX * dt;
      p.block.y += p.velocityY * dt;
      p.rotation += p.angularVelocity * dt;
    }
    pieces.removeWhere((p) => p.block.y > removeBelowY + GameConstants.fallRemoveMargin);
  }
}
