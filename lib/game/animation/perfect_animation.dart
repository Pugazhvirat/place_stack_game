import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:place_stack/app/theme/colors.dart';

/// "Perfect +N" pill, like the reference gameplay image.
class PerfectAnimation {
  PerfectAnimation(this.bonus);
  final int bonus;
  static const double duration = 0.95;
  double _t = 0;

  bool get isDone => _t >= duration;
  void update(double dt) => _t += dt;

  void render(Canvas canvas, Offset center) {
    final pop = (_t / 0.15).clamp(0.0, 1.0).toDouble();
    final scale = 0.6 + 0.4 * Curves.easeOutBack.transform(pop);
    final fade = ((duration - _t) / 0.3).clamp(0.0, 1.0).toDouble();
    final rise = -14 * (_t / duration);

    final painter = TextPainter(
      text: TextSpan(
        text: 'Perfect +$bonus',
        style: TextStyle(
          color: const Color(0xFFFFFFFF).withValues(alpha: fade),
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(center.dx, center.dy + rise);
    canvas.scale(scale);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: painter.width + 36,
      height: painter.height + 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
      Paint()..color = AppColors.green.withValues(alpha: 0.95 * fade),
    );
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }
}
