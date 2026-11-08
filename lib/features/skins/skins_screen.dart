import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/ads/ad_service.dart';
import 'package:place_stack/core/analytics/analytics_service.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/game/entities/block.dart';
import 'package:place_stack/game/rendering/block_renderer.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';
import 'package:place_stack/shared/models/skin.dart';
import 'package:place_stack/shared/widgets/coin_display.dart';

class SkinsScreen extends ConsumerStatefulWidget {
  const SkinsScreen({super.key});

  @override
  ConsumerState<SkinsScreen> createState() => _SkinsScreenState();
}

class _SkinsScreenState extends ConsumerState<SkinsScreen> {
  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _select(Skin skin) async {
    await ref.read(storageServiceProvider).setSelectedSkin(skin.id);
    ref.invalidate(runColorProvider);
    ref.read(analyticsServiceProvider).skinSelected(skin.id);
    if (mounted) setState(() {});
  }

  Future<void> _onTap(Skin skin) async {
    final storage = ref.read(storageServiceProvider);
    if (storage.unlockedSkins.contains(skin.id)) {
      await _select(skin);
      return;
    }
    switch (skin.unlock) {
      case SkinUnlock.free:
        await storage.unlockSkin(skin.id);
        await _select(skin);
      case SkinUnlock.coins:
        if (ref.read(gameStateProvider.notifier).spendCoins(skin.price)) {
          await storage.unlockSkin(skin.id);
          await _select(skin);
        } else {
          _snack(context.tr('not_enough_coins'));
        }
      case SkinUnlock.ad:
        final notReady = context.tr('ad_not_ready');
        final earned = await ref.read(adServiceProvider).showRewarded();
        if (earned) {
          await storage.unlockSkin(skin.id);
          await _select(skin);
        } else {
          _snack(notReady);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    //final runColor = ref.watch(runColorProvider);
    final unlocked = storage.unlockedSkins;
    final selected = storage.selectedSkin;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: Skin.all.length,
      itemBuilder: (context, i) {
        final skin = Skin.all[i];
        return _SkinTile(
          skin: skin,
          color: skin.fixedColor ?? skin.palette.first,
          isUnlocked: unlocked.contains(skin.id),
          isSelected: selected == skin.id,
          onTap: () => _onTap(skin),
        );
      },
    );
  }
}

class _SkinTile extends StatelessWidget {
  const _SkinTile({
    required this.skin,
    required this.color,
    required this.isUnlocked,
    required this.isSelected,
    required this.onTap,
  });

  final Skin skin;
  final Color color;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.border.withValues(alpha: 0.3),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _SkinPreviewPainter(skin.style, color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(height: 24, child: Center(child: _label(context))),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle_rounded, color: AppColors.green, size: 24),
              ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context) {
    if (isUnlocked || skin.unlock == SkinUnlock.free) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          skin.id == 'default' ? context.tr('default') : skin.name,
          style: AppTypography.body,
        ),
      );
    }
    if (skin.unlock == SkinUnlock.ad) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ondemand_video_rounded, size: 16),
            const SizedBox(width: 4),
            Text(
              context.tr('watch_ad'),
              style: AppTypography.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoinIcon(size: 18),
          const SizedBox(width: 4),
          Text('${skin.price}', style: AppTypography.body),
        ],
      ),
    );
  }
}

/// Draws two stacked sample blocks with the real block renderer.
class _SkinPreviewPainter extends CustomPainter {
  const _SkinPreviewPainter(this.style, this.color);
  final SkinStyle style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final renderer = BlockRenderer()
      ..style = style
      ..solidColor = color;
    const worldW = 130.0;
    const worldH = 70.0;
    final s = (size.width / worldW) < (size.height / worldH)
        ? size.width / worldW
        : size.height / worldH;
    canvas.save();
    canvas.translate((size.width - worldW * s) / 2, (size.height - worldH * s) / 2);
    canvas.scale(s);
    renderer.render(canvas, Block(x: 10, y: 38, width: 110, height: 30, colorIndex: 1));
    renderer.render(canvas, Block(x: 30, y: 6, width: 70, height: 30, colorIndex: 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkinPreviewPainter old) => old.style != style || old.color != color;
}
