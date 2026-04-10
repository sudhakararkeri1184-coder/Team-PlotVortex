// lib/aurora_background.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF10121A), // A very dark, deep blue base
      child: Stack(
        children: [
          // The animated, blurred color shapes that create the aurora effect
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // We use Positioned and Transform to create a slow, diagonal drift
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(0, _animation.value * 100),
                      child: _buildColorWave(
                        const Color(0xFF3A2A6A),
                        -0.5,
                        0.4,
                      ), // Purple
                    ),
                  ),
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(_animation.value * 100, 0),
                      child: _buildColorWave(
                        const Color(0xFF2A4A8A),
                        0.5,
                        0.6,
                      ), // Blue
                    ),
                  ),
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(-_animation.value * 150, 0),
                      child: _buildColorWave(
                        const Color(0xFF2AC5B4),
                        0.0,
                        0.8,
                      ), // Cyan
                    ),
                  ),
                ],
              );
            },
          ),

          // The heavy blur effect that blends the shapes together
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(color: Colors.transparent),
          ),

          // Subtle grainy texture overlay for a premium feel
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black26],
                radius: 1.0,
              ),
            ),
          ),

          // The actual UI content on top
          widget.child,
        ],
      ),
    );
  }

  Widget _buildColorWave(Color color, double alignX, double scale) {
    return Align(
      alignment: Alignment(alignX, 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8 * scale,
        height: MediaQuery.of(context).size.height * 0.8 * scale,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
