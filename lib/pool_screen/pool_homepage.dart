import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:v2/chess_screen/chess_enter_tournament.dart' show Tournament;
import 'package:v2/pool_screen/pool_community_page.dart';
import 'package:v2/pool_screen/pool_enter_tournament.dart';
import 'package:v2/pool_screen/pool_freinds_page.dart';
import 'package:v2/pool_screen/pool_learnwith_ai.dart';
import 'package:v2/pool_screen/pool_ledder_board.dart';
import 'package:v2/pool_screen/pool_multiplayer.dart';
import 'package:v2/pool_screen/pool_offline_mode.dart';
import 'package:v2/pool_screen/providers/pool_game_provider.dart';
import 'package:v2/pool_screen/screens/pool_game_screen.dart';
// import 'package:poolgameui/community_page.dart';
// import 'package:poolgameui/enter_tournament.dart';
// import 'package:poolgameui/freinds_page.dart';

// import 'package:poolgameui/learnwith_ai.dart';
// import 'package:poolgameui/ledder_board.dart';
// import 'package:poolgameui/multiplayer.dart';
// import 'package:poolgameui/offline_mode.dart';
// import 'package:poolgameui/screens/game_screen.dart';

class poolHome extends StatelessWidget {
  const poolHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const PoolHomepage();
  }
}

class PoolHomepage extends StatefulWidget {
  const PoolHomepage({super.key});

  @override
  State<PoolHomepage> createState() => _poolHomePageState();
}

