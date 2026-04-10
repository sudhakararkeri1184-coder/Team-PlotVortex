// lib/chess_screen/chess_CompetitiveMode/widgets/game_result_dialog.dart

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/chess_rank_screen.dart';

// Use same colors
const Color kBgDark = Color(0xFF0A0F2C);
const Color kPrimaryPurple = Color(0xFF7B61FF);
const Color kWinColor = Color(0xFF00FFAB);
const Color kLossColor = Color(0xFFFF4D6D);
const Color kDrawColor = Color(0xFF00D1FF);

class GameResultDialog extends StatefulWidget {
  final String result; // 'win', 'loss', 'draw'
  final int eloChange;
  final int newElo;
  final String? opponentName;
  final VoidCallback onClose;

  const GameResultDialog({
    super.key,
    required this.result,
    required this.eloChange,
    required this.newElo,
    this.opponentName,
    required this.onClose,
  });

  @override
  State<GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<GameResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0),
    );
    _particleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWin = widget.result == 'win';
    final isDraw = widget.result == 'draw';

    final color = isWin ? kWinColor : (isDraw ? kDrawColor : kLossColor);
    final icon =
        isWin
            ? Icons.emoji_events
            : (isDraw ? Icons.handshake : Icons.sentiment_very_dissatisfied);
    final title = isWin ? 'VICTORY' : (isDraw ? 'DRAW' : 'DEFEAT');

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Particle effect for wins
              if (isWin)
                AnimatedBuilder(
                  animation: _particleAnimation,
                  builder:
                      (context, child) => CustomPaint(
                        painter: ParticlePainter(
                          _particleAnimation.value,
                          color,
                        ),
                        size: const Size(300, 400),
                      ),
                ),

              // Main dialog container
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1F3C).withOpacity(0.95),
                      kBgDark.withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color, width: 3),
                  boxShadow: [BoxShadow(color: color, blurRadius: 40)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 80, color: color),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ELO Change display
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${widget.eloChange >= 0 ? '+' : ''}${widget.eloChange} ELO',
                              style: TextStyle(
                                color: color,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'New Rating: ${widget.newElo}',
                              style: const TextStyle(
                                color: kTextSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Close Button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ElevatedButton(
                        onPressed: widget.onClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBgDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle Painter for Victory Screen
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<Particle> particles = [];
  final Random random = Random();

  ParticlePainter(this.progress, this.color) {
    for (int i = 0; i < 50; i++) {
      particles.add(
        Particle(
          x: random.nextDouble() * 300,
          y: random.nextDouble() * 400,
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.5 + 0.2,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var p in particles) {
      final currentY = p.y - progress * 200 * p.speed;
      final opacity = (1 - progress);
      paint.color = color.withOpacity(opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, currentY), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Particle {
  double x, y, size, speed;
  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}
