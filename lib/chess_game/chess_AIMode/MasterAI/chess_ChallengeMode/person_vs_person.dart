import 'package:flutter/material.dart';
import 'package:v2/chess_screen/chess_ChallengeMode/vsPerson/game_board.dart';

class PersonVsPerson extends StatelessWidget {
  const PersonVsPerson({super.key});

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
                  "https://img.freepik.com/premium-photo/black-chess-pieces-chessboard-purple-lighting-pieces-are-arranged-row-with-king-center_14117-314015.jpg?semt=ais_hybrid&w=740&q=80",
                ),
                // child: (
                //   'assets/generated-image.png',
                //   height: 140,
                //   width: double.infinity,
                //   fit: BoxFit.cover,
                // ),
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
                    border: Border.all(color: Colors.yellow, width: 1),
                    color: Colors.yellow.withOpacity(.5),
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
                  'Person vs Person',
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
                    'Play with Friends',
                    style: TextStyle(
                      color: Color(0xFF8E9CFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Challenge your friend to a classic chess match. Perfect for local multiplayer gaming.',
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
                    //   child: Text('Human vs Human'),
                    // ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonGameBoard(),
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
                            Icon(Icons.person, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Human vs Human',
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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const PersonGameBoard(),
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
                            builder: (context) => const PersonGameBoard(),
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
                              size: 18,
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
