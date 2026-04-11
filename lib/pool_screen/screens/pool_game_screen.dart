import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:v2/pool_screen/widgets/pool_score_board.dart';
import '../providers/pool_game_provider.dart';
import '../widgets/pool_game_table.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      final now = DateTime.now();
      final deltaTime = now.difference(_lastUpdate).inMilliseconds / 1000.0;
      _lastUpdate = now;

      context.read<GameProvider>().updatePhysics(deltaTime);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A1B),
      body: SafeArea(
        child: Stack(
          children: [
            // Main game layout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double scale =
                          constraints.maxHeight / gameProvider.table.height;
                      double tableWidth = gameProvider.table.width * scale;

                      if (tableWidth > constraints.maxWidth * 0.72) {
                        scale =
                            (constraints.maxWidth * 0.72) /
                            gameProvider.table.width;
                        tableWidth = gameProvider.table.width * scale;
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ScoreBoard(playerNumber: 1),
                          const Spacer(),
                          SizedBox(
                            width: tableWidth,
                            height: constraints.maxHeight,
                            child: const GameTable(),
                          ),
                          const Spacer(),
                          Transform.rotate(
                            angle: 3.14159,
                            child: ScoreBoard(playerNumber: 2),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // Back button
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Game message bar (bottom)
            Positioned(
              bottom: 8,
              left: 80,
              right: 80,
              child: Consumer<GameProvider>(
                builder: (context, gp, _) {
                  if (gp.gameMessage == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Text(
                      gp.gameMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Winner overlay
            Consumer<GameProvider>(
              builder: (context, gp, _) {
                if (gp.winner == null) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3A2A), Color(0xFF0A2A1B)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            '${gp.winner} Wins!',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            gp.gameMessage ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => gp.resetGame(),
                                icon: const Icon(Icons.replay, size: 18),
                                label: const Text('New Game'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8B42),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.exit_to_app, size: 18),
                                label: const Text('Exit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
