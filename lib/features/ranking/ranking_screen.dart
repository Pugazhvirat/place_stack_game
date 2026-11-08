import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:place_stack/app/config/app_config.dart';
import 'package:place_stack/app/theme/colors.dart';
import 'package:place_stack/app/theme/dimensions.dart';
import 'package:place_stack/app/theme/typography.dart';
import 'package:place_stack/core/storage/storage_service.dart';
import 'package:place_stack/game/state/game_state.dart';
import 'package:place_stack/shared/extensions/context_extensions.dart';
import 'package:place_stack/shared/extensions/number_extensions.dart';
import 'package:place_stack/shared/models/ranking_entry.dart';
import 'package:place_stack/shared/widgets/loading_indicator.dart';

const List<RankingEntry> _demoEntries = <RankingEntry>[
  RankingEntry(rank: 0, name: 'Player001', score: 1250),
  RankingEntry(rank: 0, name: 'ProGamer', score: 980, isFriend: true),
  RankingEntry(rank: 0, name: 'StackStar', score: 745),
  RankingEntry(rank: 0, name: 'CubeMaster', score: 620, isFriend: true),
  RankingEntry(rank: 0, name: 'SkyBuilder', score: 510),
  RankingEntry(rank: 0, name: 'Player789', score: 460),
  RankingEntry(rank: 0, name: 'TowerPro', score: 390, isFriend: true),
  RankingEntry(rank: 0, name: 'NextLevel', score: 350),
  RankingEntry(rank: 0, name: 'BlockBoss', score: 300),
];

/// Fetches the leaderboard with Dio when [AppConfig.apiBaseUrl] is set;
/// otherwise (or on failure) falls back to demo data. Your best score is merged in.
final rankingProvider = FutureProvider.autoDispose<List<RankingEntry>>((ref) async {
  final best = ref.watch(gameStateProvider.select((s) => s.bestScore));
  final name = ref.watch(storageServiceProvider).playerName;

  var entries = _demoEntries;
  if (AppConfig.apiBaseUrl.isNotEmpty) {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
      final res = await dio.get<List<dynamic>>('/ranking');
      final data = res.data;
      if (data != null) {
        entries = data.whereType<Map<String, dynamic>>().map(RankingEntry.fromJson).toList();
      }
    } catch (_) {
      entries = _demoEntries;
    }
  }

  final all = <RankingEntry>[
    ...entries,
    RankingEntry(rank: 0, name: name, score: best, isYou: true),
  ]..sort((a, b) => b.score.compareTo(a.score));
  return <RankingEntry>[
    for (var i = 0; i < all.length; i++) all[i].copyWith(rank: i + 1),
  ];
});

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  bool _global = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(rankingProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _Tab(label: context.tr('global'), selected: _global, onTap: () => setState(() => _global = true))),
              const SizedBox(width: 8),
              Expanded(child: _Tab(label: context.tr('friends'), selected: !_global, onTap: () => setState(() => _global = false))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: async.when(
            loading: () => const LoadingIndicator(),
            error: (_, __) => const SizedBox.shrink(),
            data: (all) {
              final list = _global ? all : all.where((e) => e.isYou || e.isFriend).toList();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) => _Row(entry: list[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.neonBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Text(label, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry});
  final RankingEntry entry;

  Color get _badge => switch (entry.rank) {
        1 => AppColors.gold,
        2 => const Color(0xFFB8C4E0),
        3 => const Color(0xFFE08A3C),
        _ => AppColors.surfaceLight,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: entry.isYou ? AppColors.neonBlue : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _badge),
            child: Text('${entry.rank}', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(entry.isYou ? context.tr('you') : entry.name,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body),
          ),
          Text(entry.score.withSeparators, style: AppTypography.heading),
        ],
      ),
    );
  }
}
