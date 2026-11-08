import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/core/audio/audio_service.dart';
import 'package:place_stack/core/haptics/haptic_service.dart';

class AppIconButton extends ConsumerWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: tooltip ?? '',
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: AppColors.surface.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            onTap: () {
              ref.read(hapticServiceProvider).button();
              ref.read(audioServiceProvider).play(SoundEffect.button);
              onPressed();
            },
            child: Icon(icon, color: color, size: size * 0.58),
          ),
        ),
      ),
    );
  }
}
