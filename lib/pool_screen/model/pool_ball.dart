import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

class Ball {
  final int number;
  vector.Vector2 position;
  vector.Vector2 velocity;
  final double radius;
  final Color color;
  bool isPocketed;
  final BallType type;
  // ignore: public_member_api_docs
  bool wasAlreadyPocketed = false; // Used by GameProvider to track new pockets

  Ball({
    required this.number,
    required this.position,
    required this.color,
    this.radius = 18.0,
    this.isPocketed = false,
    required this.type,
  }) : velocity = vector.Vector2.zero();

  void updatePosition(double deltaTime) {
    if (!isPocketed) {
      position += velocity * deltaTime;

      // Apply friction
      velocity *= 0.985;

      // Stop if velocity is very small
      if (velocity.length < 0.5) {
        velocity = vector.Vector2.zero();
      }
    }
  }

  bool isMoving() {
    return velocity.length > 0.1;
  }

  void reset(vector.Vector2 newPosition) {
    position = newPosition;
    velocity = vector.Vector2.zero();
    isPocketed = false;
    wasAlreadyPocketed = false;
  }
}

enum BallType { cue, solid, stripe, eight }

class BallColors {
  static const Map<int, Color> ballColors = {
    0: Colors.white, // Cue ball
    1: Color(0xFFFFD700), // Yellow
    2: Color(0xFF0000FF), // Blue
    3: Color(0xFFFF0000), // Red
    4: Color(0xFF800080), // Purple
    5: Color(0xFFFFA500), // Orange
    6: Color(0xFF008000), // Green
    7: Color(0xFF8B4513), // Brown
    8: Color(0xFF000000), // Black (8-ball)
    9: Color(0xFFFFD700), // Yellow stripe
    10: Color(0xFF0000FF), // Blue stripe
    11: Color(0xFFFF0000), // Red stripe
    12: Color(0xFF800080), // Purple stripe
    13: Color(0xFFFFA500), // Orange stripe
    14: Color(0xFF008000), // Green stripe
    15: Color(0xFF8B4513), // Brown stripe
  };

  static BallType getBallType(int number) {
    if (number == 0) return BallType.cue;
    if (number == 8) return BallType.eight;
    if (number < 8) return BallType.solid;
    return BallType.stripe;
  }
}
