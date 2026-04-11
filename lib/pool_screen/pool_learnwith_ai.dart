import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:v2/pool_screen/pool_homepage.dart';

class LearnWithAi extends StatefulWidget {
  const LearnWithAi({super.key});

  @override
  State<LearnWithAi> createState() => LearnWithAiState();
}

class LearnWithAiState extends State<LearnWithAi>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E1647), // deep blue
              Color(0xFF3A298F), // purple blue
              Color(0xFF00A3FF), // cyan accent
              Color(0xFF1A2336), // navy
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated blob background
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BlobPainter(_animationController.value),
                  child: Container(),
                );
              },
            ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Navigation Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return poolHome();
                                  },
                                ),
                              );
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.psychology, color: Colors.purpleAccent),
                          SizedBox(width: 8),
                          Text(
                            'AI Learning Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.flash_on, color: Colors.yellow[700]),
                          SizedBox(width: 12),
                          Icon(Icons.power_rounded, color: Colors.greenAccent),
                        ],
                      ),
                    ),
                    // AI Powered Tag
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF613599),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 17),
                                SizedBox(width: 5),
                                Text(
                                  'AI Powered',
                                  style: TextStyle(
                                    color: Color(0xFFD4A1FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    // Choose Experience Title
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, bottom: 1),
                      child: Row(
                        children: [
                          Icon(Icons.radio_button_checked, color: Colors.white),
                          SizedBox(width: 9),
                          Text(
                            'Choose Your AI Experience',
                            style: TextStyle(
                              color: Color(0xFFF0E8FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 15.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    // Play with AI Card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      padding: EdgeInsets.fromLTRB(18, 16, 18, 20),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B2F54),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF2092FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(13),
                                child: Icon(
                                  Icons.sports_esports,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Play with AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                  Text(
                                    'Challenge AI in practice games',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              _chip('Adaptive'),
                              SizedBox(width: 8),
                              _chip('Smart Opponent'),
                            ],
                          ),
                          SizedBox(height: 9),
                          LinearProgressIndicator(
                            minHeight: 6,
                            value: 0.67,
                            backgroundColor: Color(0xFF153567),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF11B1F8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Learn with AI Card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                      padding: EdgeInsets.fromLTRB(18, 18, 18, 20),
                      decoration: BoxDecoration(
                        color: Color(0xFF212148),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFC932FD),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(13),
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Learn with AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                  Text(
                                    'Interactive lessons and tutorials',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              _chipPurple('Guided'),
                              SizedBox(width: 8),
                              _chipPurple('AI Tutor'),
                            ],
                          ),
                          SizedBox(height: 9),
                          LinearProgressIndicator(
                            minHeight: 6,
                            value: 0.87,
                            backgroundColor: Color(0xFF23214B),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF23C8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // AI Features Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      padding: EdgeInsets.fromLTRB(18, 17, 18, 13),
                      decoration: BoxDecoration(
                        color: Color(0xFF1D1C41),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.psychology,
                                color: Colors.purpleAccent,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'AI Features',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _feature(
                                Icons.flash_on,
                                'Real-time Analysis',
                                Colors.yellow[700],
                              ),
                              _feature(
                                Icons.assessment,
                                'Progress Tracking',
                                Color(0xFF2DEB91),
                              ),
                            ],
                          ),
                          SizedBox(height: 7),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _feature(
                                Icons.person_search,
                                'Personalized Learning',
                                Colors.blueAccent,
                              ),
                              _feature(
                                Icons.auto_mode,
                                'Adaptive Difficulty',
                                Colors.purpleAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFF205C89),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _chipPurple(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFF8C40FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.7,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white, size: 18),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for animated blobs
class BlobPainter extends CustomPainter {
  final double animationValue;

  BlobPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animationValue;
    final double w = size.width;
    final double h = size.height;

    // Draw blobs with animation
    blob(
      canvas,
      const Color(0xFF6F49FF),
      Offset(w * (0.2 + 0.02 * math.sin(t * math.pi * 2)), h * 0.15),
      140,
      24,
    );
    blob(
      canvas,
      const Color(0xFF00C2FF),
      Offset(w * 0.85, h * (0.25 + 0.02 * math.cos(t * math.pi * 2))),
      120,
      22,
    );
    blob(
      canvas,
      const Color(0xFF22D38A),
      Offset(w * 0.2, h * (0.7 + 0.03 * math.sin(t * math.pi))),
      160,
      26,
    );
    blob(
      canvas,
      const Color(0xFFFF9A32),
      Offset(w * (0.7 + 0.03 * math.cos(t * math.pi)), h * 0.9),
      130,
      20,
    );
  }

  void blob(
    Canvas canvas,
    Color color,
    Offset position,
    double size,
    double blur,
  ) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.drawCircle(position, size, paint);
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
