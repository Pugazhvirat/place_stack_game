import 'dart:ui';

import 'package:place_stack/game/entities/block.dart';

/// Fading ghost copies behind the moving block.
class TrailEffect {
  static const int _maxSamples = 6;
  final List<double> _xs = <double>[];

  void record(double x) {
    _xs.add(x);
    if (_xs.length > _maxSamples) _xs.removeAt(0);
  }

  void clear() => _xs.clear();

  void render(Canvas canvas, Block block, Color color) {
    final paint = Paint();
    for (var i = 0; i < _xs.length; i++) {
      final t = (i + 1) / (_xs.length + 1);
      paint.color = color.withValues(alpha: 0.28 * t * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(_xs[i], block.y, block.width, block.height),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }
}
