import 'package:v2/pool_screen/model/pool_ball.dart';
import 'package:v2/pool_screen/model/pool_table.dart';
import 'package:vector_math/vector_math.dart' as vector;

class PhysicsEngine {
  final PoolTable table;
  final List<Ball> balls;

  PhysicsEngine({required this.table, required this.balls});

  void update(double deltaTime) {
    // Update ball positions and handle collisions
    for (final ball in balls) {
      if (!ball.isPocketed) {
        ball.updatePosition(deltaTime);
        _checkPockets(ball);
        handleTableCollisions(ball);
      }
    }

    // Handle ball-to-ball collisions
    for (int i = 0; i < balls.length; i++) {
      for (int j = i + 1; j < balls.length; j++) {
        if (!balls[i].isPocketed && !balls[j].isPocketed) {
          _handleBallCollision(balls[i], balls[j]);
        }
      }
    }
  }

  void handleTableCollisions(Ball ball) {
    if (!ball.isPocketed) {
      // Only check collisions if ball is not near any pocket
      bool nearPocket = false;
      for (final pocket in table.pockets) {
        final dist = (ball.position - pocket.position).length;
        if (dist < pocket.radius + ball.radius + 5) {
          // Extra 5 pixels buffer
          nearPocket = true;
          break;
        }
      }
      if (!nearPocket) {
        // Left and right walls
        if (ball.position.x - ball.radius < 0) {
          ball.position.x = ball.radius;
          ball.velocity.x = -ball.velocity.x * 0.9;
        } else if (ball.position.x + ball.radius > table.width) {
          ball.position.x = table.width - ball.radius;
          ball.velocity.x = -ball.velocity.x * 0.9;
        }

        // Top and bottom walls
        if (ball.position.y - ball.radius < 0) {
          ball.position.y = ball.radius;
          ball.velocity.y = -ball.velocity.y * 0.9;
        } else if (ball.position.y + ball.radius > table.height) {
          ball.position.y = table.height - ball.radius;
          ball.velocity.y = -ball.velocity.y * 0.9;
        }
      }
    }
  }

  void _handleBallCollision(Ball ball1, Ball ball2) {
    final delta = ball2.position - ball1.position;
    final distance = delta.length;
    final minDistance = ball1.radius + ball2.radius;

    if (distance < minDistance) {
      // Separate the balls so they are no longer overlapping
      final overlap = (minDistance - distance) / 2;
      final separationVector = delta.normalized() * overlap;
      ball1.position -= separationVector;
      ball2.position += separationVector;

      // Calculate collision response (elastic collision)
      final collisionNormal = delta.normalized();
      final relativeVelocity = ball2.velocity - ball1.velocity;
      final velocityAlongNormal = relativeVelocity.dot(collisionNormal);

      // Prevent resolving if balls are moving apart
      if (velocityAlongNormal > 0) return;

      // Restitution coefficient for some elasticity
      final restitution = 0.9;

      // Calculate impulse scalar assuming equal mass
      final impulseMagnitude = -(1 + restitution) * velocityAlongNormal / 2;
      final impulse = collisionNormal * impulseMagnitude;

      // Update velocities based on impulse
      ball1.velocity -= impulse;
      ball2.velocity += impulse;
    }
  }

  void _checkPockets(Ball ball) {
    if (table.isInPocket(ball.position, ball.radius)) {
      ball.isPocketed = true;
      ball.velocity = vector.Vector2.zero();
    }
  }

  // void applyCueForce(Ball cueBall, vector.Vector2 target, double power) {
  //   final direction = (target - cueBall.position).normalized();
  //   cueBall.velocity = direction * power * 10;
  // }
  void applyCueForce(Ball cueBall, vector.Vector2 target, double power) {
    final direction = (target - cueBall.position).normalized();
    cueBall.velocity = direction * power * 10; // multiplier 10 affects speed
  }
}