// ignore: camel_case_types
class _poolHomePageState extends State<PoolHomepage>
    with TickerProviderStateMixin {
  final Color background = const Color(0xFF191B24);
  final Color cardDark = const ui.Color.fromARGB(255, 21, 23, 33);
  final Color accentPurple = const Color(0xFF8769E8);
  final Color accentGreen = const Color(0xFF14D085);
  final Color accentPink = const Color(0xFFE869A1);
  final Color accentYellow = const Color(0xFFF9A53C);
  final Color accentBlue = const Color(0xFF3C7AF9);
  final Color accentRed = const Color(0xFFDB4653);
  final Color accentOrange = const Color(0xFFF9A53C);

  late AnimationController _animationController;
  late AnimationController _blobAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late ScrollController _scrollController = ScrollController();
  bool _showBars = true;
  //  ScrollController _scrollController = ScrollController();
  double _lastOffset = 0.0;
  final double _threshold = 150.0;
  void _scrollListener() {
    double currentOffset = _scrollController.offset;

    if (currentOffset - _lastOffset > _threshold) {
      // log("scroll");
      // scrolling down → hide
      if (_showBars) setState(() => _showBars = false);
      _lastOffset = currentOffset;
    } else if (_lastOffset - currentOffset > _threshold) {
      // scrolling up → show
      if (!_showBars) setState(() => _showBars = true);
      _lastOffset = currentOffset;
    }
  }

  final List<bool> _isHovering = [false, false, false, false];
  final List<Offset> _hoverPositions = [
    const Offset(100, 100),
    const Offset(100, 100),
    const Offset(100, 100),
    const Offset(100, 100),
  ];
  final double _scrollOffset = 0.0;
  // ignore: unused_field
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _blobAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _blobAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 12;

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          // Gradient Background Base Layer
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E1647), // deep blue
                    Color(0xFF3A298F), // purple blue
                    Color(0xFF00A3FF), // cyan accent
                    Color(0xFF1A2336), // navy
                  ],
                ),
              ),
            ),
          ),

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

          // Subtle overlay to enhance depth
          Container(color: Colors.black.withOpacity(0.2)),

          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: _slideAnimation.value * 20,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding,
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: Stack(
                            children: [
                              // Backdrop filter wrapped properly
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 75,
                                    decoration: BoxDecoration(
                                      color: cardDark.withOpacity(1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 75,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Row(
                                        children: const [
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "♔ pool Master ♛",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: accentYellow
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.emoji_events,
                                                      color: accentYellow,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      "Grandmaster",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return LeadderBoard();
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            1,
                                            1,
                                            10,
                                          ).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.trending_up,
                                          color: const Color.fromARGB(
                                            255,
                                            173,
                                            176,
                                            31,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return FriendsPage();
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            1,
                                            1,
                                            10,
                                          ).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person_outlined,
                                          color: const Color.fromARGB(
                                            255,
                                            234,
                                            233,
                                            231,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return CommunityPage();
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            1,
                                            1,
                                            10,
                                          ).withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.chalet_outlined,
                                          color: const Color.fromARGB(
                                            255,
                                            63,
                                            189,
                                            73,
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
                  },
                ),

                // Hero card with background image
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: _slideAnimation.value * 15,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: double.infinity,
                                height: 240,
                                decoration: BoxDecoration(
                                  color: cardDark.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/imagen-4.0-ultra-generate-preview-06-06_give_3D_animated_ima.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 16,
                                      top: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentGreen,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          "Live Game",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 17),

                // "Game Modes" label
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: _slideAnimation.value * 10,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 24,
                            bottom: 2,
                            top: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_checked,
                                color: accentPurple,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Game Modes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // four cards grid (2x2)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return OfflineMode();
                                    },
                                  ),
                                );
                              },
                              child: tweenAnimatedCard(
                                durationMs: 800,
                                child: animatedGameModeCard(
                                  index: 0,
                                  title: "Offline Mode",
                                  subtitle: "Play against AI without internet",
                                  chipText: "Adaptive",
                                  chipColor: accentBlue,
                                  trailing: "vs AI",
                                  icon: Icons.wifi_off,
                                  bgColor: cardDark.withOpacity(0.9),
                                  subtitleColor: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Multiplayer();
                                    },
                                  ),
                                );
                              },
                              child: tweenAnimatedCard(
                                durationMs: 900,
                                child: animatedGameModeCard(
                                  index: 1,
                                  title: "Multiplayer",
                                  subtitle: "Play with players worldwide",
                                  chipText: "Varied",
                                  chipColor: accentPurple,
                                  trailing: "2.4K ",
                                  icon: Icons.public,
                                  bgColor: cardDark.withOpacity(0.9),
                                  subtitleColor: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChangeNotifierProvider(
                                          create: (_) => GameProvider(),
                                          child:
                                              GameScreen(), // Your widget with the Consumer
                                        ),
                                  ),
                                );
                              },
                              child: tweenAnimatedCard(
                                durationMs: 1000,
                                child: animatedGameModeCard(
                                  index: 2,
                                  title: "Play with Buddy",
                                  subtitle: "Challenge your friends",
                                  chipText: "Social",
                                  chipColor: accentGreen,
                                  trailing: "12 Friends",
                                  icon: Icons.people,
                                  bgColor: cardDark.withOpacity(0.9),
                                  subtitleColor: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LearnWithAi();
                                    },
                                  ),
                                );
                              },
                              child: tweenAnimatedCard(
                                durationMs: 1100,
                                child: animatedGameModeCard(
                                  index: 3,
                                  title: "Learn with AI",
                                  subtitle: "Master pool with AI tutor",
                                  chipText: "Tutorial",
                                  chipColor: accentPink,
                                  trailing: "AI Coach",
                                  icon: Icons.auto_awesome,
                                  bgColor: cardDark.withOpacity(0.9),
                                  subtitleColor: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Tournament promo card
                tweenAnimatedCard(
                  durationMs: 1300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 28,
                        left: 23,
                        right: 23,
                        bottom: 26,
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            accentOrange.withOpacity(0.98),
                            accentRed.withOpacity(0.98),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sports_kabaddi,
                            color: Colors.white,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Join Tournament",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Compete with pool masters worldwide",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.attach_money,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Prize Pool: \$10K",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.people, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                "2,847 Players",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white12,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 11,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Tournament();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Enter Tournament",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showBars ? 0 : -80, // hides fully
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1A2E), // dark navy / blue tone (top)
                    Color(0xFF16213E), // slightly deeper blue
                    Color(0xFF0F3460), // purple-blue transition
                    Color(0xFF1B2A49),
                  ],
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 60),
                  Icon(Icons.home),
                  Spacer(),
                  Icon(Icons.person),
                  SizedBox(width: 60),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showBars ? 40 : -100, // slide out when hidden
            left: MediaQuery.of(context).size.width / 2 - 34, // center align
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showBars ? 1 : 0,
              child: Container(
                // margin: EdgeInsets.all(8),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF9D423), Color(0xFFFF4E50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showBars ? 50 : -100, // slide out when hidden
            left: MediaQuery.of(context).size.width / 2 - 28, // center align
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showBars ? 1 : 0,
              child: GestureDetector(
                onTap: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: Image.network(
                    "https://cdn-icons-png.flaticon.com/512/3943/3943584.png",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tweenAnimatedCard({
    required int durationMs,
    required Widget child,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      key: key,
      duration: Duration(milliseconds: durationMs),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, w) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: w,
          ),
        );
      },
      child: child,
    );
  }

  Widget animatedGameModeCard({
    required int index,
    required String title,
    required String subtitle,
    required String chipText,
    required Color chipColor,
    required String trailing,
    required IconData icon,
    required Color bgColor,
    required Color subtitleColor,
  }) {
    return MouseRegion(
      onEnter: (details) {
        setState(() {
          _isHovering[index] = true;
          _hoverPositions[index] = details.localPosition;
        });
      },
      onHover: (details) {
        setState(() {
          _hoverPositions[index] = details.localPosition;
        });
      },
      onExit: (details) {
        setState(() {
          _isHovering[index] = false;
          _hoverPositions[index] = const Offset(100, 100);
        });
      },
      child: Builder(
        builder: (context) {
          final bool hovering = _isHovering[index];
          final Offset position = _hoverPositions[index];
          final double perspective = 1000.0;
          final double normalizedX = (position.dx - 100) / 100;
          final double normalizedY = (position.dy - 100) / 100;
          final double tiltX = hovering ? 0.08 * normalizedY : 0.0;
          final double tiltY = hovering ? 0.08 * -normalizedX : 0.0;
          Matrix4 transform =
              Matrix4.identity()
                ..setEntry(3, 2, 1.0 / perspective)
                ..rotateX(tiltX)
                ..rotateY(tiltY);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: AnimatedScale(
              scale: hovering ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 200,
                width: 200,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient:
                      hovering
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              chipColor.withOpacity(0.3),
                              chipColor.withOpacity(0.1),
                              bgColor.withOpacity(0.8),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          )
                          : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              bgColor.withOpacity(0.9),
                              bgColor.withOpacity(0.7),
                              bgColor.withOpacity(0.9),
                            ],
                          ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      hovering
                          ? Border.all(
                            color: chipColor.withOpacity(0.6),
                            width: 2,
                          )
                          : Border.all(color: Colors.transparent, width: 0),
                  boxShadow:
                      hovering
                          ? [
                            BoxShadow(
                              color: chipColor.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: chipColor.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 1,
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
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 10,
                      child: AnimatedOpacity(
                        opacity: hovering ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.circle,
                          color: chipColor.withOpacity(0.3),
                          size: 60,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedScale(
                          scale: hovering ? 1.3 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: Icon(icon, color: chipColor, size: 32),
                        ),
                        const SizedBox(height: 12),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: hovering ? 16 : 15,
                            shadows:
                                hovering
                                    ? [
                                      Shadow(
                                        color: chipColor.withOpacity(0.8),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Text(title),
                        ),
                        const SizedBox(height: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color:
                                hovering
                                    ? Colors.white.withOpacity(0.9)
                                    : subtitleColor,
                            fontSize: hovering ? 14 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                          child: Text(subtitle),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    hovering
                                        ? chipColor.withOpacity(0.3)
                                        : chipColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      hovering
                                          ? chipColor.withOpacity(0.6)
                                          : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                chipText,
                                style: TextStyle(
                                  color: chipColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: hovering ? 13 : 12,
                                ),
                              ),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                color: chipColor,
                                fontWeight: FontWeight.bold,
                                fontSize: hovering ? 13 : 12,
                                shadows:
                                    hovering
                                        ? [
                                          Shadow(
                                            color: chipColor.withOpacity(0.4),
                                            blurRadius: 5,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                        : [],
                              ),
                              child: Text(trailing),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 🎨 Custom Painter with Deep Blue/Purple Gradient Colors
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
      paint.color = color.withOpacity(0.4);
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);

      // Create animated path for blob
      final path = Path();
      const points = 8;
      for (int i = 0; i < points; i++) {
        final angle = (i / points) * 2 * math.pi;
        final animatedRadius =
            baseRadius +
            25 * math.sin(animation * 2 * math.pi + i) +
            15 * math.cos(animation * 3 * math.pi + i * 0.5);

        final x = position.dx + animatedRadius * math.cos(angle);
        final y =
            position.dy + animatedRadius * math.sin(angle) - scrollOffset * 0.3;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevAngle = ((i - 1) / points) * 2 * math.pi;
          final prevRadius =
              baseRadius +
              25 * math.sin(animation * 2 * math.pi + (i - 1)) +
              15 * math.cos(animation * 3 * math.pi + (i - 1) * 0.5);
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

    // Animated blobs with reduced opacity to complement gradient background

    // Blob 1: Light Purple (Top Left)
    drawBlob(
      const Color(0xFF9D7EE8),
      Offset(w * (0.18 + 0.04 * math.sin(t * math.pi * 2)), h * 0.15),
      165,
      35,
    );

    // Blob 2: Bright Cyan (Top Right)
    drawBlob(
      const Color(0xFF00D4FF),
      Offset(w * 0.85, h * (0.25 + 0.03 * math.cos(t * math.pi * 1.8))),
      150,
      32,
    );

    // Blob 3: Electric Blue (Bottom Left)
    drawBlob(
      const Color(0xFF4A90E2),
      Offset(w * 0.2, h * (0.72 + 0.035 * math.sin(t * math.pi * 1.5))),
      185,
      38,
    );

    // Blob 4: Deep Purple (Bottom Right)
    drawBlob(
      const Color(0xFF6B4FBB),
      Offset(w * (0.78 + 0.035 * math.cos(t * math.pi * 1.6)), h * 0.88),
      160,
      30,
    );
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.scrollOffset != scrollOffset;
}
