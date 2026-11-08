import 'dart:ui';

import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/game/entities/falling_piece.dart';
import 'package:place_stack/game/entities/moving_block.dart';
import 'package:place_stack/game/entities/stack.dart';
import 'package:place_stack/game/rendering/block_renderer.dart';
import 'package:place_stack/shared/constants/game_constants.dart';

class StackRenderer {
  StackRenderer(this.blocks);
  final BlockRenderer blocks;

  /// Draws only blocks inside [viewTop]..[viewBottom] (world y).
  void renderStack(
    Canvas canvas,
    BlockStack stack, {
    required double viewTop,
    required double viewBottom,
    double topHeightScale = 1,
  }) {
    final list = stack.blocks;
    final last = list.length - 1;
    for (var i = 0; i <= last; i++) {
      final b = list[i];
      if (b.bottom < viewTop || b.top > viewBottom) continue;
      blocks.render(canvas, b, heightScale: i == last ? topHeightScale : 1);
    }
  }

  void renderMoving(Canvas canvas, MovingBlock? moving) {
    if (moving != null) blocks.render(canvas, moving.block);
  }

  void renderPieces(Canvas canvas, Iterable<FallingPiece> pieces) {
    for (final p in pieces) {
      blocks.render(canvas, p.block, rotation: p.rotation, alpha: 0.95);
    }
  }

  /// Dashed track with arrows (screen space), like the reference gameplay image.
  void renderTrack(Canvas canvas, double y) {
    final paint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const left = 30.0;
    final right = GameConstants.worldWidth - 30;
    for (var x = left; x < right; x += 9) {
      canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
    }
    paint.strokeWidth = 2.2;
    for (final side in <double>[-1, 1]) {
      final tipX = side < 0 ? 10.0 : GameConstants.worldWidth - 10;
      final path = Path()
        ..moveTo(tipX - side * 9, y - 11)
        ..lineTo(tipX, y)
        ..lineTo(tipX - side * 9, y + 11);
      canvas.drawPath(path, paint);
    }
  }
}
