enum StoreItemKind { rewardedCoins, removeAds }

class StoreItem {
  const StoreItem({
    required this.id,
    required this.kind,
    this.coins = 0,
  });

  final String id;
  final StoreItemKind kind;
  final int coins;

  static const List<StoreItem> coinItems = <StoreItem>[
    StoreItem(id: 'coins_50', kind: StoreItemKind.rewardedCoins, coins: 50),
    StoreItem(id: 'coins_200', kind: StoreItemKind.rewardedCoins, coins: 200),
  ];
}
