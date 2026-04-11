import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:v2/pool_screen/pool_comment_section.dart';
// import 'package:poolgameui/comment_section.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgCtrl;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0E1320);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Animated nebula background with the exact four blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder:
                  (_, __) => CustomPaint(
                    painter: _CommunityNebulaPainter(t: _bgCtrl.value),
                  ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Community Chats card (first screenshot)
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rowIconTitle(
                                icon: Icons.chat_bubble_rounded,
                                title: "Community Chats",
                              ),
                              const SizedBox(height: 12),
                              _chatTile(
                                leadingColor: const Color(0xFFFF9A32),
                                icon: Icons.workspace_premium_rounded,
                                title: "Grandmaster Elite",
                                crown: true,
                                time: "2m ago",
                                subtitle: "234 members • 45 online",
                                lastMsg: "Anyone up for a quick game?",
                                badge: "3",
                              ),
                              const SizedBox(height: 12),
                              _chatTile(
                                leadingColor: const Color(0xFF9B59FF),
                                icon: Icons.auto_awesome_rounded,
                                title: "Master League",
                                time: "5m ago",
                                subtitle: "456 members • 78 online",
                                lastMsg: "Great tournament today!",
                                badge: null,
                              ),
                              const SizedBox(height: 12),
                              _chatTile(
                                leadingColor: const Color(0xFF3A8CFF),
                                icon: Icons.castle_rounded,
                                title: "Expert Circle",
                                time: "15m ago",
                                subtitle: "789 members • 123 online",
                                lastMsg: "Check out this opening!",
                                badge: "7",
                              ),
                              const SizedBox(height: 12),
                              _chatTile(
                                leadingColor: const Color(0xFF22D38A),
                                icon:
                                    Icons
                                        .microwave_rounded, // simple bishop-like glyph
                                title: "Chess Beginners",
                                time: "1h ago",
                                subtitle: "1024 members • 234 online",
                                lastMsg: "How do I improve my game?",
                                badge: null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Trending Topics card (second screenshot)
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _rowIconTitle(
                                icon: Icons.trending_up_rounded,
                                title: "Trending Topics",
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: const [
                                  _TopicChip(
                                    text: "#GrandmasterTips",
                                    sub: "2.4K posts",
                                  ),
                                  _TopicChip(
                                    text: "#ChessTournament",
                                    sub: "1.8K posts",
                                  ),
                                  _TopicChip(
                                    text: "#OpeningMoves",
                                    sub: "1.2K posts",
                                  ),
                                  _TopicChip(
                                    text: "#ChessStrategy",
                                    sub: "956 posts",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Space for continuing sections (e.g., Community Feed) if needed
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Top app bar that matches Figma - FIXED
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161C2E).withOpacity(0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _glassIcon(
              Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Community",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Join the conversation",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _glassIcon(
              Icons.help_outline_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF6F49FF), Color(0xFF00C2FF)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section container with 3D effect
  Widget _sectionCard({required Widget child}) {
    return Container(
      decoration: _card3D(),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }

  // Community chat tile row
  Widget _chatTile({
    required Color leadingColor,
    required IconData icon,
    required String title,
    required String time,
    required String subtitle,
    required String lastMsg,
    String? badge,
    bool crown = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CommentSection();
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: leadingColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: leadingColor.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D38A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0E1320),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22D38A).withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (crown)
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                      const Spacer(),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (badge != null)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D38A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22D38A).withOpacity(0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Small title row
  Widget _rowIconTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
          ),
        ),
      ],
    );
  }

  // 3D card decoration
  BoxDecoration _card3D() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF161C2E), Color(0xFF0F1424)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 22,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(-2, -2),
        ),
      ],
    );
  }

  // Shared glass icon helper (fixed)
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
}

// Topic chip used in Trending section
class _TopicChip extends StatelessWidget {
  final String text;
  final String sub;
  const _TopicChip({required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1424),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF22D38A),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated background painter with the exact blob colors/positions
class _CommunityNebulaPainter extends CustomPainter {
  final double t;
  _CommunityNebulaPainter({required this.t});

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

    // Helper for soft blobs
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

    // Sparse stars
    final star = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 80; i++) {
      final x = (i * 41 % 100) / 100.0 * w;
      final y = (i * 67 % 100) / 100.0 * h;
      final r = (i % 3 == 0) ? 1.3 : 0.8;
      canvas.drawCircle(Offset(x, y), r, star);
    }
  }

  @override
  bool shouldRepaint(covariant _CommunityNebulaPainter oldDelegate) =>
      oldDelegate.t != t;
}
