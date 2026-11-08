import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:place_stack/app/theme/colors.dart';

class _Star {
  const _Star(this.x, this.y, this.size, this.depth, this.phase);
  final double x, y, size, depth, phase;
}

/// Placeholder gradient + star-field background.
///
/// To use artwork later: load a `ui.Image` and assign [image]
/// (e.g. `game.background.image = myImage;`). It is drawn with BoxFit.cover.
class BackgroundRenderer {
  BackgroundRenderer({this.image, int starCount = 70, int seed = 7})
    : _stars = _generate(starCount, seed);

  ui.Image? image;
  Color? tint;
  static const double tintStrength = 0.40;
  final List<_Star> _stars;
  final Paint _paint = Paint();

  static List<_Star> _generate(int count, int seed) {
    final r = math.Random(seed);
    return List<_Star>.generate(
      count,
      (_) => _Star(
        r.nextDouble(),
        r.nextDouble(),
        1 + r.nextDouble() * 1.8,
        0.3 + r.nextDouble(),
        r.nextDouble() * 6.28,
      ),
    );
  }

  void render(Canvas canvas, Size size, double cameraOffset, double time) {
    final rect = Offset.zero & size;
    final img = image;
    if (img != null) {
      paintImage(canvas: canvas, rect: rect, image: img, fit: BoxFit.cover);
      return;
    }
    // final t = tint;
    // if (t != null) {
    //   _paint.shader = null;
    //   _paint.color = Color.lerp(const Color(0xFFFFFFFF), t, tintStrength)!;
    //   canvas.drawRect(rect, _paint);
    //   return;
    // }
    final t = tint;
    if (t != null) {
      if (t.computeLuminance() < 0.05) {
        // Dark skins (Stone): flat dark background.
        _paint.shader = null;
        _paint.color = const Color(0xFFF2F2F4);
        canvas.drawRect(rect, _paint);
        return;
      }
      // Flat light tint of the box color.
      _paint.shader = null;
      _paint.color = Color.lerp(const Color(0xFFFFFFFF), t, tintStrength)!;
      canvas.drawRect(rect, _paint);

      // Round bubbles that stay in place and softly pulse.
      final bubble = Paint()..style = PaintingStyle.fill;
      for (final s in _stars) {
        final k = 0.5 + 0.5 * math.sin(time * 1.2 + s.phase * 3);
        final radius = (1.5 + s.size * 1.2) * (0.7 + 0.5 * k);
        final x = s.x * size.width;
        final y = s.y * size.height + math.sin(time * 0.7 + s.phase) * 3;

        bubble.color = const Color(0xFFFFFFFF).withValues(alpha: 0.25 + 0.4 * k);
        canvas.drawCircle(Offset(x, y), radius, bubble);
      }
      return;
    }
    _paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[AppColors.backgroundTop, AppColors.backgroundBottom],
    ).createShader(rect);
    canvas.drawRect(rect, _paint);
    _paint.shader = null;

    for (final s in _stars) {
      final y = (s.y * size.height + cameraOffset * 0.08 * s.depth) % size.height;
      final twinkle = 0.5 + 0.5 * math.sin(time * 1.5 + s.phase);
      _paint.color = AppColors.cyan.withValues(
        alpha: 0.25 + 0.5 * twinkle * s.depth.clamp(0.0, 1.0),
      );
      canvas.drawCircle(Offset(s.x * size.width, y), s.size * 0.6, _paint);
    }
  }
}
