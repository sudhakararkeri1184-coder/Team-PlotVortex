// lib/chess_screen/chess_CompetitiveMode/competitive_chess_board_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/chess_rank_screen.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/services/firebase_game_services.dart';
import 'package:v2/chess_screen/chess_MultiplayerMode/3DchessMode/services/multiplayer_chess_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ✅ CORRECTED: Import paths changed from plural 'services' to singular 'service'
// import 'package:v2/chess_screen/chess_CompetitiveMode/services/firebase_game_service.dart';
// import 'package:v2/chess_screen/chess_CompetitiveMode/services/multiplayer_chess_service.dart';

import 'package:v2/chess_screen/chess_CompetitiveMode/widgets/game_result_dialog.dart';

// --- GAMING UI THEME COLORS ---
const Color kBgDark = Color(0xFF0A0F2C);
const Color kCardColor = Color(0xFF1A1F3C);
const Color kPrimaryPurple = Color(0xFF7B61FF);
const Color kSecondaryBlue = Color(0xFF00D1FF);
const Color kAccentPink = Color(0xFFF72585);
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xFF8D99AE);
const Color kWinColor = Color(0xFF00FFAB);

class MultiplayerChessBoardScreen extends StatefulWidget {
  final String lobbyId;
  final bool isHost;

  const MultiplayerChessBoardScreen({
    super.key,
    required this.lobbyId,
    required this.isHost,
  });

  @override
  State<MultiplayerChessBoardScreen> createState() =>
      _MultiplayerChessBoardScreenState();
}

