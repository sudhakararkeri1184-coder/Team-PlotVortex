// lib/chess_screen/chess_CompetitiveMode/widgets/match_found_dialog.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:v2/chess_screen/chess_CompetitiveMode/chess_rank_screen.dart';

// Use colors from the main screen for consistency
const Color kPrimaryPurple = Color(0xFF7B61FF);
const Color kSecondaryBlue = Color(0xFF00D1FF);
const Color kAccentPink = Color(0xFFF72585);
const Color kCardColor = Color(0xFF1A1F3C);

class MatchFoundDialog extends StatefulWidget {
  final String opponentName;
  final int opponentElo;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int timeoutSeconds;

  const MatchFoundDialog({
    super.key,
    required this.opponentName,
    required this.opponentElo,
    required this.onAccept,
    required this.onDecline,
    this.timeoutSeconds = 10,
  });

  @override
  State<MatchFoundDialog> createState() => _MatchFoundDialogState();
}

class _MatchFoundDialogState extends State<MatchFoundDialog>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  Timer? _timer;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeoutSeconds;
    _startTimer();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        if (mounted) widget.onDecline();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: kCardColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: kPrimaryPurple.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryPurple.withOpacity(
                        0.3 + _glowController.value * 0.3,
                      ),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: kSecondaryBlue.withOpacity(
                        0.3 + (1 - _glowController.value) * 0.3,
                      ),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Swords Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shield,
                      color: kPrimaryPurple.withOpacity(0.5),
                      size: 80,
                    ),
                    const Icon(Icons.bolt, color: kSecondaryBlue, size: 70),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'BATTLE FOUND',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 24),

                // Opponent Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kTextSecondary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.opponentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.opponentElo} ELO',
                        style: const TextStyle(
                          color: kSecondaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timer Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _remainingSeconds / widget.timeoutSeconds,
                    minHeight: 10,
                    backgroundColor: kAccentPink.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      kAccentPink,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accept within $_remainingSeconds seconds',
                  style: const TextStyle(
                    color: kAccentPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        text: 'DECLINE',
                        icon: Icons.close,
                        onTap: widget.onDecline,
                        color: kAccentPink,
                        isPrimary: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        text: 'ACCEPT',
                        icon: Icons.check,
                        onTap: widget.onAccept,
                        color: kWinColor,
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
          boxShadow:
              isPrimary
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15)]
                  : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? kBgDark : color, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPrimary ? kBgDark : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
