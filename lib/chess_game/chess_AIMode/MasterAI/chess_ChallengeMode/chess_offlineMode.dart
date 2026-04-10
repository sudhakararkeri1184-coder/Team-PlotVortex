import 'package:flutter/material.dart';
import 'package:v2/chess_screen/chess_ChallengeMode/quizesection.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'person_vs_person.dart';
import 'person_vs_computer.dart';

class OfflineMode extends StatefulWidget {
  const OfflineMode({super.key});

  @override
  State<OfflineMode> createState() => OfflineModeState();
}

class OfflineModeState extends State<OfflineMode>
    with SingleTickerProviderStateMixin {
  late AnimationController _blobAnimationController;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    _blobAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _blobAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10152B),
      body: Stack(
        children: [
          // Animated blob background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blobAnimationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BlobPainter(
                    animation: _blobAnimationController.value,
                    scrollOffset: _scrollOffset,
                  ),
                  child: Container(),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top navigation bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.sports_esports, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Challenge Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.settings, color: Colors.white),
                      ],
                    ),
                  ),

                  // Local Play Tab
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF191E39).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          color: Color(0xFF8E9CFF),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Local Play',
                          style: TextStyle(
                            color: Color(0xFF8E9CFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),

                  // Person vs Person Card
                  PersonVsPerson(),
                  SizedBox(height: 18),

                  // Person vs Computer Card
                  PersonVsComputer(),
                  SizedBox(height: 28),
                  QuizeCard(),
                  SizedBox(height: 28),
                  // Bottom Info Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bottomInfo(
                          Icons.flash_on,
                          'Quick Play',
                          '5-15 min games',
                        ),
                        _bottomInfo(
                          Icons.leaderboard,
                          'AI Levels',
                          'Beginner to Master',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomInfo(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF191E39).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for animated blobs
class BlobPainter extends CustomPainter {
  final double animation;
  final double scrollOffset;

  BlobPainter({required this.animation, required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Helper function to draw a blob
    void drawBlob(
      Color color,
      Offset position,
      double baseRadius,
      double blurRadius,
    ) {
      paint.color = color.withOpacity(0.25);
      paint.maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius);

      // Create animated path for blob
      final path = Path();
      const points = 8;
      for (int i = 0; i < points; i++) {
        final angle = (i / points) * 2 * math.pi;
        final animatedRadius =
            baseRadius +
            20 * math.sin(animation * 2 * math.pi + i) +
            10 * math.cos(animation * 3 * math.pi + i * 0.5);

        final x = position.dx + animatedRadius * math.cos(angle);
        final y =
            position.dy + animatedRadius * math.sin(angle) - scrollOffset * 0.3;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevAngle = ((i - 1) / points) * 2 * math.pi;
          final prevRadius =
              baseRadius +
              20 * math.sin(animation * 2 * math.pi + (i - 1)) +
              10 * math.cos(animation * 3 * math.pi + (i - 1) * 0.5);
          final prevX = position.dx + prevRadius * math.cos(prevAngle);
          final prevY =
              position.dy +
              prevRadius * math.sin(prevAngle) -
              scrollOffset * 0.3;

          final cpX = (prevX + x) / 2;
          final cpY = (prevY + y) / 2;
          path.quadraticBezierTo(cpX, cpY, x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    final w = size.width;
    final h = size.height;
    final t = animation;

    // Draw animated blobs
    drawBlob(
      const Color(0xFF6F49FF),
      Offset(w * (0.2 + 0.02 * math.sin(t * math.pi * 2)), h * 0.15),
      140,
      24,
    );

    drawBlob(
      const Color(0xFF00C2FF),
      Offset(w * 0.85, h * (0.25 + 0.02 * math.cos(t * math.pi * 2))),
      120,
      22,
    );

    drawBlob(
      const Color(0xFF22D38A),
      Offset(w * 0.2, h * (0.7 + 0.03 * math.sin(t * math.pi))),
      160,
      26,
    );

    drawBlob(
      const Color(0xFFFF9A32),
      Offset(w * (0.7 + 0.03 * math.cos(t * math.pi)), h * 0.9),
      130,
      20,
    );
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.scrollOffset != scrollOffset;
}
