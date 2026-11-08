import 'dart:math' as math;
import 'dart:ui';

/// Screen shake + full-screen flash.
class ScreenEffect {
  double _shakeTime = 0;
  double _shakeDuration = 0;
  double _intensity = 0;
  double _flash = 0;
  Color _flashColor = const Color(0xFFFFFFFF);
  double _clock = 0;

  void shake({double intensity = 6, double duration = 0.25}) {
    _intensity = intensity;
    _shakeDuration = duration;
    _shakeTime = duration;
  }

  void flash(Color color, {double strength = 0.25}) {
    _flashColor = color;
    _flash = strength;
  }

  void update(double dt) {
    _clock += dt;
    if (_shakeTime > 0) _shakeTime = math.max(0, _shakeTime - dt);
    if (_flash > 0) _flash = math.max(0, _flash - dt * 1.2);
  }

  Offset get offset {
    if (_shakeTime <= 0 || _shakeDuration <= 0) return Offset.zero;
    final decay = _shakeTime / _shakeDuration;
    return Offset(
      math.sin(_clock * 70) * _intensity * decay,
      math.cos(_clock * 83) * _intensity * decay,
    );
  }

  void renderFlash(Canvas canvas, Size size) {
    if (_flash <= 0) return;
    canvas.drawRect(Offset.zero & size, Paint()..color = _flashColor.withValues(alpha: _flash));
  }

  void clear() {
    _shakeTime = 0;
    _flash = 0;
  }
}
