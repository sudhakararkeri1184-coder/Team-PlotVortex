import 'package:flutter/material.dart';
import 'package:v2/pool_screen/model/pool_ball.dart';
import 'package:v2/pool_screen/model/pool_table.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;

import '../physics/pool_physics_engine.dart';

class GameProvider extends ChangeNotifier {
  late PoolTable table;
  late List<Ball> balls;
  late PhysicsEngine physics;

  int player1Score = 0;
  int player2Score = 0;
  int currentPlayer = 1;
  bool isAiming = false;
  vector.Vector2? aimStart;
  vector.Vector2? aimEnd;
  double shotPower = 0.0;

  // 8-ball game state
  BallType? player1Type; // solids or stripes (null = not yet assigned)
  BallType? player2Type;
  bool _shotInProgress = false;
  bool _cueBallPocketed = false;
  bool _pocketedOwnBall = false;
  bool _eightBallPocketed = false;
  String? gameMessage;
  String? winner;
  bool _settleTimerActive = false;
  double _settleTimer = 0.0;
  static const double _settleDelay = 0.4;
  Timer? _messageTimer;

  GameProvider() {
    initializeGame();
  }

  void initializeGame() {
    table = PoolTable(width: 1000.0, height: 600.0);
    balls = _setupBalls();
    physics = PhysicsEngine(table: table, balls: balls);
    player1Score = 0;
    player2Score = 0;
    currentPlayer = 1;
    player1Type = null;
    player2Type = null;
    _shotInProgress = false;
    _cueBallPocketed = false;
    _pocketedOwnBall = false;
    _eightBallPocketed = false;
    gameMessage = 'Player 1\'s turn';
    winner = null;
    _settleTimerActive = false;
    _settleTimer = 0.0;
    _messageTimer?.cancel();
    notifyListeners();
  }

  void _showMessage(String msg) {
    _messageTimer?.cancel();
    gameMessage = msg;
    notifyListeners();
    _messageTimer = Timer(const Duration(seconds: 2), () {
      gameMessage = null;
      notifyListeners();
    });
  }

  List<Ball> _setupBalls() {
    List<Ball> gameBalls = [];

    // Cue ball
    gameBalls.add(
      Ball(
        number: 0,
        position: vector.Vector2(table.width * 0.25, table.height * 0.5),
        color: BallColors.ballColors[0]!,
        type: BallType.cue,
      ),
    );

    // Standard 8-ball rack order
    final rackOrder = [1, 9, 2, 10, 8, 3, 11, 4, 12, 5, 13, 6, 14, 7, 15];

    double startX = table.width * 0.75;
    double startY = table.height * 0.5;
    double radius = 18.0;
    double rowSpacing = radius * 2.0;
    double colSpacing = radius * math.sqrt(3);

    int ballIndex = 0;
    for (int row = 0; row < 5; row++) {
      int ballsInRow = row + 1;
      double rowX = startX + row * colSpacing;
      for (int col = 0; col < ballsInRow; col++) {
        double y =
            startY + (col * rowSpacing) - ((ballsInRow - 1) * rowSpacing / 2);
        int num = rackOrder[ballIndex];

        gameBalls.add(
          Ball(
            number: num,
            position: vector.Vector2(rowX, y),
            color: BallColors.ballColors[num]!,
            type: BallColors.getBallType(num),
          ),
        );

        ballIndex++;
        if (ballIndex >= 15) break;
      }
      if (ballIndex >= 15) break;
    }

    return gameBalls;
  }

  void updatePhysics(double deltaTime) {
    if (winner != null) return;

    physics.update(deltaTime);

    // Check for newly pocketed balls
    for (final ball in balls) {
      if (ball.isPocketed && !ball.wasAlreadyPocketed) {
        ball.wasAlreadyPocketed = true;
        _handleBallPocketed(ball);
      }
    }

    // Check if all balls have stopped
    bool allStopped = balls.every(
      (ball) => ball.isPocketed || !ball.isMoving(),
    );

    if (allStopped && _shotInProgress) {
      if (!_settleTimerActive) {
        _settleTimerActive = true;
        _settleTimer = 0.0;
      }
      _settleTimer += deltaTime;

      if (_settleTimer >= _settleDelay) {
        _endTurn();
        _settleTimerActive = false;
        _settleTimer = 0.0;
      }
    } else if (!allStopped) {
      _settleTimerActive = false;
      _settleTimer = 0.0;
    }

    notifyListeners();
  }

