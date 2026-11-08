import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/shared/extensions/number_extensions.dart';

class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE066), AppColors.goldDark],
        ),
      ),
      child: Icon(Icons.star_rounded, size: size * 0.7, color: const Color(0xFFFFF4C2)),
    );
  }
}

class CoinDisplay extends StatelessWidget {
  const CoinDisplay({super.key, required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CoinIcon(),
        const SizedBox(width: 6),
        Text(coins.withSeparators, style: AppTypography.heading),
      ],
    );
  }
}
