import 'package:flutter/material.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const List<(IconData, Color)> _steps = <(IconData, Color)>[
    (Icons.touch_app_rounded, AppColors.neonBlue),
    (Icons.content_cut_rounded, AppColors.purple),
    (Icons.auto_awesome_rounded, AppColors.green),
    (Icons.warning_amber_rounded, AppColors.gold),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final (icon, color) = _steps[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.dialogCardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            //border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('htp_${i + 1}_title'), style: AppTypography.heading),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('htp_${i + 1}_body'),
                      style: AppTypography.caption.copyWith(fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
