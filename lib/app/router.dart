import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/ads/ad_service.dart';
import 'package:place_stack/features/game/game_screen.dart';
import 'package:place_stack/features/home/home_screen.dart';
import 'package:place_stack/features/how_to_play/how_to_play_screen.dart';
import 'package:place_stack/features/profile/profile_screen.dart';
import 'package:place_stack/features/ranking/ranking_screen.dart';
import 'package:place_stack/features/settings/settings_screen.dart';
import 'package:place_stack/features/shop/shop_screen.dart';
import 'package:place_stack/features/skins/skins_screen.dart';
import 'package:place_stack/game/rendering/background_renderer.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';
import 'package:place_stack/shared/extensions/number_extensions.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String shop = '/shop';
  static const String skins = '/skins';
  static const String ranking = '/ranking';
  static const String howToPlay = '/how-to-play';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String splash = '/splash';
}

Page<void> _page(Widget child, GoRouterState state) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    //initialLocation: AppRoutes.home,
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) => MainShell(location: state.uri.path, child: child),
        routes: <RouteBase>[
          GoRoute(path: AppRoutes.home, pageBuilder: (c, s) => _page(const HomeScreen(), s)),
          GoRoute(path: AppRoutes.shop, pageBuilder: (c, s) => _page(const ShopScreen(), s)),
          GoRoute(path: AppRoutes.skins, pageBuilder: (c, s) => _page(const SkinsScreen(), s)),
          GoRoute(path: AppRoutes.ranking, pageBuilder: (c, s) => _page(const RankingScreen(), s)),
          GoRoute(
            path: AppRoutes.howToPlay,
            pageBuilder: (c, s) => _page(const HowToPlayScreen(), s),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (c, s) => _page(const SettingsScreen(), s),
          ),
          GoRoute(path: AppRoutes.profile, pageBuilder: (c, s) => _page(const ProfileScreen(), s)),
        ],
      ),
      GoRoute(path: AppRoutes.game, builder: (context, state) => const GameScreen()),
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const _SplashScreen()),
    ],
  );
});

class _NavItem {
  const _NavItem(this.route, this.icon, this.labelKey);
  final String route;
  final IconData icon;
  final String labelKey;
}

const List<_NavItem> _navItems = <_NavItem>[
  // _NavItem(AppRoutes.shop, Icons.storefront_rounded, 'shop'),
  // // _NavItem(AppRoutes.skins, Icons.palette_rounded, 'skin'),
  //_NavItem(AppRoutes.home, Icons.home_rounded, 'home'),
  // //_NavItem(AppRoutes.ranking, Icons.emoji_events_rounded, 'ranking'),
  // _NavItem(AppRoutes.howToPlay, Icons.menu_book_rounded, 'how_to_play'),
];

