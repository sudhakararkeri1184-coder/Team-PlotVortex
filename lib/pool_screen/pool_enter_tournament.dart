import 'package:flutter/material.dart';
// import 'package:poolgameui/add_card.dart';
// import 'package:poolgameui/join_tournament.dart';

import 'dart:math' as math;

import 'package:v2/pool_screen/model/pool_tournament_model.dart';
import 'package:v2/pool_screen/pool_add_card.dart';
import 'package:v2/pool_screen/pool_join_tournament.dart';
// import 'package:poolgameui/model/tournament_model.dart';

class Tournament extends StatefulWidget {
  const Tournament({super.key});

  @override
  State<Tournament> createState() => TournamentState();
}

class TournamentState extends State<Tournament>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<TournamentModel> userTournaments = [];

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
            // Main content and button
            SafeArea(
              child: Stack(
                children: [
                  // Scrollable list of tournament cards
                  Padding(
                    padding: const EdgeInsets.only(bottom: 84),
                    child: ListView(
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
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Tournaments',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 23,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (userTournaments.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.greenAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'My Tournaments',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...userTournaments.map(
                            (tournament) => _tournamentCard(
                              color: Color(0xFF1E8E3E),
                              icon: Icons.emoji_events,
                              title: tournament.title,
                              mode: tournament.category,
                              badges: [
                                _badge(
                                  tournament.isPaid
                                      ? 'Paid Entry'
                                      : 'Free Entry',
                                  tournament.isPaid
                                      ? Color(0xFFFF8F24)
                                      : Color(0xFF08E47E),
                                ),
                                _badge('Created', Color(0xFF66FFCD)),
                              ],
                              prize: tournament.isPaid ? '\$10,000' : 'Free',
                              players: '0',
                              start: 'Not started',
                              actionLabel: 'Manage Tournament',
                              isCreate: true,
                              tournamentId: tournament.tournamentId,
                            ),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  color: Colors.blueAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Public Tournaments',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        _tournamentCard(
                          color: Color(0xFF9C5109),
                          icon: Icons.emoji_events,
                          title: 'Grand Master Championship',
                          mode: 'Classical',
                          badges: [
                            _badge('Master', Color(0xFFFF3260)),
                            _badge('Open', Color(0xFF08E47E)),
                          ],
                          prize: '\$50,000',
                          players: '2,847',
                          start: '2h 45m',
                          actionLabel: 'Join Tournament',
                          isCreate: false,
                        ),
                        _tournamentCard(
                          color: Color(0xFF533FED),
                          icon: Icons.flash_on,
                          title: 'Lightning Blitz Arena',
                          mode: 'Blitz',
                          badges: [
                            _badge('Expert', Color(0xFFFF8F24)),
                            _badge('Starting Soon', Color(0xFFFFE660)),
                          ],
                          prize: '\$15,000',
                          players: '1,523',
                          start: '1h 20m',
                          actionLabel: 'Join Tournament',
                          isCreate: false,
                        ),
                        _tournamentCard(
                          color: Color(0xFF09AE6D),
                          icon: Icons.star,
                          title: 'Rookie Rising Stars',
                          mode: 'Rapid',
                          badges: [
                            _badge('Beginner', Color(0xFF66FFCD)),
                            _badge('Open', Color(0xFF08E47E)),
                          ],
                          prize: '\$5,000',
                          players: '2,000',
                          start: '4h 15m',
                          actionLabel: 'Join Tournament',
                          isCreate: false,
                        ),
                        SizedBox(height: 9),
                        _tournamentCard(
                          color: Color(0xFFD11251),
                          icon: Icons.adjust,
                          title: 'Speed Demon Bullet',
                          mode: 'Bullet',
                          badges: [
                            _badge('Intermediate', Color(0xFFFFE660)),
                            _badge('Live', Color(0xFFFF3279)),
                          ],
                          prize: '\$8,500',
                          players: '987',
                          start: '45m',
                          actionLabel: 'Join Tournament',
                          isCreate: false,
                        ),
                        _tournamentCard(
                          color: Color(0xFF256EFF),
                          icon: Icons.sports,
                          title: 'Weekend Warriors Cup',
                          mode: 'Rapid',
                          badges: [
                            _badge('Intermediate', Color(0xFFFFF660)),
                            _badge('Open', Color(0xFF08E47E)),
                          ],
                          prize: '\$12,000',
                          players: '2,156',
                          start: '6h 30m',
                          actionLabel: 'Join Tournament',
                          isCreate: false,
                        ),
                        _tournamentCard(
                          color: Color(0xFF952AFE),
                          icon: Icons.verified_outlined,
                          title: 'Elite Masters Series',
                          mode: 'Classical',
                          badges: [
                            _badge('Master', Color(0xFFFF3260)),
                            _badge('Starting Soon', Color(0xFFFFE660)),
                          ],
                          prize: '\$75,000',
                          players: '456',
                          start: '12h 45m',
                          actionLabel: 'Join Tournament',
                          isCreate: false,
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // Bottom center add card button
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 19,
                        horizontal: 34,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.add, color: Colors.white, size: 24),
                          label: Text(
                            "Add Tournament",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB85FF2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.of(
                              context,
                            ).push<TournamentModel>(
                              MaterialPageRoute(
                                builder: (context) => Addcard(),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                userTournaments.insert(0, result);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tournament "${result.title}" created successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
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
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 7),
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _tournamentCard({
    required Color color,
    required IconData icon,
    required String title,
    required String mode,
    required List<Widget> badges,
    required String prize,
    required String players,
    required String start,
    required String actionLabel,
    required bool isCreate,
    String? tournamentId,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: color,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.95), color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.17),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: EdgeInsets.all(11),
                  child: Icon(icon, color: Colors.white, size: 23),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(children: badges),
            if (tournamentId != null) ...[
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.tag, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'ID: $tournamentId',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Prize',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  prize,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.people, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Players',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  players,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 11),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors:
                      isCreate
                          ? [Color(0xFF792CF8), Colors.white.withOpacity(0.18)]
                          : [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.13),
                          ],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return JoinTournament();
                      },
                    ),
                  );
                },
                icon:
                    isCreate
                        ? Icon(Icons.settings, color: Colors.white)
                        : Icon(Icons.emoji_events, color: Colors.white),
                label: Text(
                  actionLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated blob painter
class BlobPainter extends CustomPainter {
  final double animationValue;

  BlobPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animationValue;
    final double w = size.width;
    final double h = size.height;

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
