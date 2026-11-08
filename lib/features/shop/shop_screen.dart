import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:place_stack/app/config/app_config.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/ads/ad_service.dart';
import 'package:place_stack/core/analytics/analytics_service.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';
import 'package:place_stack/shared/models/store_item.dart';
import 'package:place_stack/shared/widgets/app_button.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  StreamSubscription<List<PurchaseDetails>>? _sub;
  String _price = AppConfig.removeAdsFallbackPrice;

  @override
  void initState() {
    super.initState();
    try {
      _sub = InAppPurchase.instance.purchaseStream.listen(_onPurchases, onError: (_) {});
      _loadPrice();
    } catch (_) {
      // Platform without store support.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<ProductDetails?> _product() async {
    final iap = InAppPurchase.instance;
    if (!await iap.isAvailable()) return null;
    final response = await iap.queryProductDetails(<String>{AppConfig.removeAdsProductId});
    return response.productDetails.isEmpty ? null : response.productDetails.first;
  }

  Future<void> _loadPrice() async {
    try {
      final product = await _product();
      if (product != null && mounted) setState(() => _price = product.price);
    } catch (_) {}
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      final ok = p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored;
      if (ok && p.productID == AppConfig.removeAdsProductId) {
        await ref.read(adsRemovedProvider.notifier).setRemoved(true);
        ref.read(analyticsServiceProvider).purchase(p.productID);
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _watchAd(StoreItem item) async {
    final notReady = context.tr('ad_not_ready');
    final earned = await ref.read(adServiceProvider).showRewarded();
    if (!mounted) return;
    if (earned) {
      ref.read(gameStateProvider.notifier).addCoins(item.coins);
      ref.read(analyticsServiceProvider).rewardedAd(item.id);
    } else {
      _snack(notReady);
    }
  }

  Future<void> _buyRemoveAds() async {
    final unavailable = context.tr('purchase_unavailable');
    try {
      final product = await _product();
      if (product == null) {
        _snack(unavailable);
        return;
      }
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      _snack(unavailable);
    }
  }

  Future<void> _restore() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      _snack(context.tr('purchase_unavailable'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsRemoved = ref.watch(adsRemovedProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        // for (final item in StoreItem.coinItems)
        //   _ShopCard(
        //     leading: const CoinIcon(size: 44),
        //     title: context.tr('coins_n', args: {'n': item.coins}),
        //     subtitle: context.tr('get_n_coins', args: {'n': item.coins}),
        //     action: AppButton(
        //       expand: false,
        //       height: 40,
        //       style: AppButtonStyle.purple,
        //       icon: Icons.ondemand_video_rounded,
        //       label: context.tr('watch_ad'),
        //       onPressed: () => _watchAd(item),
        //     ),
        //   ),
        if (!adsRemoved)
          _ShopCard(
            leading: const Icon(Icons.block_rounded, color: AppColors.red, size: 44),
            title: context.tr('remove_ads'),
            subtitle: context.tr('remove_ads_sub'),
            action: AppButton(
              expand: false,
              height: 40,
              style: AppButtonStyle.green,
              label: _price,
              onPressed: _buyRemoveAds,
            ),
          ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: _restore,
            child: Text(
              context.tr('restore_purchases'),
              style: AppTypography.caption.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.action,
  });
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dialogCardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        //border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          SizedBox(width: 48, child: Center(child: leading)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading,
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          action,
        ],
      ),
    );
  }
}