/// Common chrome (HUD top bar + bottom nav + banner) around every non-game screen.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  String? get _titleKey => switch (location) {
    AppRoutes.shop => 'shop',
    AppRoutes.skins => 'skin',
    AppRoutes.ranking => 'ranking',
    AppRoutes.howToPlay => 'how_to_play',
    AppRoutes.settings => 'settings',
    AppRoutes.profile => 'profile',

    _ => null,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final best = ref.watch(gameStateProvider.select((s) => s.bestScore));
    final state = ref.watch(gameStateProvider);
    final adsRemoved = ref.watch(adsRemovedProvider);
    final titleKey = _titleKey;
    final runColor = ref.watch(runColorProvider);
    final isHome = location == AppRoutes.home;
    final homeBg = Color.lerp(const Color(0xFFFFFFFF), runColor, BackgroundRenderer.tintStrength)!;
    //final iconColor = isHome ? const Color(0xFF0B1A3F) : Colors.white;
    //const iconColor = Colors.white;

    return PopScope(
      canPop: location == AppRoutes.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: Scaffold(
        body: _HomeBackground(
          color: runColor,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
                      child: SizedBox(
                        height: AppDimensions.topBarHeight,

                        child: Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            Text('$best', style: AppTypography.score.copyWith(fontSize: 30)),

                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                              tooltip: context.tr('how_to_play'),
                              // onPressed: () => context.go(
                              //   location == AppRoutes.howToPlay
                              //       ? AppRoutes.home
                              //       : AppRoutes.howToPlay,
                              // ),
                              onPressed: () =>
                                  showPanel(context, 'how_to_play', const HowToPlayScreen()),
                            ),
                            // IconButton(
                            //   icon: Icon(Icons.palette_rounded, color: iconColor, size: 40),
                            //   tooltip: context.tr('skin'),
                            //   onPressed: () => showPanel(context, 'skin', const SkinsScreen()),
                            // ),
                            // if (!adsRemoved)
                            //   IconButton(
                            //     icon: const Icon(
                            //       Icons.block_rounded,
                            //       color: AppColors.red,
                            //       size: 28,
                            //     ),
                            //     tooltip: context.tr('remove_ads'),
                            //     // onPressed: () => context.go(
                            //     //   location == AppRoutes.shop ? AppRoutes.home : AppRoutes.shop,
                            //     // ),
                            //     onPressed: () =>
                            //         showPanel(context, 'remove_ads', const ShopScreen()),
                            //   ),
                            IconButton(
                              icon: const Icon(
                                Icons.settings_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                              tooltip: context.tr('settings'),
                              // onPressed: () => context.go(
                              //   location == AppRoutes.settings
                              //       ? AppRoutes.home
                              //       : AppRoutes.settings,
                              // ),
                              onPressed: () =>
                                  showPanel(context, 'settings', const SettingsScreen()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (titleKey != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(context.tr(titleKey), style: AppTypography.title),
                      ),
                    Expanded(child: child),
                    _BottomNav(location: location),
                    //if (!adsRemoved) const BannerAdView(),
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

class _BestChip extends StatelessWidget {
  const _BestChip({required this.best, required this.onTap});
  final int best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.gold, size: 28),
          const SizedBox(width: 4),
          Text(best.withSeparators, style: AppTypography.heading),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.bottomNavHeight,
      child: Row(
        children: [
          for (final item in _navItems)
            Expanded(
              child: InkResponse(
                onTap: () => context.go(item.route),
                child: _NavButton(item: item, selected: item.route == location),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected});
  final _NavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.textSecondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, size: selected ? 32 : 26, color: selected ? AppColors.cyan : color),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.tr(item.labelKey),
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Light tinted background with the same softly pulsing dots as the game.
class _HomeBackground extends StatefulWidget {
  const _HomeBackground({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  State<_HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<_HomeBackground> with SingleTickerProviderStateMixin {
  final BackgroundRenderer _renderer = BackgroundRenderer();
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => _time.value = elapsed.inMilliseconds / 1000.0)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _renderer.tint = widget.color;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(child: CustomPaint(painter: _HomeBackgroundPainter(_renderer, _time))),
        widget.child,
      ],
    );
  }
}

class _HomeBackgroundPainter extends CustomPainter {
  _HomeBackgroundPainter(this.renderer, this.time) : super(repaint: time);
  final BackgroundRenderer renderer;
  final ValueNotifier<double> time;

  @override
  void paint(Canvas canvas, Size size) => renderer.render(canvas, size, 0, time.value);

  @override
  bool shouldRepaint(covariant _HomeBackgroundPainter old) => false;
}

/// Shows the launch picture full-screen for a set time, then opens Home.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  /// How long the splash stays on screen. Change this number.
  static const Duration _duration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(_duration, () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF030A24),
        body: SizedBox.expand(
          child: Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

void showPanel(BuildContext context, String titleKey, Widget child) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => Consumer(
      builder: (ctx, ref, _) {
        final runColor = ref.watch(runColorProvider);
        // final bg = Color.lerp(const Color(0xFF000000), runColor, 0.25)!.withValues(alpha: 1.0);
        final bg = runColor.computeLuminance() < 0.05
            ? const Color(0xFF3A3A40)
            : Color.lerp(const Color(0xFF000000), runColor, 0.25)!.withValues(alpha: 1.0);
        const ink = Color(0xFFFFFFFF);
        final height = MediaQuery.sizeOf(ctx).height * 0.7;
        return Dialog(
          backgroundColor: bg,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusL)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.dialogMaxWidth + 60),
            child: SizedBox(
              height: height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            ctx.tr(titleKey),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title.copyWith(color: ink),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: ink, size: 28),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
