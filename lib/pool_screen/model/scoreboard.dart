import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';

import '../providers/pool_game_provider.dart';

class ScoreBoard extends StatelessWidget {
  final int playerNumber;

  const ScoreBoard({super.key, required this.playerNumber});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        String name = 'Player $playerNumber';
        bool isActive = gameProvider.currentPlayer == playerNumber;
        int score =
            playerNumber == 1
                ? gameProvider.player1Score
                : gameProvider.player2Score;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.amber : Colors.white54,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                score.toString(),
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