class _MultiplayerChessBoardScreenState
    extends State<MultiplayerChessBoardScreen>
    with TickerProviderStateMixin {
  // UI Animation Controllers
  late AnimationController _shimmerController;
  late AnimationController _glowController;

  final MultiplayerChessService _chessService = MultiplayerChessService();
  final FirebaseGameService _gameService = FirebaseGameService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _lobbySubscription;

  final Completer<void> _webViewReadyCompleter = Completer<void>();
  bool _isChessServiceInitialized = false;

  bool isLoading = true;
  bool isMyTurn = false;
  String opponentName = 'Opponent';
  int opponentElo = 1200;
  int myElo = 1200;
  String? drawOfferedBy;
  bool _isProcessing = false;

  List<String> moveHistory = [];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _glowController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _initializeGame();
  }

  @override
  void dispose() {
    _lobbySubscription?.cancel();
    _shimmerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  // --- CORE LOGIC METHODS ---

  void _initializeGame() {
    _chessService.initialize(onMessageReceived: _handleChessMessage);
    setState(() {
      _isChessServiceInitialized = true;
    });
    _listenToLobbyUpdates();
    _loadInitialGameState();
  }

  void _loadInitialGameState() async {
    try {
      final lobbyDoc =
          await _firestore
              .collection('competitive_lobbies')
              .doc(widget.lobbyId)
              .get();
      if (lobbyDoc.exists && mounted) {
        final data = lobbyDoc.data()!;
        final myUid = _auth.currentUser!.uid;
        final isHostPlayer = data['host']['uid'] == myUid;
        final opponent = isHostPlayer ? data['guest'] : data['host'];
        setState(() {
          opponentName = opponent['gamertag'] ?? 'Opponent';
          opponentElo = opponent['elo'] ?? 1200;
          myElo = isHostPlayer ? data['host']['elo'] : data['guest']['elo'];
          isMyTurn = widget.isHost;
        });
        if (!widget.isHost) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _chessService.rotateBoard();
          });
        }
      }
    } catch (e) {
      if (mounted) _showError("Failed to load game data.");
    }
  }

  void _listenToLobbyUpdates() {
    _lobbySubscription = _firestore
        .collection('competitive_lobbies')
        .doc(widget.lobbyId)
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists || !mounted) {
            if (mounted && Navigator.canPop(context)) {
              _showError("The game has ended or was disconnected.");
              Navigator.of(context).pop();
            }
            return;
          }

          final data = snapshot.data()!;
          if (data['status'] == 'completed') {
            _handleGameCompleted(data);
            return;
          }

          final gameState = data['gameState'] as Map<String, dynamic>;
          final newFen = gameState['fen'] as String;
          final newTurn = gameState['turn'] as String;
          final moves = List<String>.from(gameState['moves'] ?? []);

          await _webViewReadyCompleter.future;

          if (!mounted) return;

          _chessService.loadFen(newFen);

          setState(() {
            bool isWhiteTurn = newTurn == 'w';
            isMyTurn =
                (widget.isHost && isWhiteTurn) ||
                (!widget.isHost && !isWhiteTurn);
            drawOfferedBy = data['drawOffer'];
            moveHistory = moves;
          });

          if (isMyTurn) {
            _chessService.enableInput();
          } else {
            _chessService.disableInput();
          }
        });
  }

  void _handleChessMessage(String message) {
    final data = jsonDecode(message);
    switch (data['type']) {
      case 'loaded':
        if (!_webViewReadyCompleter.isCompleted) {
          _webViewReadyCompleter.complete();
        }
        if (mounted) {
          setState(() => isLoading = false);
        }
        break;
      case 'move':
        _handlePlayerMove(data);
        break;
      case 'checkmate':
        _handleCheckmate(data['winner']);
        break;
      case 'stalemate':
        _handleStalemate();
        break;
    }
  }

  void _handlePlayerMove(Map<String, dynamic> data) async {
    if (!isMyTurn || !mounted) return;
    final fen = data['fen'] as String;
    final notation = data['notation'] as String;
    final newTurn = fen.split(' ')[1];
    final updatedMoves = [...moveHistory, notation];
    try {
      await _gameService.updateGameState(
        lobbyId: widget.lobbyId,
        fen: fen,
        turn: newTurn,
        moves: updatedMoves,
        lastMove: notation,
      );
      if (mounted) setState(() => isMyTurn = false);
      _chessService.disableInput();
    } catch (e) {
      if (mounted) _showError('Failed to update move: $e');
    }
  }

  void _handleCheckmate(String winner) async {
    if (!mounted) return;
    final lobbyDoc =
        await _firestore
            .collection('competitive_lobbies')
            .doc(widget.lobbyId)
            .get();
    if (!lobbyDoc.exists) return;
    final data = lobbyDoc.data()!;
    final winnerId =
        winner == 'white' ? data['host']['uid'] : data['guest']['uid'];
    final loserId =
        winner == 'white' ? data['guest']['uid'] : data['host']['uid'];

    await _gameService.endGame(
      lobbyId: widget.lobbyId,
      winnerId: winnerId,
      loserId: loserId,
    );
  }

  void _handleStalemate() async {
    if (!mounted) return;
    final lobbyDoc =
        await _firestore
            .collection('competitive_lobbies')
            .doc(widget.lobbyId)
            .get();
    if (!lobbyDoc.exists) return;
    final data = lobbyDoc.data()!;

    await _gameService.endGame(
      lobbyId: widget.lobbyId,
      winnerId: data['host']['uid'],
      loserId: data['guest']['uid'],
      isDraw: true,
    );
  }

  void _handleGameCompleted(Map<String, dynamic> data) async {
    if (!mounted) return;
    final myUid = _auth.currentUser!.uid;
    final winner = data['winner'];
    String result =
        (winner == 'draw') ? 'draw' : (winner == myUid ? 'win' : 'loss');
    final userDoc = await _firestore.collection('users').doc(myUid).get();
    final newElo = userDoc.data()?['elo'] ?? myElo;
    final eloChange = newElo - myElo;
    if (mounted) _showGameResultDialog(result, eloChange, newElo);
  }

  void _showGameResultDialog(String result, int eloChange, int newElo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: GameResultDialog(
              result: result,
              eloChange: eloChange,
              newElo: newElo,
              opponentName: opponentName,
              onClose: () {
                if (mounted) {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // back to ranked screen
                }
              },
            ),
          ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kAccentPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showResignConfirmation() {
    if (_isProcessing) return;
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: kCardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: kAccentPink, width: 2),
            ),
            title: Row(
              children: const [
                Icon(Icons.flag, color: kAccentPink, size: 28),
                SizedBox(width: 12),
                Text(
                  'Resign Game?',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Are you sure? This will count as a loss and you will lose ELO.',
              style: TextStyle(color: kTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: kTextSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  if (mounted) setState(() => _isProcessing = true);
                  try {
                    await _gameService.resignGame(
                      widget.lobbyId,
                      _auth.currentUser!.uid,
                    );
                  } catch (e) {
                    if (mounted) _showError('Failed to resign: $e');
                  } finally {
                    if (mounted) setState(() => _isProcessing = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentPink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Resign',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _offerDraw() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _gameService.offerDraw(widget.lobbyId, _auth.currentUser!.uid);
      if (mounted) _showError('Draw offer sent.');
    } catch (e) {
      if (mounted) _showError('Failed to offer draw: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _respondToDrawOffer(bool accept) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      if (accept) {
        await _gameService.acceptDraw(widget.lobbyId);
      } else {
        await _gameService.declineDraw(widget.lobbyId);
      }
    } catch (e) {
      if (mounted) _showError('Failed to respond to draw: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showResignConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: kBgDark,
        body: Stack(
          children: [
            AnimatedBuilder(
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
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildPlayerInfo(opponentName, opponentElo, !isMyTurn),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              if (_isChessServiceInitialized)
                                WebViewWidget(
                                  controller: _chessService.controller,
                                )
                              else
                                Container(color: kBgDark),
                              if (isLoading) _buildLoadingOverlay(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildPlayerInfo('You', myElo, isMyTurn),
                  _buildActionBar(),
                  _buildMoveHistory(),
                ],
              ),
            ),
            if (drawOfferedBy != null &&
                drawOfferedBy != _auth.currentUser!.uid)
              _buildDrawOfferBanner(),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(color: kPrimaryPurple),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kTextSecondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.flag,
            label: "Resign",
            color: kAccentPink,
            onTap: _isProcessing ? null : _showResignConfirmation,
          ),
          _buildActionButton(
            icon: Icons.handshake,
            label: "Offer Draw",
            color: kSecondaryBlue,
            onTap:
                (drawOfferedBy == null && !_isProcessing) ? _offerDraw : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    bool isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String name, int elo, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? kWinColor : kTextSecondary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow:
            isActive
                ? [
                  BoxShadow(color: kWinColor, blurRadius: 20, spreadRadius: -8),
                ]
                : [],
      ),
      child: Stack(
        children: [
          if (isActive)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder:
                      (context, child) => CustomPaint(
                        painter: TitaniumShimmerPainter(
                          _shimmerController.value,
                        ),
                      ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kPrimaryPurple,
                  radius: 22,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$elo ELO',
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kWinColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "YOUR TURN",
                      style: TextStyle(
                        color: kWinColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
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

  Widget _buildLoadingOverlay() => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: kBgDark.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: kPrimaryPurple,
                strokeWidth: 5,
              ),
              const SizedBox(height: 24),
              const Text(
                'Syncing Battle Arena...',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildDrawOfferBanner() => Positioned.fill(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: kCardColor.withOpacity(0.9),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.handshake, color: kSecondaryBlue, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Draw Offered',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your opponent proposes a truce.',
                    style: TextStyle(color: kTextSecondary, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _respondToDrawOffer(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentPink,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _respondToDrawOffer(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kWinColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            color: kBgDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildMoveHistory() => Container(
    height: 50,
    margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: kCardColor.withOpacity(0.8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kTextSecondary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        const Icon(Icons.history, color: kTextSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child:
              moveHistory.isEmpty
                  ? const Text(
                    'The battle begins...',
                    style: TextStyle(
                      color: kTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: moveHistory.length,
                    itemBuilder: (context, index) {
                      final moveNumber =
                          (moveHistory.length - index) ~/ 2 +
                          ((moveHistory.length - index) % 2);
                      final isWhiteMove =
                          (moveHistory.length - index - 1) % 2 == 0;
                      final move = moveHistory[moveHistory.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'sans-serif',
                              color: kTextSecondary,
                              fontSize: 16,
                            ),
                            children: [
                              if (isWhiteMove) TextSpan(text: '$moveNumber. '),
                              TextSpan(
                                text: move,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    ),
  );
}

// ✅ REMOVED: Redundant painter classes as they are defined in chess_rank_screen.dart
