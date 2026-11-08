import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:place_stack/app/router.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/core/ads/ad_service.dart';
import 'package:place_stack/core/analytics/analytics_service.dart';
import 'package:place_stack/core/audio/audio_service.dart';
import 'package:place_stack/core/haptics/haptic_service.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/features/game_over/game_over_dialog.dart';
import 'package:place_stack/game/engine/stack_game.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/game/state/game_status.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';
import 'package:place_stack/shared/models/skin.dart';
import 'package:place_stack/shared/widgets/app_button.dart';
import 'package:place_stack/shared/widgets/app_dialog.dart';
import 'package:place_stack/shared/widgets/score_display.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final StackGame _game;
  late final AudioService _audio;
  bool _dialogOpen = false;
  late final RunColorNotifier _runColorNotifier;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    _audio = ref.read(audioServiceProvider);
    final notifier2 = ref.read(runColorProvider.notifier);
    _runColorNotifier = notifier2;
    _game = StackGame(
      audio: _audio,
      haptics: ref.read(hapticServiceProvider),
      analytics: ref.read(analyticsServiceProvider),
      palette: Skin.byId(storage.selectedSkin).palette,
      skinStyle: Skin.byId(storage.selectedSkin).style,

      onScoreChanged: notifier.setScore,
      onCoinsEarned: notifier.addCoins,
      onStatusChanged: _onStatus,
      runColor: () => ref.read(runColorProvider),
      pickNextRunColor: notifier2.pickNext,
    );
    storage.incrementGamesPlayed();
    _audio.startMusic();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) notifier.resetRun();
    });
  }

  @override
  void dispose() {
    _audio.stopMusic();
    //    Future<void>(_runColorNotifier.pickNext);
    super.dispose();
  }

  void _onStatus(GameStatus status) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameStateProvider.notifier).setStatus(status);
      if (status == GameStatus.gameOver) _showGameOver();
    });
  }

  Future<void> _showGameOver() async {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final score = ref.read(gameStateProvider).score;
    ref.read(analyticsServiceProvider).gameOver(score);
    final adShown = await ref.read(adServiceProvider).maybeShowInterstitial();
    if (!mounted) return;

    if (adShown) {
      _dialogOpen = false;
      await ref.read(storageServiceProvider).advanceSkin();
      _runColorNotifier.pickNext();
      if (!mounted) return;
      context.go(AppRoutes.home);
      return;
    }

    ref.read(adServiceProvider).loadRewardedIfNeeded();
    final action = await showDialog<GameOverAction>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (_) => GameOverDialog(score: score),
    );
    _dialogOpen = false;
    if (!mounted) return;

    switch (action) {
      case GameOverAction.playAgain:
        await _advanceSkin();
        ref.read(gameStateProvider.notifier).resetRun();
        _game.restart();
      case GameOverAction.continueWithAd:
      case GameOverAction.continueWithCoins:
        _game.continueAfterGameOver();
      case GameOverAction.home:
      case null:
        await ref.read(storageServiceProvider).advanceSkin();
        _runColorNotifier.pickNext();
        if (!mounted) return;
        context.go(AppRoutes.home);
    }
  }

  Future<void> _advanceSkin() async {
    final storage = ref.read(storageServiceProvider);
    await storage.advanceSkin();
    _game.applySkin(Skin.byId(storage.selectedSkin));
  }

  Future<void> _pause() async {
    if (_game.status != GameStatus.playing || _dialogOpen) return;
    _game.pauseGame();
    _dialogOpen = true;
    final goHome = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppDialog(
        title: ctx.tr('paused'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: ctx.tr('resume'),
              icon: Icons.play_arrow_rounded,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            const SizedBox(height: 10),
            AppButton(
              style: AppButtonStyle.purple,
              label: ctx.tr('home'),
              icon: Icons.home_rounded,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    );
    _dialogOpen = false;
    if (!mounted) return;
    if (goHome ?? false) {
      context.go(AppRoutes.home);
    } else {
      _game.resumeGame();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final adsRemoved = ref.watch(adsRemovedProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await ref.read(storageServiceProvider).advanceSkin();
        _runColorNotifier.pickNext();
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundTop,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GameWidget<StackGame>(game: _game),
                  SafeArea(
                    bottom: false,

                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: context.sp(88)),
                            Expanded(
                              child: IgnorePointer(
                                child: ScoreDisplay(
                                  score: state.score,
                                  best: state.bestScore,
                                  fontSize: context.sp(56),
                                ),
                              ),
                            ),
                            SizedBox(width: context.sp(88)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //if (!adsRemoved) const SafeArea(top: false, child: BannerAdView()),
          ],
        ),
      ),
    );
  }
}
