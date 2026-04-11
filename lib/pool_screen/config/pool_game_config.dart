/// Pool Game Configuration
/// Contains all game constants, physics parameters, and rules

class PoolGameConfig {
  // Table dimensions
  static const double tableWidth = 1000.0;
  static const double tableHeight = 600.0;
  static const double cushionWidth = 25.0;

  // Pocket configuration
  static const double cornerPocketRadius = 25.0;
  static const double sidePocketRadius = 22.0;
  static const double pocketOffset = 5.0;

  // Ball configuration
  static const double ballRadius = 18.0;
  static const int totalBalls = 16; // 15 object balls + 1 cue ball

  // Physics parameters
  static const double friction = 0.985; // Ball friction coefficient
  static const double cushionBounceLoss =
      0.85; // Energy loss on cushion collision
  static const double collisionRestitution = 0.95; // Ball-to-ball bounce
  static const double ballStopThreshold =
      0.05; // Velocity below which ball is "stopped"

  // Turn management
  static const double settleHoldTime =
      0.8; // Seconds balls must be still before turn ends
  static const bool strictTurnLocking = true; // Enforce strict turn-based play

  // Shot parameters
  static const double minShotPower = 0.1;
  static const double maxShotPower = 1.0;
  static const double powerMultiplier = 100.0; // Applied force multiplier

  // Game rules
  static const bool ballInHand = true; // Cue ball respawns on foul
  static const bool callShot = false; // Whether players must call their shots
  static const bool continueTurnOnMake =
      true; // Player continues if they pocket their ball

  // UI settings
  static const double aimLineOpacity = 0.7;
  static const double powerIndicatorMaxLength = 80.0;

  // Color scheme
  static const int feltColorValue = 0xFF388E46; // Green felt
  static const int woodBorderColorValue = 0xFF804000; // Wood border

  // Debug settings
  static const bool enableDebugPrint = true;
  static const bool showVelocityVectors = false;

  /// Returns the starting position for the cue ball
  static (double x, double y) get cueballStartPosition {
    return (tableWidth * 0.25, tableHeight * 0.5);
  }

  /// Returns the starting position for the racked balls
  static (double x, double y) get rackStartPosition {
    return (tableWidth * 0.75, tableHeight * 0.5);
  }
}

/// Game difficulty levels (for future AI implementation)
enum Difficulty { easy, medium, hard, expert }

/// Match types
enum MatchType { eightBall, nineBall, straightPool, practice }
