import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:v2/pool_screen/pool_homepage.dart';

class LeadderBoard extends StatefulWidget {
  const LeadderBoard({super.key});

  @override
  State<LeadderBoard> createState() => _LeadderBoardState();
}

class _LeadderBoardState extends State<LeadderBoard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _blobController;
  late Animation<double> _animation;

  final List<LeaderboardUser> users = [
    LeaderboardUser(
      4,
      "TacticsMaster",
      "RU",
      "Grandmaster",
      "King's Indian",
      2754,
      87,
      44,
      const Color(0xFFE91E63),
    ),
    LeaderboardUser(
      5,
      "EndgamePro",
      "CN",
      "Master",
      "French Defense",
      2698,
      85,
      51,
      const Color(0xFF9C27B0),
    ),
    LeaderboardUser(
      6,
      "ChessQueen23",
      "GB",
      "Master",
      "Italian Game",
      2645,
      83,
      46,
      const Color(0xFF673AB7),
    ),
    LeaderboardUser(
      7,
      "KnightRider99",
      "FR",
      "Master",
      "Caro-Kann",
      2587,
      81,
      47,
      const Color(0xFF3F51B5),
    ),
    LeaderboardUser(
      8,
      "RookMaster",
      "DE",
      "Expert",
      "English Opening",
      2534,
      79,
      49,
      const Color(0xFF2196F3),
    ),
    LeaderboardUser(
      9,
      "BishopKing",
      "ES",
      "Expert",
      "Nimzo-Indian",
      2489,
      77,
      50,
      const Color(0xFF00BCD4),
    ),
    LeaderboardUser(
      10,
      "PawnWarrior",
      "IT",
      "Expert",
      "Scandinavian",
      2432,
      74,
      53,
      const Color(0xFF009688),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _blobController.dispose();
    super.dispose();
  }

  Widget _buildPodium(double animationValue) {
    double rotationY = math.sin(animationValue) * 0.1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 2nd Place
        _PodiumBlock(
          width: 95,
          height: 150,
          label: "Magnus_Pro",
          subtitle: "2985 ELO",
          opening: "Queen's Gambit",
          rank: 2,
          gradient: const LinearGradient(
            colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          rotationY: rotationY * -1,
        ),
        // 1st Place
        _PodiumBlock(
          width: 105,
          height: 190,
          label: "ChessLegend_99",
          subtitle: "3120 ELO",
          opening: "Sicilian Defense",
          rank: 1,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          rotationY: rotationY,
          crown: true,
        ),
        // 3rd Place
        _PodiumBlock(
          width: 95,
          height: 140,
          label: "StrategyKing",
          subtitle: "2876 ELO",
          opening: "Ruy Lopez",
          rank: 3,
          gradient: const LinearGradient(
            colors: [Color(0xFFCD7F32), Color(0xFF8B4513)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          rotationY: rotationY * -1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1320),
      body: Stack(
        children: [
          // Animated blob background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LeaderboardBlobPainter(t: _blobController.value),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildCustomAppBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Animated Podium with rotation
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return _buildPodium(_animation.value);
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Section Title
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber[400],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Top Chess Champions",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Leaderboard List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          itemBuilder: (context, index) {
                            final u = users[index];
                            return _LeaderboardTile(user: u, rank: u.rank);
                          },
                        ),

                        const SizedBox(height: 20),
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

  Widget _buildCustomAppBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return poolHome();
                      },
                    ),
                  ),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Text(
              "Pool Leaderboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Trophy icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final String subtitle;
  final String opening;
  final int rank;
  final Gradient gradient;
  final double rotationY;
  final bool crown;

  const _PodiumBlock({
    required this.width,
    required this.height,
    required this.label,
    required this.subtitle,
    required this.opening,
    required this.rank,
    required this.gradient,
    this.rotationY = 0,
    this.crown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotationY),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown for 1st place
          if (crown)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 32,
                color: Colors.white,
              ),
            ),

          // Podium block
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  opening,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              rank.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name, country, title, opening;
  final int elo, winRate, avgMoves;
  final Color color;

  LeaderboardUser(
    this.rank,
    this.name,
    this.country,
    this.title,
    this.opening,
    this.elo,
    this.winRate,
    this.avgMoves,
    this.color,
  );
}

class _LeaderboardTile extends StatefulWidget {
  final LeaderboardUser user;
  final int rank;
  // ignore: unused_element_parameter
  const _LeaderboardTile({required this.user, required this.rank, super.key});

  @override
  State<_LeaderboardTile> createState() => _LeaderboardTileState();
}

class _LeaderboardTileState extends State<_LeaderboardTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                _isHovered
                    ? [
                      widget.user.color.withOpacity(0.2),
                      widget.user.color.withOpacity(0.05),
                    ]
                    : [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                _isHovered
                    ? widget.user.color.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow:
              _isHovered
                  ? [
                    BoxShadow(
                      color: widget.user.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.user.color,
                    widget.user.color.withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _isHovered ? Colors.white : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.user.color.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                "#${widget.rank}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.user.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            shadows:
                                _isHovered
                                    ? [
                                      Shadow(
                                        color: widget.user.color.withOpacity(
                                          0.5,
                                        ),
                                        blurRadius: 8,
                                      ),
                                    ]
                                    : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.user.color,
                              widget.user.color.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.user.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.user.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.user.country,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.user.opening,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.user.color.withOpacity(0.3),
                        widget.user.color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.user.color.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    widget.user.elo.toString(),
                    style: TextStyle(
                      color: widget.user.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: widget.user.color.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF4CAF50),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.user.winRate}%",
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  "${widget.user.avgMoves} avg moves",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Animated background painter with blobs
class _LeaderboardBlobPainter extends CustomPainter {
  final double t;
  _LeaderboardBlobPainter({required this.t});

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
  bool shouldRepaint(covariant _LeaderboardBlobPainter oldDelegate) =>
      oldDelegate.t != t;
}
