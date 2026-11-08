extension IntFormatting on int {
  /// 1250 -> "1,250"
  String get withSeparators {
    final digits = abs().toString();
    final buffer = StringBuffer(this < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

extension DoubleMath on double {
  double lerpTo(double target, double t) => this + (target - this) * t;
  double clampTo(double min, double max) => this < min ? min : (this > max ? max : this);
}
