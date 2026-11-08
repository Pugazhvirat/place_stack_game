/// Mutable data for the current run (owned by the engine).
class GameSession {
  int score = 0;
  int blocksPlaced = 0;
  int perfectStreak = 0;
  int perfectCount = 0;
  int coinsEarned = 0;

  void registerPlacement({required bool perfect}) {
    blocksPlaced++;
    if (perfect) {
      perfectStreak++;
      perfectCount++;
    } else {
      perfectStreak = 0;
    }
  }

  void reset() {
    score = 0;
    blocksPlaced = 0;
    perfectStreak = 0;
    perfectCount = 0;
    coinsEarned = 0;
  }
}
