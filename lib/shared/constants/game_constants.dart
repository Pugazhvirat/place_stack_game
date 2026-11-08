/// All gameplay tuning values in logical game units (world width = 400).
abstract final class GameConstants {
  static const double worldWidth = 400;
  static const double blockHeight = 50;
  static const double firstBlockHeight = 150;
  static const double initialBlockWidth = 250;
  static const double minOverlapWidth = 1.5;
  static const double perfectTolerance = 0;
  static const double trackMargin = 16;
  static const double reviveBlockWidth = 100;
  static const double firstBlockTopFraction = 0.56;

  static const double movingBlockScreenFraction = 0.24;
  static const double baseTopFraction = 0.86;
  static const double cameraTopFraction = 0.55;
  static const double cameraSmoothing = 6;

  static const double baseSpeed = 150;
  static const double speedStep = 4;
  static const double maxSpeed = 380;

  static const double dropGravity = 2800;
  static const double dropInitialVelocity = 300;

  static const double fallGravity = 200;
  static const double fallKickX = 90;
  static const double fallMinSpin = 1.5;
  static const double fallExtraSpin = 2.5;
  static const double fallRemoveMargin = 200;

  static const double missGameOverDelay = 0.9;
  static const double maxFrameStep = 0.05;
  static const double colorStep = 0.4;
  static const double blockCornerRadius = 2;

  static const int maxPerfectBonus = 5;
}
