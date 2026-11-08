import 'package:place_stack/game/entities/block.dart';

/// The block sliding horizontally above the stack.
class MovingBlock {
  MovingBlock({
    required this.block,
    required this.direction,
    required this.speed,
    required this.minX,
    required this.maxX,
  });

  final Block block;
  double direction; // -1 left, +1 right
  final double speed;
  final double minX;
  final double maxX;
}