  void _handleBallPocketed(Ball ball) {
    if (ball.type == BallType.cue) {
      _cueBallPocketed = true;
      _showMessage('Foul! Cue ball pocketed');
      return;
    }

    if (ball.number == 8) {
      _eightBallPocketed = true;
      return;
    }

    // Assign ball types on first pocket
    if (player1Type == null) {
      if (ball.type == BallType.solid) {
        player1Type = currentPlayer == 1 ? BallType.solid : BallType.stripe;
        player2Type = currentPlayer == 1 ? BallType.stripe : BallType.solid;
      } else if (ball.type == BallType.stripe) {
        player1Type = currentPlayer == 1 ? BallType.stripe : BallType.solid;
        player2Type = currentPlayer == 1 ? BallType.solid : BallType.stripe;
      }
      String p1Label = player1Type == BallType.solid ? 'Solids' : 'Stripes';
      String p2Label = player2Type == BallType.solid ? 'Solids' : 'Stripes';
      _showMessage('P1: $p1Label | P2: $p2Label');
    }

    // Check if the pocketed ball belongs to current player
    BallType? currentType = currentPlayer == 1 ? player1Type : player2Type;
    if (currentType != null && ball.type == currentType) {
      _pocketedOwnBall = true;
      if (currentPlayer == 1) {
        player1Score++;
      } else {
        player2Score++;
      }
    } else {
      // Pocketed opponent's ball
      if (currentPlayer == 1) {
        player2Score++;
      } else {
        player1Score++;
      }
    }
  }

  void _endTurn() {
    if (winner != null) return;
    _shotInProgress = false;

    // Handle 8-ball pocketed
    if (_eightBallPocketed) {
      bool allOwnPocketed = _allOwnBallsPocketed(currentPlayer);

      if (allOwnPocketed && !_cueBallPocketed) {
        winner = 'Player $currentPlayer';
        gameMessage = '🎱 Player $currentPlayer WINS!';
      } else {
        int otherPlayer = currentPlayer == 1 ? 2 : 1;
        winner = 'Player $otherPlayer';
        gameMessage =
            'Player $currentPlayer scratched on 8-ball! Player $otherPlayer WINS!';
      }
      notifyListeners();
      return;
    }

    // Handle cue ball foul
    if (_cueBallPocketed) {
      _respawnCueBall();
      int nextPlayer = currentPlayer == 1 ? 2 : 1;
      currentPlayer = nextPlayer;
      _showMessage('Foul! Player $currentPlayer\'s turn (ball in hand)');
    } else if (_pocketedOwnBall) {
      _showMessage('Nice shot! Player $currentPlayer continues');
    } else {
      currentPlayer = currentPlayer == 1 ? 2 : 1;
      _showMessage('Player $currentPlayer\'s turn');
    }

    // Reset turn flags
    _cueBallPocketed = false;
    _pocketedOwnBall = false;
    _eightBallPocketed = false;

    notifyListeners();
  }

  bool _allOwnBallsPocketed(int player) {
    BallType? type = player == 1 ? player1Type : player2Type;
    if (type == null) return false;
    return balls.where((b) => b.type == type).every((b) => b.isPocketed);
  }

  void _respawnCueBall() {
    Ball? cueBall = getCueBall();
    if (cueBall != null) {
      cueBall.isPocketed = false;
      cueBall.wasAlreadyPocketed = false;
      cueBall.velocity = vector.Vector2.zero();

      vector.Vector2 spawnPos = vector.Vector2(
        table.width * 0.25,
        table.height * 0.5,
      );

      bool clear = false;
      double offsetX = 0;
      while (!clear) {
        clear = true;
        for (final b in balls) {
          if (b == cueBall || b.isPocketed) continue;
          if ((b.position - spawnPos).length < b.radius + cueBall.radius + 5) {
            clear = false;
            offsetX += cueBall.radius * 2;
            spawnPos = vector.Vector2(
              table.width * 0.25 + offsetX,
              table.height * 0.5,
            );
            break;
          }
        }
        if (offsetX > table.width * 0.2) break;
      }
      cueBall.position = spawnPos;
    }
  }

  void startAiming(vector.Vector2 position) {
    if (winner != null) return;
    if (_shotInProgress) return;

    Ball? cueBall = getCueBall();
    if (cueBall != null && !cueBall.isPocketed) {
      bool anyMoving = balls.any((ball) => !ball.isPocketed && ball.isMoving());
      if (anyMoving) return;

      isAiming = true;
      aimStart = cueBall.position.clone();
      aimEnd = position;
      notifyListeners();
    }
  }

  void updateAim(vector.Vector2 position) {
    if (isAiming) {
      aimEnd = position;
      Ball? cueBall = getCueBall();
      if (cueBall != null) {
        double distance = (position - cueBall.position).length;
        shotPower = (distance / 200).clamp(0.1, 1.0);
      }
      notifyListeners();
    }
  }

  void shoot() {
    if (isAiming && aimEnd != null && winner == null) {
      Ball? cueBall = getCueBall();
      if (cueBall != null) {
        physics.applyCueForce(cueBall, aimEnd!, shotPower * 100);
        _shotInProgress = true;

        // Reset per-turn tracking
        _cueBallPocketed = false;
        _pocketedOwnBall = false;
        _eightBallPocketed = false;

        // Reset wasAlreadyPocketed for non-pocketed balls
        for (final b in balls) {
          if (!b.isPocketed) {
            b.wasAlreadyPocketed = false;
          }
        }
      }
      isAiming = false;
      aimStart = null;
      aimEnd = null;
      shotPower = 0.0;
      notifyListeners();
    }
  }

  Ball? getCueBall() {
    try {
      return balls.firstWhere((ball) => ball.number == 0);
    } catch (_) {
      return null;
    }
  }

  bool canShootEightBall() {
    return _allOwnBallsPocketed(currentPlayer);
  }

  void resetGame() {
    initializeGame();
  }
}
