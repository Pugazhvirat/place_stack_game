import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';

/// Card-style dialog used by Game Over, Pause, Language picker...
/// Scrolls internally so it can never overflow small screens.
class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.title, required this.child, this.onClose});

  final String title;
  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.dialogMaxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(color: AppColors.neonBlue.withValues(alpha: 0.25), blurRadius: 24),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: onClose == null
                          ? null
                          : IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                            ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
