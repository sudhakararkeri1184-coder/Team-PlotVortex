import 'package:v2/chess_screen/chess_QuizMode/screens/quize_home_screen.dart';
import 'package:v2/chess_screen/chess_ChallengeMode/vsPerson/game_board.dart';
import 'package:flutter/material.dart';
// import 'package:v2/chess_screen/quize/screens/home_screen.dart';
// import 'package:v2/chess_screen/quize/screens/quize_home_screen.dart';

class QuizeCard extends StatelessWidget {
  const QuizeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Color(0xFF162343).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  'https://thumbs.dreamstime.com/b/dramatic-chess-game-artwork-dark-knight-pieces-board-epic-image-features-metallic-dimly-lit-perfect-strategy-websites-367174260.jpg',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Icon(Icons.people, color: Colors.blueAccent, size: 30),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlue),
                    color: Colors.lightBlue.withOpacity(.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '★ Social',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quize section',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonGameBoard(),
                      ),
                    );
                  }, // Add nav
                  child: Text(
                    'Take a Quiz',
                    style: TextStyle(
                      color: Color(0xFF8E9CFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Solve chess puzzles and improve your skills with our engaging quiz section.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _chip('Turn-based gameplay'),
                    _chip('Custom time '),
                  ],
                ),
                Row(
                  children: [_chip('Local multiplayer'), _chip('Move history')],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Color(0xFF191E39),
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(16),
                    //     ),
                    //     minimumSize: Size(100, 40),
                    //   ),
                    //   child: Text('Quiz Info'),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizeHomeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white12),
                          color: Color(0xFF191E39),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Quiz Info',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Spacer(),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const QuizeHomeScreen(),
                    //       ),
                    //     );
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Color(0xFF1AB6EF),
                    //     foregroundColor: Colors.white,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(16),
                    //     ),
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(right: 3),
                    //     child: Row(
                    //       children: [
                    //         Icon(Icons.play_arrow, size: 18),
                    //         SizedBox(width: 2),
                    //         Text('Start Game'),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuizeHomeScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan),
                          color: Color(0xFF1AB6EF).withOpacity(.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_arrow,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Start Game',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: 0.7,
              backgroundColor: Color(0xFF191E39),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF11B1F8)),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF222852).withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
