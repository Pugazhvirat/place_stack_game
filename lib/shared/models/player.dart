class Player {
  const Player({
    required this.name,
    required this.bestScore,
    required this.coins,
    required this.gamesPlayed,
  });

  final String name;
  final int bestScore;
  final int coins;
  final int gamesPlayed;
}
