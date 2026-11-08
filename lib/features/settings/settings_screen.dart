import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/router.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/audio/audio_service.dart';
import 'package:place_stack/core/localization/localization_service.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/shared/constants/app_constants.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late double _volume;

  @override
  void initState() {
    super.initState();
    _volume = ref.read(storageServiceProvider).volume;
  }

  /// No url_launcher dependency (not in the approved package list), so links are copied.
  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('link_copied'))));
  }

  void _pickLanguage() {
    showPanel(
      context,
      'language',
      Consumer(
        builder: (ctx, ref, _) {
          final current = ref.watch(localeProvider).languageCode;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              for (final entry in LocalizationService.languageNames.entries)
                _Tile(
                  icon: Icons.language_rounded,
                  color: AppColors.neonBlue,
                  label: entry.value,
                  onTap: () async {
                    await ref.read(localeProvider.notifier).setLanguage(entry.key);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  trailing: current == entry.key
                      ? const Icon(Icons.check_rounded, color: AppColors.green)
                      : const SizedBox.shrink(),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final locale = ref.watch(localeProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        _Tile(
          icon: Icons.vibration_rounded,
          color: AppColors.red,
          label: context.tr('vibrate'),
          trailing: Switch(
            value: storage.hapticsEnabled,
            onChanged: (v) async {
              await storage.setHapticsEnabled(v);
              if (mounted) setState(() {});
            },
          ),
        ),
        _Tile(
          icon: Icons.language_rounded,
          color: AppColors.neonBlue,
          label: context.tr('language'),
          onTap: _pickLanguage,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocalizationService.languageNames[locale.languageCode] ?? locale.languageCode,
                style: AppTypography.body,
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        _Tile(
          icon: _volume <= 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          color: AppColors.gold,
          label: context.tr('volume'),
          trailing: SizedBox(
            width: 150,
            child: Slider(
              value: _volume,
              // onChanged: (v) => setState(() => _volume = v),
              // onChangeEnd: (v) async {
              //   await ref.read(audioServiceProvider).setVolume(v);
              //   await storage.setSoundEnabled(v > 0);
              // },
              onChanged: (v) {
                setState(() => _volume = v);
                ref.read(audioServiceProvider).setVolume(v);
              },
              onChangeEnd: (v) async {
                await storage.setSoundEnabled(v > 0);
                if (v > 0) ref.read(audioServiceProvider).play(SoundEffect.drop);
              },
            ),
          ),
        ),
        _Tile(
          icon: Icons.star_rounded,
          color: AppColors.gold,
          label: context.tr('rate_us'),
          onTap: () => _copy(AppConstants.rateUrl),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        _Tile(
          icon: Icons.shield_rounded,
          color: AppColors.purple,
          label: context.tr('privacy_policy'),
          onTap: () => _copy(AppConstants.privacyPolicyUrl),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        _Tile(
          icon: Icons.mail_rounded,
          color: AppColors.neonBlue,
          label: context.tr('mail'),
          onTap: () => _copy(AppConstants.supportEmail),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.dialogCardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body,
                    ),
                  ),
                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
