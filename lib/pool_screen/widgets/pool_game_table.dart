import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v2/pool_screen/model/pool_ball.dart';
import 'package:v2/pool_screen/model/pool_table.dart';

import 'package:vector_math/vector_math.dart' as vector;
import '../providers/pool_game_provider.dart';

class GameTable extends StatelessWidget {
  const GameTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double scale = constraints.maxWidth / gameProvider.table.width;
            return GestureDetector(
              onPanStart: (details) {
                final position = _getTablePosition(
                  details.localPosition,
                  scale,
                );
                gameProvider.startAiming(position);
              },
              onPanUpdate: (details) {
                final position = _getTablePosition(
                  details.localPosition,
                  scale,
                );
                gameProvider.updateAim(position);
              },
              onPanEnd: (_) {
                gameProvider.shoot();
              },
              child: Container(
                width: gameProvider.table.width * scale,
                height: gameProvider.table.height * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6B2E),
                  border: Border.all(
                    color: const Color(0xFF5C3A1F),
                    width: 14 * scale,
                  ),
                  borderRadius: BorderRadius.circular(8 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4 * scale),
                  child: CustomPaint(
                    painter: TablePainter(
                      balls: gameProvider.balls,
                      table: gameProvider.table,
                      scale: scale,
                      aimStart: gameProvider.aimStart,
                      aimEnd: gameProvider.aimEnd,
                      isAiming: gameProvider.isAiming,
                      shotPower: gameProvider.shotPower,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  vector.Vector2 _getTablePosition(Offset localPosition, double scale) {
    return vector.Vector2(localPosition.dx / scale, localPosition.dy / scale);
  }
}

class TablePainter extends CustomPainter {
  final List<Ball> balls;
  final PoolTable table;
  final double scale;
  final vector.Vector2? aimStart;
  final vector.Vector2? aimEnd;
  final bool isAiming;
  final double shotPower;

  TablePainter({
    required this.balls,
    required this.table,
    required this.scale,
    this.aimStart,
    this.aimEnd,
    required this.isAiming,
    required this.shotPower,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Felt gradient background
    final feltGradient = const RadialGradient(
      center: Alignment(0, 0),
      radius: 1.2,
      colors: [Color(0xFF2E8B42), Color(0xFF1B6B2E), Color(0xFF155D26)],
      stops: [0.0, 0.6, 1.0],
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..shader = feltGradient.createShader(rect));

    // Felt texture (subtle noise effect)
    final texturePaint =
        Paint()
          ..color = Colors.black.withOpacity(0.03)
          ..strokeWidth = 0.5;
    for (int i = 0; i < 60; i++) {
      double y = (size.height / 60) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), texturePaint);
    }

    // Center line
    final centerLinePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.12)
          ..strokeWidth = 2 * scale;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerLinePaint,
    );

    // Head string (where cue ball breaks from)
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height),
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..strokeWidth = 1.5 * scale,
    );

    // Foot spot
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height / 2),
      3 * scale,
      Paint()..color = Colors.white.withOpacity(0.2),
    );

    // Head spot
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height / 2),
      3 * scale,
      Paint()..color = Colors.white.withOpacity(0.2),
    );

    // Draw pockets with premium look
    _drawPockets(canvas, size);

    // Draw balls
    for (final ball in balls) {
      if (!ball.isPocketed) {
        _drawBall(canvas, ball);
      }
    }

    // Draw aiming line
    if (isAiming && aimStart != null && aimEnd != null) {
      _drawAimingLine(canvas, size);
    }
  }

  void _drawPockets(Canvas canvas, Size size) {
    final pocketRadius = 30.0 * scale;

    final pocketPositions = [
      Offset(0, 0),
      Offset(size.width / 2, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width / 2, size.height),
      Offset(size.width, size.height),
    ];

    for (final pos in pocketPositions) {
      // Outer glow
      canvas.drawCircle(
        pos,
        pocketRadius * 1.3,
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Pocket hole
      final pocketGrad = RadialGradient(
        colors: [
          Colors.black,
          Colors.black.withOpacity(0.9),
          const Color(0xFF1A1A1A),
        ],
        stops: const [0.0, 0.7, 1.0],
      );
      canvas.drawCircle(
        pos,
        pocketRadius,
        Paint()
          ..shader = pocketGrad.createShader(
            Rect.fromCircle(center: pos, radius: pocketRadius),
          ),
      );

      // Metallic rim
      canvas.drawCircle(
        pos,
        pocketRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * scale
          ..color = const Color(0xFFB8860B).withOpacity(0.7),
      );
    }
  }

  void _drawBall(Canvas canvas, Ball ball) {
    final center = Offset(ball.position.x * scale, ball.position.y * scale);
    final ballRadius = ball.radius * scale;

    // Ball shadow
    canvas.drawCircle(
      center + Offset(2 * scale, 3 * scale),
      ballRadius,
      Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 * scale),
    );

    if (ball.type == BallType.stripe) {
      // Stripe ball: white base with colored stripe band
      // White base
      final basePaint =
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                Colors.white,
                const Color(0xFFF0F0F0),
                const Color(0xFFD0D0D0),
              ],
              stops: const [0.0, 0.6, 1.0],
            ).createShader(Rect.fromCircle(center: center, radius: ballRadius));
      canvas.drawCircle(center, ballRadius, basePaint);

      // Colored stripe band (horizontal band across the middle)
      canvas.save();
      canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: ballRadius)),
      );
      final stripeRect = Rect.fromCenter(
        center: center,
        width: ballRadius * 2.0,
        height: ballRadius * 1.1,
      );
      final stripePaint = Paint()..color = ball.color;
      canvas.drawRect(stripeRect, stripePaint);
      canvas.restore();

      // Number circle (white)
      canvas.drawCircle(
        center,
        ballRadius * 0.35,
        Paint()..color = Colors.white,
      );
    } else if (ball.type == BallType.eight) {
      // 8-ball: full black with highlights
      canvas.drawCircle(
        center,
        ballRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              const Color(0xFF444444),
              const Color(0xFF111111),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: ballRadius)),
      );

      // Number circle (white)
      canvas.drawCircle(
        center,
        ballRadius * 0.35,
        Paint()..color = Colors.white,
      );
    } else if (ball.type == BallType.cue) {
      // Cue ball: shiny white
      canvas.drawCircle(
        center,
        ballRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              Colors.white,
              const Color(0xFFF5F5F5),
              const Color(0xFFCCCCCC),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: ballRadius)),
      );
    } else {
      // Solid ball: full color
      canvas.drawCircle(
        center,
        ballRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [
              _lighten(ball.color, 0.25),
              ball.color,
              _darken(ball.color, 0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: ballRadius)),
      );

      // Number circle (white)
      canvas.drawCircle(
        center,
        ballRadius * 0.35,
        Paint()..color = Colors.white,
      );
    }

    // Draw ball number
    if (ball.number > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: ball.number.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 9 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // Glossy highlight
    canvas.drawCircle(
      center - Offset(ballRadius * 0.25, ballRadius * 0.25),
      ballRadius * 0.3,
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * scale),
    );

    // Outer rim
    canvas.drawCircle(
      center,
      ballRadius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withOpacity(0.3),
    );
  }

  void _drawAimingLine(Canvas canvas, Size size) {
    final Ball? cueBall = balls.firstWhere(
      (b) => b.number == 0,
      orElse: () => balls[0],
    );
    if (cueBall == null) return;

    final cueCenter = Offset(
      cueBall.position.x * scale,
      cueBall.position.y * scale,
    );

    // Direction from cue ball TOWARD aim point
    final direction = (aimEnd! - cueBall.position);
    if (direction.length < 1) return;
    final dir = direction.normalized();

    // Predict trajectory line (extend from cue ball in aim direction)
    final trajectoryLength = 400.0 * scale;
    final trajectoryEnd = Offset(
      cueCenter.dx + dir.x * trajectoryLength,
      cueCenter.dy + dir.y * trajectoryLength,
    );

    // Dashed trajectory line
    final dashPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 2 * scale
          ..strokeCap = StrokeCap.round;
    _drawDashedLine(canvas, cueCenter, trajectoryEnd, dashPaint);

    // Power indicator (line from aim point AWAY from cue ball)
    final powerLength = shotPower * 60 * scale;
    final powerDir = (cueBall.position - aimEnd!);
    if (powerDir.length > 0) {
      final pDir = powerDir.normalized();
      final powerEnd = Offset(
        cueCenter.dx - pDir.x * powerLength,
        cueCenter.dy - pDir.y * powerLength,
      );

      final powerColor =
          Color.lerp(
            const Color(0xFF00E676),
            const Color(0xFFFF1744),
            shotPower,
          )!;

      canvas.drawLine(
        cueCenter,
        powerEnd,
        Paint()
          ..color = powerColor
          ..strokeWidth = 4 * scale
          ..strokeCap = StrokeCap.round,
      );

      // Power glow
      canvas.drawLine(
        cueCenter,
        powerEnd,
        Paint()
          ..color = powerColor.withOpacity(0.3)
          ..strokeWidth = 10 * scale
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Aim crosshair at cue ball
    final crossSize = 8 * scale;
    final crossPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..strokeWidth = 1.5 * scale;
    canvas.drawLine(
      Offset(cueCenter.dx - crossSize, cueCenter.dy),
      Offset(cueCenter.dx + crossSize, cueCenter.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(cueCenter.dx, cueCenter.dy - crossSize),
      Offset(cueCenter.dx, cueCenter.dy + crossSize),
      crossPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    final delta = to - from;
    final distance = delta.distance;
    if (distance == 0) return;
    final direction = delta / distance;

    const dashWidth = 8.0;
    const dashSpace = 6.0;

    double start = 0;
    while (start < distance) {
      final p1 = from + direction * start;
      final end = (start + dashWidth).clamp(0.0, distance);
      final p2 = from + direction * end;
      canvas.drawLine(p1, p2, paint);
      start += dashWidth + dashSpace;
    }
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(TablePainter oldDelegate) => true;
}
