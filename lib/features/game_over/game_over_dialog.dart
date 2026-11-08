import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/ads/ad_service.dart';
import 'package:place_stack/core/analytics/analytics_service.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';

enum GameOverAction { playAgain, home, continueWithAd, continueWithCoins }

/// Full-screen "Continue?" overlay shown over the zoomed-out tower.
class GameOverDialog extends ConsumerWidget {
  const GameOverDialog({super.key, required this.score});

  final int score;

  static const Color _ink = Color(0xFF2B2B2B);
  static const Color _ring = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runColor = ref.watch(runColorProvider);
    // final overlay = Color.lerp(runColor, const Color(0xFF000000), 0.55)!.withValues(alpha: 0.85);
    final overlay = runColor.computeLuminance() < 0.05
        ? const Color(0xFF3A3A40).withValues(alpha: 0.9)
        : Color.lerp(runColor, const Color(0xFF000000), 0.55)!.withValues(alpha: 0.85);
    final adService = ref.read(adServiceProvider);

    Future<void> continueWithAd() async {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final notReady = context.tr('ad_not_ready');
      final earned = await adService.showRewarded();
      if (earned) {
        ref.read(analyticsServiceProvider).rewardedAd('continue');
        navigator.pop(GameOverAction.continueWithAd);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(notReady)));
      }
    }

    return PopScope(
      canPop: false,
      child: Material(
        color: overlay,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$score',
                  style: AppTypography.score.copyWith(
                    fontSize: 110,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.tr('watch_video_continue'),
                  textAlign: TextAlign.center,
                  style: AppTypography.title.copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              ValueListenableBuilder<bool>(
                valueListenable: adService.rewardedReady,
                builder: (context, ready, _) => GestureDetector(
                  onTap: ready ? continueWithAd : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      //border: Border.all(color: const Color(0xFF111111), width: 2),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFFFF), Color(0xFFE6E6E6)],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.play_circle_outline_rounded, size: 54, color: _ink),
                              if (!ready)
                                SizedBox(
                                  width: 54,
                                  height: 54,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                    color: Colors.grey.withValues(alpha: 0.9),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.tr('continue_q'),
                          style: AppTypography.title.copyWith(
                            fontSize: 38,
                            fontWeight: FontWeight.w400,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(GameOverAction.home),
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: _ring, width: 7),
                  ),
                  child: const Icon(Icons.close_rounded, size: 46, color: _ring),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:place_stack/app/config/app_config.dart';
// import 'package:place_stack/app/theme/colors.dart';
// import 'package:place_stack/app/theme/typography.dart';
// import 'package:place_stack/core/ads/ad_service.dart';
// import 'package:place_stack/core/analytics/analytics_service.dart';
// import 'package:place_stack/game/state/game_state.dart';
// import 'package:place_stack/shared/extensions/context_extensions.dart';
// import 'package:place_stack/shared/widgets/app_button.dart';
// import 'package:place_stack/shared/widgets/app_dialog.dart';
// import 'package:place_stack/shared/widgets/score_display.dart';
//
// enum GameOverAction { playAgain, home, continueWithAd, continueWithCoins }
//
// /// Shown as an overlay on top of the game (not a separate route).
// class GameOverDialog extends ConsumerWidget {
//   const GameOverDialog({super.key, required this.score});
//
//   final int score;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(gameStateProvider);
//     final canAfford = state.coins >= AppConfig.continueCoinCost;
//
//     Future<void> continueWithAd() async {
//       final messenger = ScaffoldMessenger.of(context);
//       final navigator = Navigator.of(context);
//       final notReady = context.tr('ad_not_ready');
//       final earned = await ref.read(adServiceProvider).showRewarded();
//       if (earned) {
//         ref.read(analyticsServiceProvider).rewardedAd('continue');
//         navigator.pop(GameOverAction.continueWithAd);
//       } else {
//         messenger.showSnackBar(SnackBar(content: Text(notReady)));
//       }
//     }
//
//     void continueWithCoins() {
//       if (ref.read(gameStateProvider.notifier).spendCoins(AppConfig.continueCoinCost)) {
//         Navigator.of(context).pop(GameOverAction.continueWithCoins);
//       }
//     }
//
//     return PopScope(
//       canPop: false,
//       child: AppDialog(
//         title: context.tr('game_over'),
//         onClose: () => Navigator.of(context).pop(GameOverAction.home),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               context.tr('your_score'),
//               style: AppTypography.body.copyWith(color: AppColors.textSecondary),
//             ),
//             const SizedBox(height: 4),
//             ScoreDisplay(score: score, best: state.bestScore, fontSize: 56),
//             const SizedBox(height: 16),
//             AppButton(
//               style: AppButtonStyle.green,
//               icon: Icons.play_circle_fill_rounded,
//               label: context.tr('continue_here'),
//               subtitle: context.tr('watch_ad_keep_playing'),
//               onPressed: continueWithAd,
//             ),
//             const SizedBox(height: 10),
//             // AppButton(
//             //   style: AppButtonStyle.purple,
//             //   icon: Icons.monetization_on_rounded,
//             //   label: context.tr('continue_here'),
//             //   subtitle: context.tr('use_coins', args: {'n': AppConfig.continueCoinCost}),
//             //   trailing: Row(
//             //     mainAxisSize: MainAxisSize.min,
//             //     children: [
//             //       const CoinIcon(size: 20),
//             //       const SizedBox(width: 4),
//             //       Text('${AppConfig.continueCoinCost}', style: AppTypography.heading),
//             //     ],
//             //   ),
//             //   onPressed: canAfford ? continueWithCoins : null,
//             // ),
//             const SizedBox(height: 10),
//             AppButton(
//               style: AppButtonStyle.blue,
//               icon: Icons.play_arrow_rounded,
//               label: context.tr('play_again'),
//               onPressed: () => Navigator.of(context).pop(GameOverAction.playAgain),
//             ),
//             const SizedBox(height: 6),
//             // TextButton.icon(
//             //   onPressed: () => Navigator.of(context).pop(GameOverAction.home),
//             //   icon: const Icon(Icons.home_rounded, color: AppColors.textSecondary),
//             //   label: Text(context.tr('home'), style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
