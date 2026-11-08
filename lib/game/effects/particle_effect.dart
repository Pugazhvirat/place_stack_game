import 'dart:math' as math;
import 'dart:ui';

class _Particle {
  _Particle(this.x, this.y, this.vx, this.vy, this.size, this.life, this.color);
  double x, y, vx, vy;
  final double size;
  final double life;
  final Color color;
  double age = 0;
}

class ParticleEffect {
  final List<_Particle> _particles = <_Particle>[];
  final Paint _paint = Paint();

  /// When set, every block uses this single color instead of the palette.
  Color? solidColor;

  void burst({
    required double x,
    required double y,
    required Color color,
    required math.Random random,
    int count = 22,
  }) {
    for (var i = 0; i < count; i++) {
      final angle = -math.pi * random.nextDouble(); // upward fan
      final speed = 80 + random.nextDouble() * 200;
      _particles.add(
        _Particle(
          x,
          y,
          math.cos(angle) * speed,
          math.sin(angle) * speed,
          2 + random.nextDouble() * 3.5,
          0.5 + random.nextDouble() * 0.5,
          random.nextBool() ? color : const Color(0xFFFFFFFF),
        ),
      );
    }
  }

  void update(double dt) {
    for (final p in _particles) {
      p.age += dt;
      p.vy += 420 * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
    }
    _particles.removeWhere((p) => p.age >= p.life);
  }

  void render(Canvas canvas) {
    for (final p in _particles) {
      final a = (1 - p.age / p.life).clamp(0.0, 1.0).toDouble();
      _paint.color = p.color.withValues(alpha: a);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(p.x, p.y), width: p.size, height: p.size),
        _paint,
      );
    }
  }

  void clear() => _particles.clear();
}
