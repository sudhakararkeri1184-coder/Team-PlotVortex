import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v2/pool_screen/model/pool_ball.dart';

import '../providers/pool_game_provider.dart';

class ScoreBoard extends StatelessWidget {
  final int playerNumber;

  const ScoreBoard({super.key, required this.playerNumber});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, child) {
        bool isActive = gp.currentPlayer == playerNumber;
        int score = playerNumber == 1 ? gp.player1Score : gp.player2Score;
        BallType? ballType =
            playerNumber == 1 ? gp.player1Type : gp.player2Type;

        String typeLabel = '';
        Color typeColor = Colors.white54;
        if (ballType == BallType.solid) {
          typeLabel = 'Solids';
          typeColor = const Color(0xFFFFD700);
        } else if (ballType == BallType.stripe) {
          typeLabel = 'Stripes';
          typeColor = const Color(0xFF00E5FF);
        }

        // Count remaining balls
        int remaining = 0;
        if (ballType != null) {
          remaining =
              gp.balls.where((b) => b.type == ballType && !b.isPocketed).length;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    )
                    : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ],
                    ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isActive
                      ? const Color(0xFFFFD700)
                      : Colors.white.withOpacity(0.15),
              width: isActive ? 2 : 1,
            ),
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                    : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Player $playerNumber',
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                score.toString(),
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (typeLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? Colors.black.withOpacity(0.15)
                            : typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$typeLabel ($remaining)',
                    style: TextStyle(
                      color: isActive ? Colors.black87 : typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (isActive) ...[
                const SizedBox(height: 4),
                Text(
                  '● TURN',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
