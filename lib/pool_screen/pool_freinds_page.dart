import 'dart:math' as math;
import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final bg = const Color(0xFF0E1320);
    final card = const Color(0xFF161C2E);
    final cardDark = const Color(0xFF0F1424);
    final textPrimary = Colors.white;
    // ignore: unused_local_variable
    final textSecondary = Colors.white70;
    final accentOrange = const Color(0xFFFF9A32);
    final accentPurple = const Color(0xFF9B59FF);
    final accentBlue = const Color(0xFF3DBEFF);
    final accentGreen = const Color(0xFF22D38A);
    final accentYellow = const Color(0xFFF6D14A);
    final offlineGrey = const Color(0xFF7C8499);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Subtle animated starfield/nebula gradient
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (context, _) {
                final t = _glowCtrl.value;
                return CustomPaint(painter: _NebulaPainter(t: t));
              },
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(
                  context,
                  bg: bg,
                  card: card,
                  textPrimary: textPrimary,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader("Your Friends", textPrimary),
                        const SizedBox(height: 12),
                        // Friends list (as in first screenshot)
                        _friendTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: accentOrange,
                          crown: true,
                          name: "Magnus_Pro",
                          badgeText: "Champion",
                          badgeColor: accentYellow,
                          subtitleRole: "Grandmaster",
                          elo: "2850 ELO",
                          wins: "234 wins",
                          games: "312 games",
                          onlineDot: accentGreen,
                          rankTagColor: accentPurple,
                          chatColor: accentBlue,
                          winRate: 0.75,
                          winRateText: "75%",
                        ),
                        const SizedBox(height: 14),
                        _friendTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: accentPurple,
                          crown: true,
                          name: "ChessQueen23",
                          badgeText: "Elite",
                          badgeColor: const Color(0xFFE0B3FF),
                          subtitleRole: "Master",
                          elo: "2680 ELO",
                          wins: "189 wins",
                          games: "256 games",
                          onlineDot: accentGreen,
                          rankTagColor: accentPurple,
                          chatColor: accentBlue,
                          winRate: 0.74,
                          winRateText: "74%",
                        ),
                        const SizedBox(height: 14),
                        _friendTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: const Color(0xFF3A8CFF),
                          knight: true,
                          name: "KnightRider99",
                          subtitleRole: "Expert",
                          elo: "2420 ELO",
                          wins: "156 wins",
                          games: "201 games",
                          onlineDot: accentYellow,
                          rankTagColor: accentPurple,
                          chatColor: accentBlue,
                          winRate: 0.78,
                          winRateText: "78%",
                        ),
                        const SizedBox(height: 14),
                        _friendTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: const Color(0xFF00D1FF),
                          bishop: true,
                          name: "TacticsGuru",
                          subtitleRole: "Master",
                          elo: "2510 ELO",
                          wins: "173 wins",
                          games: "254 games",
                          onlineDot: accentGreen,
                          rankTagColor: accentPurple,
                          chatColor: accentBlue,
                          winRate: 0.68,
                          winRateText: "68%",
                        ),
                        const SizedBox(height: 14),
                        _friendTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: offlineGrey,
                          pawn: true,
                          name: "PawnWarrior",
                          subtitleRole: "Beginner",
                          elo: "1720 ELO",
                          wins: "67 wins",
                          games: "112 games",
                          onlineDot: offlineGrey,
                          rankTagColor: accentPurple,
                          chatColor: accentBlue,
                          winRate: 0.60,
                          winRateText: "60%",
                          dimmed: true,
                        ),
                        const SizedBox(height: 22),
                        _sectionHeader("Suggested Friends", textPrimary),
                        const SizedBox(height: 12),
                        _suggestedTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: accentOrange,
                          crown: true,
                          name: "StrategyMaster",
                          role: "Grandmaster • 2790 ELO",
                          mutual: "12 mutual friends",
                          buttonText: "Add",
                          buttonColor: accentPurple,
                        ),
                        const SizedBox(height: 12),
                        _suggestedTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: accentPurple,
                          rook: true,
                          name: "TacticsNinja",
                          role: "Master • 2560 ELO",
                          mutual: "8 mutual friends",
                          buttonText: "Add",
                          buttonColor: accentPurple,
                        ),
                        const SizedBox(height: 12),
                        _suggestedTile(
                          bg1: card,
                          bg2: cardDark,
                          avatarColor: const Color(0xFF3A8CFF),
                          knight: true,
                          name: "EndgamePro",
                          role: "Expert • 2340 ELO",
                          mutual: "5 mutual friends",
                          buttonText: "Add",
                          buttonColor: accentPurple,
                        ),
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

  Widget _buildTopBar(
    BuildContext context, {
    required Color bg,
    required Color card,
    required Color textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        decoration: _depthDeco(card),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _glassIcon(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_rounded,
                    color: textPrimary.withOpacity(0.9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Friends",
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "6 friends",
                    style: TextStyle(
                      color: textPrimary.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _glassIcon(
              icon: Icons.share_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF6F49FF), Color(0xFF00C2FF)],
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _friendTile({
    required Color bg1,
    required Color bg2,
    required String name,
    required String subtitleRole,
    required String elo,
    required String wins,
    required String games,
    required Color onlineDot,
    required Color rankTagColor,
    required Color chatColor,
    required double winRate,
    required String winRateText,
    required Color avatarColor,
    String? badgeText,
    Color? badgeColor,
    bool crown = false,
    bool knight = false,
    bool bishop = false,
    bool rook = false,
    bool pawn = false,
    bool dimmed = false,
  }) {
    final textPrimary = Colors.white.withOpacity(dimmed ? 0.6 : 0.95);
    final textSecondary = Colors.white70.withOpacity(dimmed ? 0.45 : 0.75);

    return Container(
      decoration: _card3D(bg1, bg2, dimmed: dimmed),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(
                color: avatarColor,
                onlineDot: onlineDot,
                crown: crown,
                knight: knight,
                bishop: bishop,
                rook: rook,
                pawn: pawn,
                dimmed: dimmed,
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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          _chip(
                            badgeText,
                            bg: (badgeColor ?? Colors.white24).withOpacity(
                              dimmed ? 0.15 : 0.2,
                            ),
                            fg: badgeColor ?? Colors.white,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          subtitleRole,
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "  •  $elo",
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$wins   $games",
                          style: TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _pillIcon(
                    Icons.sports_mma_rounded,
                    bg: rankTagColor.withOpacity(dimmed ? 0.20 : 0.25),
                    glow: rankTagColor,
                  ),
                  const SizedBox(height: 10),
                  _pillIcon(
                    Icons.chat_bubble_rounded,
                    bg: chatColor.withOpacity(dimmed ? 0.18 : 0.22),
                    glow: chatColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "Win Rate",
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                winRateText,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _progressBar(
            value: winRate,
            accent: const LinearGradient(
              colors: [Color(0xFF21D4FD), Color(0xFFB721FF)],
            ),
            dimmed: dimmed,
          ),
        ],
      ),
    );
  }

  Widget _suggestedTile({
    required Color bg1,
    required Color bg2,
    required String name,
    required String role,
    required String mutual,
    required String buttonText,
    required Color buttonColor,
    required Color avatarColor,
    bool crown = false,
    bool knight = false,
    bool bishop = false,
    bool rook = false,
    bool pawn = false,
  }) {
    return Container(
      decoration: _card3D(bg1, bg2),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _avatar(
            color: avatarColor,
            crown: crown,
            knight: knight,
            bishop: bishop,
            rook: rook,
            pawn: pawn,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mutual,
                  style: TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          _glassButton(
            text: buttonText,
            gradient: LinearGradient(
              colors: [buttonColor, buttonColor.withOpacity(0.65)],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // UI atoms

  Decoration _depthDeco(Color card) {
    return BoxDecoration(
      color: card.withOpacity(0.65),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.04)),
    );
  }

  BoxDecoration _card3D(Color a, Color b, {bool dimmed = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          a.withOpacity(dimmed ? 0.7 : 0.95),
          b.withOpacity(dimmed ? 0.8 : 0.98),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dimmed ? 0.35 : 0.55),
          blurRadius: 22,
          spreadRadius: 0,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(dimmed ? 0.02 : 0.04),
          blurRadius: 10,
          offset: const Offset(-2, -2),
        ),
      ],
    );
  }

  Widget _avatar({
    required Color color,
    Color? onlineDot,
    bool crown = false,
    bool knight = false,
    bool bishop = false,
    bool rook = false,
    bool pawn = false,
    bool dimmed = false,
  }) {
    IconData piece = Icons.circle;
    if (crown) piece = Icons.emoji_events_rounded;
    if (knight) {
      piece = Icons.chair_alt_rounded; // stylized horse-like silhouette
    }
    if (bishop) piece = Icons.auto_awesome_rounded;
    if (rook) piece = Icons.fort_rounded;
    if (pawn) piece = Icons.circle;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(dimmed ? 0.5 : 0.95),
                color.withOpacity(dimmed ? 0.35 : 0.75),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(dimmed ? 0.25 : 0.45),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(dimmed ? 0.05 : 0.12),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            piece,
            color: Colors.white.withOpacity(dimmed ? 0.7 : 0.95),
            size: 26,
          ),
        ),
        if (onlineDot != null)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onlineDot,
                border: Border.all(color: const Color(0xFF0E1320), width: 3),
                boxShadow: [
                  BoxShadow(color: onlineDot.withOpacity(0.6), blurRadius: 12),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _chip(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            size: 14,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillIcon(IconData icon, {required Color bg, required Color glow}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [BoxShadow(color: glow.withOpacity(0.3), blurRadius: 14)],
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _progressBar({
    required double value,
    required Gradient accent,
    bool dimmed = false,
  }) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(dimmed ? 0.05 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: c.maxWidth * value,
                decoration: BoxDecoration(
                  gradient: accent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _glassButton({
    required String text,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
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
        child: ShaderMask(
          shaderCallback: (r) => gradient.createShader(r),
          blendMode: BlendMode.srcIn,
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassIcon({
    required IconData icon,
    LinearGradient? gradient,
    VoidCallback? onTap,
  }) {
    final base = Container(
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
      child:
          gradient == null
              ? Icon(icon, color: Colors.white)
              : ShaderMask(
                shaderCallback: (r) => gradient.createShader(r),
                blendMode: BlendMode.srcIn,
                child: Icon(icon, color: Colors.white),
              ),
    );
    return GestureDetector(onTap: onTap, child: base);
  }

  Widget _sectionHeader(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.person_add_alt_1_rounded, color: color.withOpacity(0.85)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// Background painter for subtle moving nebula
class _NebulaPainter extends CustomPainter {
  final double t;
  _NebulaPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Deep gradient base - UPDATED WITH NEW COLORS
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

    // Floating blobs
    void blob(Color c, Offset center, double r, double glow) {
      final p =
          Paint()
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow)
            ..color = c.withOpacity(0.18);
      canvas.drawCircle(center, r, p);
    }

    final w = size.width;
    final h = size.height;

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

    // Tiny star specks
    final star = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 80; i++) {
      final x = (i * 37 % 100) / 100.0 * w;
      final y = (i * 53 % 100) / 100.0 * h;
      final r = (i % 3 == 0) ? 1.3 : 0.8;
      canvas.drawCircle(Offset(x, y), r, star);
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) =>
      oldDelegate.t != t;
}
