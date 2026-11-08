import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';

/// Big score number that "pops" every time it changes.
class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key, required this.score, this.best, this.fontSize = 64});

  final int score;
  final int? best;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          key: ValueKey<int>(score),
          tween: Tween<double>(begin: 1.3, end: 1),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$score', style: AppTypography.score.copyWith(fontSize: fontSize)),
          ),
        ),
        if (best != null)
          Text('${context.tr('best')} $best', style: AppTypography.body.copyWith(color: Colors.white70)),
      ],
    );
  }
}
