import 'dart:ui';

/// A block in world coordinates (x/y = top-left, y grows downward).
class Block {
  Block({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.colorIndex,
  });

  double x;
  double y;
  double width;
  double height;
  final int colorIndex;

  double get left => x;
  double get right => x + width;
  double get top => y;
  double get bottom => y + height;
  double get centerX => x + width / 2;
  Rect get rect => Rect.fromLTWH(x, y, width, height);

  Block copyWith({double? x, double? y, double? width, double? height, int? colorIndex}) => Block(
        x: x ?? this.x,
        y: y ?? this.y,
        width: width ?? this.width,
        height: height ?? this.height,
        colorIndex: colorIndex ?? this.colorIndex,
      );
}
