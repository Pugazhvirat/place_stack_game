import 'dart:ui';

/// Simple white border flashed around a block on a perfect landing.
class GlowEffect {
  static const double _life = 0.5;
  Rect? _rect;
  double _age = _life;

  void trigger(Rect rect, Color color) {
    _rect = rect;
    _age = 0;
  }

  void update(double dt) => _age += dt;
  void clear() => _age = _life;

  void render(Canvas canvas) {
    final rect = _rect;
    if (rect == null || _age >= _life) return;
    final t = _age / _life;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 1 - t);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
  }
}
