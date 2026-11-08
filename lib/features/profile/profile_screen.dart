import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';
import 'package:place_stack/shared/extensions/number_extensions.dart';
import 'package:place_stack/shared/models/player.dart';
import 'package:place_stack/shared/widgets/app_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: ref.read(storageServiceProvider).playerName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _name.text.trim();
    if (value.isEmpty) return;
    await ref.read(storageServiceProvider).setPlayerName(value);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('saved'))));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final storage = ref.watch(storageServiceProvider);
    final player = Player(
      name: storage.playerName,
      bestScore: state.bestScore,
      coins: state.coins,
      gamesPlayed: storage.gamesPlayed,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.surfaceLight,
            child: Icon(Icons.person_rounded, size: 52, color: AppColors.cyan),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            maxLength: 16,
            textAlign: TextAlign.center,
            style: AppTypography.heading,
            decoration: InputDecoration(
              labelText: context.tr('player_name'),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 8),
          AppButton(label: context.tr('save'), onPressed: _save, height: 48),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _Stat(label: context.tr('best'), value: player.bestScore.withSeparators)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(label: context.tr('coins'), value: player.coins.withSeparators)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(label: context.tr('games_played'), value: player.gamesPlayed.withSeparators)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: AppTypography.title)),
          const SizedBox(height: 2),
          FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: AppTypography.caption)),
        ],
      ),
    );
  }
}
