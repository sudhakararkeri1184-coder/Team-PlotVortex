// lib/chess_screen/chess_CompetitiveMode/services/elo_calculator.dart

import 'dart:math';

class EloCalculator {
  // K-factor determines how much ratings change per game
  static const int kFactor = 32;

  /// Calculate expected score for player A
  static double getExpectedScore(int ratingA, int ratingB) {
    return 1 / (1 + pow(10, (ratingB - ratingA) / 400));
  }

  /// Calculate new ELO ratings after a game
  /// Returns a Map with 'winner' and 'loser' new ratings
  static Map<String, int> calculateNewRatings({
    required int winnerElo,
    required int loserElo,
    bool isDraw = false,
  }) {
    double expectedWinner = getExpectedScore(winnerElo, loserElo);
    double expectedLoser = getExpectedScore(loserElo, winnerElo);

    double actualWinner = isDraw ? 0.5 : 1.0;
    double actualLoser = isDraw ? 0.5 : 0.0;

    int newWinnerElo =
        (winnerElo + kFactor * (actualWinner - expectedWinner)).round();
    int newLoserElo =
        (loserElo + kFactor * (actualLoser - expectedLoser)).round();

    return {'winner': newWinnerElo, 'loser': newLoserElo};
  }

  /// Get ELO change for display
  static int getEloChange(int oldElo, int newElo) {
    return newElo - oldElo;
  }
}
