abstract final class CoinRewards {
  /// Perfect landings pay 1 coin, +1 once the streak reaches 3.
  static int forPlacement({required bool perfect, required int streak}) {
    if (!perfect) return 0;
    return streak >= 3 ? 2 : 1;
  }
}
