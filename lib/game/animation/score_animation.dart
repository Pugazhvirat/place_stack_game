import 'package:flutter/painting.dart';

class _Popup {
  _Popup(this.text, this.x, this.y, this.color);
  final String text;
  final double x;
  double y;
  final Color color;
  double age = 0;
}

/// Floating "+N" popups above freshly placed blocks (world coordinates).
class ScoreAnimation {
  static const double _life = 0.8;
  final List<_Popup> _popups = <_Popup>[];

  void add(String text, double x, double y, Color color) => _popups.add(_Popup(text, x, y, color));
  void clear() => _popups.clear();

  void update(double dt) {
    for (final p in _popups) {
      p.age += dt;
      p.y -= 60 * dt;
    }
    _popups.removeWhere((p) => p.age >= _life);
  }

  void render(Canvas canvas) {
    for (final p in _popups) {
      final t = p.age / _life;
      final alpha = (1 - t).clamp(0.0, 1.0).toDouble();
      final tp = TextPainter(
        text: TextSpan(
          text: p.text,
          style: TextStyle(
            color: p.color.withValues(alpha: alpha),
            fontSize: 20 + 6 * (1 - t),
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(p.x - tp.width / 2, p.y - tp.height));
    }
  }
}
