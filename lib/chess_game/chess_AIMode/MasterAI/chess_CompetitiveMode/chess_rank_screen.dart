// lib/screens/chess_rank_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:v2/chess_screen/chess_CompetitiveMode/competitive_chess_board_screen.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/rank_criteria_dialog.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/rank_info.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/widgets/match_found_dialog.dart';

// --- GAMING UI THEME COLORS ---
const Color kBgDark = Color(0xFF0A0F2C);
const Color kCardColor = Color(0xFF1A1F3C);
const Color kPrimaryPurple = Color(0xFF7B61FF);
const Color kSecondaryBlue = Color(0xFF00D1FF);
const Color kAccentPink = Color(0xFFF72585);
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xFF8D99AE);
const Color kWinColor = Color(0xFF00FFAB);
const Color kLossColor = Color(0xFFFF4D6D);

class ChessRankScreen extends StatefulWidget {
  const ChessRankScreen({super.key});

  @override
  State<ChessRankScreen> createState() => _ChessRankScreenState();
}

class _ChessRankScreenState extends State<ChessRankScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  bool _isSearching = false;
  String _statusMessage = "Ready for the next challenge!";
  StreamSubscription? _lobbySubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _playerElo = 1200;
  String _playerRank = "Bronze";
  String _playerGamertag = "Player";
  int _matchesPlayed = 0;
  int _wins = 0;
  int _losses = 0;
  int _rankProgressWins = 0;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _fetchPlayerData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _cancelSearch(showMessage: false);
    super.dispose();
  }

  Future<void> _fetchPlayerData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _playerElo = userDoc.data()?['elo'] ?? 1200;

          // ✅ CORRECTED: This logic is crucial. It prioritizes the 'rank' field
          // from the database, which is now updated by our backend logic.
          // It falls back to calculating from ELO only if the field is missing.
          _playerRank =
              userDoc.data()?['rank'] ??
              RankInfo.getRankFromElo(_playerElo).name;

          _playerGamertag = userDoc.data()?['gamertag'] ?? "Player";
          _matchesPlayed = userDoc.data()?['matches_played'] ?? 0;
          _wins = userDoc.data()?['wins'] ?? 0;
          _losses = userDoc.data()?['losses'] ?? 0;
          _rankProgressWins = userDoc.data()?['rank_progress_wins'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching player data: $e");
    }
  }

  void _navigateToGame(String lobbyId, bool isHost) {
    if (!mounted) return;
    _cancelSearch(showMessage: false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) =>
                MultiplayerChessBoardScreen(lobbyId: lobbyId, isHost: isHost),
      ),
    );
  }

  Future<void> _toggleSearch() async {
    if (_isSearching) {
      await _cancelSearch();
    } else {
      await _findOrCreateLobby();
    }
  }

  Future<void> _findOrCreateLobby() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError("You must be signed in to play ranked.");
      return;
    }
    setState(() {
      _isSearching = true;
      _statusMessage = "Scanning for worthy opponents...";
    });
    try {
      const eloRange = 150;
      final query = _firestore
          .collection('competitive_lobbies')
          .where('status', isEqualTo: 'waiting')
          .limit(20);
      final waitingLobbies = await query.get();
      final suitableLobbies =
          waitingLobbies.docs.where((doc) {
            try {
              final data = doc.data();
              final hostData = data['host'] as Map<String, dynamic>?;
              if (hostData == null || hostData['uid'] == user.uid) return false;
              final hostElo = hostData['elo'] ?? 1200;
              return hostElo >= (_playerElo - eloRange) &&
                  hostElo <= (_playerElo + eloRange);
            } catch (e) {
              return false;
            }
          }).toList();

      if (suitableLobbies.isNotEmpty) {
        final lobbyDoc = suitableLobbies.first;
        final hostData = lobbyDoc.data()['host'] as Map<String, dynamic>;
        if (!mounted) return;
        setState(() => _statusMessage = "Opponent found! Preparing battle...");
        final accepted = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => MatchFoundDialog(
                opponentName: hostData['gamertag'] ?? 'Player',
                opponentElo: hostData['elo'] ?? 1200,
                onAccept: () => Navigator.of(context).pop(true),
                onDecline: () => Navigator.of(context).pop(false),
              ),
        );
        if (accepted == true) {
          await _joinLobby(lobbyDoc, user);
        } else {
          await _cancelSearch();
        }
      } else {
        await _createNewLobby(user);
      }
    } catch (e) {
      if (mounted) {
        _showError("Matchmaking error. Please try again.");
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _createNewLobby(User user) async {
    if (!mounted) return;
    setState(
      () => _statusMessage = "No opponents found. Creating a new arena...",
    );
    final newLobbyRef = _firestore.collection('competitive_lobbies').doc();
    await newLobbyRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'waiting',
      'host': {'uid': user.uid, 'gamertag': _playerGamertag, 'elo': _playerElo},
      'guest': null,
      'gameState': {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'turn': 'w',
        'moves': [],
        'lastMove': null,
        'statusMessage': '',
      },
    });
    if (!mounted) return;
    setState(() => _statusMessage = "Arena ready. Awaiting a challenger...");
    _lobbySubscription = newLobbyRef.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        _cancelSearch(showMessage: true);
        return;
      }
      final data = snapshot.data();
      if (data != null && data['status'] == 'active') {
        _navigateToGame(snapshot.id, true);
      }
    });
  }

  Future<void> _joinLobby(DocumentSnapshot lobbyDoc, User user) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final freshLobbyDoc = await transaction.get(lobbyDoc.reference);
        if (!freshLobbyDoc.exists) throw Exception("Lobby no longer exists.");
        final data = freshLobbyDoc.data() as Map<String, dynamic>?;
        if (data == null) throw Exception("Lobby data is null.");
        if (data['status'] != 'waiting') {
          throw Exception("Lobby is no longer available.");
        }
        if (data['guest'] != null) throw Exception("Lobby is already full.");
        transaction.update(lobbyDoc.reference, {
          'guest': {
            'uid': user.uid,
            'gamertag': _playerGamertag,
            'elo': _playerElo,
          },
          'status': 'active',
        });
      });
      _navigateToGame(lobbyDoc.id, false);
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = "Lobby taken. Searching again...");
      }
      await Future.delayed(const Duration(seconds: 1));
      if (_isSearching && mounted) await _findOrCreateLobby();
    }
  }

  Future<void> _cancelSearch({bool showMessage = true}) async {
    await _lobbySubscription?.cancel();
    _lobbySubscription = null;
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final createdLobbies =
            await _firestore
                .collection('competitive_lobbies')
                .where('host.uid', isEqualTo: user.uid)
                .where('status', isEqualTo: 'waiting')
                .get();
        for (var doc in createdLobbies.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Error cancelling search: $e");
      }
    }
    if (mounted) {
      setState(() {
        _isSearching = false;
        if (showMessage) _statusMessage = "Search cancelled. Ready to fight!";
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE8425E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(children: [_buildAnimatedBackground(), _buildMainContent()]),
    );
  }

  Widget _buildAnimatedBackground() => AnimatedBuilder(
    animation: _glowController,
    builder:
        (context, child) => CustomPaint(
          painter: GradientGlowPainter(_glowController.value, [
            kPrimaryPurple,
            kSecondaryBlue,
            kAccentPink,
          ]),
          size: MediaQuery.of(context).size,
        ),
  );

  Widget _buildMainContent() => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      _buildSliverAppBar(),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 24),
            _AnimatedEntrance(delay: 1, child: _buildRankCard()),
            const SizedBox(height: 24),
            _AnimatedEntrance(delay: 2, child: _buildRankProgressCard()),
            const SizedBox(height: 24),
            _AnimatedEntrance(delay: 3, child: _buildFindMatchButton()),
            const SizedBox(height: 16),
            _AnimatedEntrance(delay: 3, child: _buildStatusText()),
            const SizedBox(height: 32),
            _AnimatedEntrance(
              delay: 4,
              child: _buildSectionHeader("Recent Battles", Icons.history),
            ),
            const SizedBox(height: 16),
            _AnimatedEntrance(delay: 5, child: _buildRecentMatches()),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    ],
  );

  Widget _buildSliverAppBar() => SliverAppBar(
    pinned: true,
    stretch: true,
    backgroundColor: kBgDark.withOpacity(0.85),
    elevation: 0,
    flexibleSpace: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(color: Colors.transparent),
      ),
    ),
    leading: _buildAppBarButton(
      icon: Icons.arrow_back_ios_new,
      onTap: () => Navigator.of(context).pop(),
    ),
    centerTitle: true,
    title: const Text(
      "RANKED ARENA",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: kTextPrimary,
      ),
    ),
    actions: [
      _buildAppBarButton(
        icon: Icons.emoji_events,
        onTap: _showRankCriteriaDialog,
      ),
      const SizedBox(width: 16),
    ],
  );

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) => Center(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kCardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kTextSecondary.withOpacity(0.2)),
        ),
        child: Icon(icon, color: kTextSecondary, size: 20),
      ),
    ),
  );

  void _showRankCriteriaDialog() {
    showDialog(
      context: context,
      builder:
          (context) => RankCriteriaDialog(
            currentRank: RankInfo.getRankFromElo(_playerElo),
            currentProgress: _rankProgressWins,
          ),
    );
  }

  Widget _buildRankCard() {
    final rankInfo = RankInfo.getRankFromElo(_playerElo);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kPrimaryPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryPurple.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [rankInfo.color, rankInfo.color.withOpacity(0.4)],
                  ),
                  border: Border.all(
                    color: rankInfo.color.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [BoxShadow(color: rankInfo.color, blurRadius: 20)],
                ),
                child: Icon(rankInfo.icon, size: 40, color: kBgDark),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _playerGamertag,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          rankInfo.name,
                          style: TextStyle(
                            color: rankInfo.color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          " • ",
                          style: TextStyle(color: kTextSecondary),
                        ),
                        Text(
                          "$_playerElo ELO",
                          style: const TextStyle(
                            color: kTextSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatPill("$_wins Wins", kWinColor, Icons.emoji_events),
              _buildStatPill("$_losses Losses", kLossColor, Icons.shield),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String text, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildRankProgressCard() {
    final currentRank = RankInfo.getRankFromElo(_playerElo);
    final nextRank = RankInfo.getNextRank(currentRank.name);

    if (nextRank == null) return const SizedBox.shrink();

    final winsNeeded = currentRank.winsRequired;
    final winsRemaining = (winsNeeded - _rankProgressWins).clamp(0, winsNeeded);
    final progress = (winsNeeded > 0) ? _rankProgressWins / winsNeeded : 0.0;

    return InkWell(
      onTap: _showRankCriteriaDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kTextSecondary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Rank Progress",
                  style: TextStyle(
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  "$_rankProgressWins / $winsNeeded",
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProgressBar(progress, [kPrimaryPurple, kSecondaryBlue]),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(nextRank.icon, color: nextRank.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$winsRemaining wins to ${nextRank.name}",
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Next: ${nextRank.eloMin} - ${nextRank.eloMax} ELO",
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: kTextSecondary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value, List<Color> colors) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 8,
      decoration: BoxDecoration(color: kTextSecondary.withOpacity(0.2)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colors.first,
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildFindMatchButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.98, end: 1.02).animate(_pulseController),
      child: GestureDetector(
        onTap: _toggleSearch,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors:
                  _isSearching
                      ? [kAccentPink, kAccentPink.withOpacity(0.7)]
                      : [kPrimaryPurple, kSecondaryBlue],
            ),
            boxShadow: [
              BoxShadow(
                color: (_isSearching ? kAccentPink : kPrimaryPurple)
                    .withOpacity(0.5),
                blurRadius: 25,
              ),
            ],
          ),
          child: Center(
            child:
                _isSearching
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "CANCELING...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          "FIND BATTLE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() => AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder:
        (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
    child: Text(
      _statusMessage,
      key: ValueKey(_statusMessage),
      style: const TextStyle(
        color: kTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    ),
  );

  Widget _buildSectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: kPrimaryPurple, size: 20),
      const SizedBox(width: 12),
      Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ],
  );

  Widget _buildRecentMatches() => Column(
    children: [
      _buildMatchTile("Magnus_Pro", "1h ago", "+21", true),
      _buildMatchTile("ChessQueen23", "3h ago", "-18", false),
      _buildMatchTile("TacticNinja", "8h ago", "+15", true),
    ],
  );

  Widget _buildMatchTile(
    String opponent,
    String time,
    String change,
    bool won,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: kCardColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kTextSecondary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          width: 6,
          height: 50,
          decoration: BoxDecoration(
            color: won ? kWinColor : kLossColor,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: won ? kWinColor : kLossColor, blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opponent,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(color: kTextSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          change,
          style: TextStyle(
            color: won ? kWinColor : kLossColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// =======================================================================
// ==                     HELPER WIDGETS & PAINTERS                     ==
// =======================================================================

class _AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedEntrance({required this.child, required this.delay});
  @override
  State<_AnimatedEntrance> createState() => __AnimatedEntranceState();
}

class __AnimatedEntranceState extends State<_AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.delay * 150), () {
      if (mounted) _controller.forward();
    });
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fadeAnimation,
    child: SlideTransition(position: _slideAnimation, child: widget.child),
  );
}

class GradientGlowPainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;
  GradientGlowPainter(this.animationValue, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.fill;
    final t = (math.sin(animationValue * math.pi * 2) + 1) / 2;

    paint.shader = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.0 + t * 0.5,
      colors: [colors[0].withOpacity(0.3), Colors.transparent],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = RadialGradient(
      center: Alignment.bottomRight,
      radius: 1.0 + (1 - t) * 0.5,
      colors: [colors[1].withOpacity(0.3), Colors.transparent],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = RadialGradient(
      center: Alignment(t * 2 - 1, (1 - t) * 2 - 1),
      radius: 0.8,
      colors: [colors[2].withOpacity(0.2), Colors.transparent],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TitaniumShimmerPainter extends CustomPainter {
  final double progress;
  TitaniumShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(progress * 2 * math.pi),
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.0),
            ],
            stops: const [0.4, 0.5, 0.6],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(TitaniumShimmerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
