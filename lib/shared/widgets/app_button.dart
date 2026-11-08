import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/audio/audio_service.dart';
import 'package:place_stack/core/haptics/haptic_service.dart';

enum AppButtonStyle { blue, green, purple, gold }

class AppButton extends ConsumerWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subtitle,
    this.icon,
    this.trailing,
    this.style = AppButtonStyle.blue,
    this.height = 60,
    this.expand = true,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final double height;
  final bool expand;

  List<Color> get _colors => switch (style) {
        AppButtonStyle.blue => const [Color(0xFF1E8CFF), AppColors.blueDark],
        AppButtonStyle.green => const [Color(0xFF2BE67A), AppColors.greenDark],
        AppButtonStyle.purple => const [Color(0xFFA14CFF), AppColors.purpleDark],
        AppButtonStyle.gold => const [AppColors.gold, AppColors.goldDark],
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(AppDimensions.radiusM);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _colors,
          ),
          boxShadow: [BoxShadow(color: _colors.first.withValues(alpha: 0.35), blurRadius: 14)],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled
                ? () {
                    ref.read(hapticServiceProvider).button();
                    ref.read(audioServiceProvider).play(SoundEffect.button);
                    onPressed!();
                  }
                : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height, minWidth: expand ? double.infinity : 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: icon == null ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 30, color: Colors.white),
                      const SizedBox(width: 12),
                    ],
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: icon == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                        children: [
                          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.button),
                          if (subtitle != null)
                            Text(subtitle!,
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.caption.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[const SizedBox(width: 10), trailing!],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
