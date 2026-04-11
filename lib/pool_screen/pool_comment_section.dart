import 'dart:math' as math;
import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  final TextEditingController _textCtrl = TextEditingController();

  final List<_Bubble> _bubbles = [
    _Bubble(
      author: "System",
      you: false,
      text: "Anyone up for a quick game?",
      time: "09:45",
    ),
    _Bubble(
      you: true,
      text: "Sure! I'm practicing the Sicilian Defense",
      time: "09:46",
    ),
    _Bubble(
      prefix: "RU",
      author: "Chess_King",
      role: "Grandmaster",
      text: "The Najdorf variation is really powerful",
      time: "09:47",
    ),
    _Bubble(
      prefix: "IN",
      author: "Strategic_Mind",
      role: "Master",
      text: "I prefer the Dragon variation myself",
      time: "09:48",
    ),
    _Bubble(
      you: true,
      text: "Both are great! Want to discuss endgame strategies?",
      time: "09:50",
    ),
    _Bubble(
      prefix: "NO",
      author: "Magnus_Pro",
      role: "Grandmaster",
      text: "Absolutely! Rook endgames are crucial",
      time: "09:51",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0E1320);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder:
                  (_, __) => CustomPaint(
                    painter: _ChatNebulaPainter(t: _bgCtrl.value),
                  ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                const Divider(height: 1, color: Colors.white10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: _bubbles.length,
                    itemBuilder: (context, i) {
                      final b = _bubbles[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment:
                              b.you
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: _chatBubble(b),
                        ),
                      );
                    },
                  ),
                ),
                _composer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Top bar matching Figma - FIXED
  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _glassIcon(
            Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9A32),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9A32).withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Grandmaster Elite",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  "45 online • 234 members",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          _glassIcon(Icons.notifications_none_rounded),
          const SizedBox(width: 8),
          _glassIcon(Icons.more_vert_rounded),
        ],
      ),
    );
  }

  // Chat bubble
  Widget _chatBubble(_Bubble b) {
    final isYou = b.you;
    final bubbleColor =
        isYou
            ? const LinearGradient(
              colors: [Color(0xFF3A8CFF), Color(0xFF4263FF)],
            )
            : const LinearGradient(
              colors: [Color(0xFF1E2536), Color(0xFF1A2233)],
            );
    final radius = const Radius.circular(16);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        crossAxisAlignment:
            isYou ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isYou && (b.author != null || b.role != null))
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (b.prefix != null)
                    Text(
                      b.prefix!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 1.1,
                      ),
                    ),
                  if (b.prefix != null) const SizedBox(width: 8),
                  if (b.author != null)
                    Text(
                      b.author!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  if (b.role != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6D14A).withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                      child: Text(
                        b.role!,
                        style: const TextStyle(
                          color: Color(0xFFF6D14A),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: isYou ? radius : const Radius.circular(6),
                bottomRight: isYou ? const Radius.circular(6) : radius,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isYou ? const Color(0xFF3A8CFF) : Colors.black)
                      .withOpacity(isYou ? 0.35 : 0.45),
                  blurRadius: isYou ? 18 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              b.text,
              style: TextStyle(
                color: isYou ? Colors.white : Colors.white.withOpacity(0.95),
                fontSize: 14.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: isYou ? 0 : 6, right: isYou ? 6 : 0),
            child: Text(
              b.time,
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Message composer
  Widget _composer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424).withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161C2E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_emoticon_rounded,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                  _glassIcon(Icons.attach_file_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _sendButton(onTap: () => _send(_textCtrl.text)),
        ],
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _bubbles.add(_Bubble(you: true, text: text.trim(), time: _nowHHmm()));
      _textCtrl.clear();
    });
  }

  String _nowHHmm() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(now.hour)}:${two(now.minute)}";
  }

  // Reusable glass icon
  Widget _glassIcon(
    IconData icon, {
    VoidCallback? onTap,
    LinearGradient? gradient,
  }) {
    final iconWidget =
        gradient == null
            ? Icon(icon, color: Colors.white)
            : ShaderMask(
              shaderCallback: (r) => gradient.createShader(r),
              blendMode: BlendMode.srcIn,
              child: Icon(icon, color: Colors.white),
            );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(child: iconWidget),
      ),
    );
  }

  Widget _sendButton({required VoidCallback onTap}) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF21D4FD), Color(0xFFB721FF)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(14.0),
            child: Icon(Icons.send_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

// Data model for a chat bubble
class _Bubble {
  final bool you;
  final String text;
  final String time;
  final String? author;
  final String? role;
  final String? prefix;
  _Bubble({
    this.you = false,
    required this.text,
    required this.time,
    this.author,
    this.role,
    this.prefix,
  });
}

// Animated background painter with the exact blobs/colors
class _ChatNebulaPainter extends CustomPainter {
  final double t;
  _ChatNebulaPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base gradient - UPDATED WITH NEW COLORS
    final base =
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E1647), // deep blue
              Color(0xFF3A298F), // purple blue
              Color(0xFF00A3FF), // cyan accent
              Color(0xFF1A2336), // navy
            ],
          ).createShader(rect);
    canvas.drawRect(rect, base);

    void blob(Color c, Offset center, double r, double glow) {
      final p =
          Paint()
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow)
            ..color = c.withOpacity(0.20);
      canvas.drawCircle(center, r, p);
    }

    final w = size.width;
    final h = size.height;

    // EXACT blobs requested
    blob(
      const Color(0xFF6F49FF),
      Offset(w * (0.2 + 0.02 * math.sin(t * math.pi * 2)), h * 0.15),
      140,
      24,
    );
    blob(
      const Color(0xFF00C2FF),
      Offset(w * 0.85, h * (0.25 + 0.02 * math.cos(t * math.pi * 2))),
      120,
      22,
    );
    blob(
      const Color(0xFF22D38A),
      Offset(w * 0.2, h * (0.7 + 0.03 * math.sin(t * math.pi))),
      160,
      26,
    );
    blob(
      const Color(0xFFFF9A32),
      Offset(w * (0.7 + 0.03 * math.cos(t * math.pi)), h * 0.9),
      130,
      20,
    );

    // Subtle stars
    final star = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 70; i++) {
      final x = (i * 37 % 100) / 100.0 * w;
      final y = (i * 53 % 100) / 100.0 * h;
      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 1.3 : 0.8, star);
    }
  }

  @override
  bool shouldRepaint(covariant _ChatNebulaPainter oldDelegate) =>
      oldDelegate.t != t;
}
