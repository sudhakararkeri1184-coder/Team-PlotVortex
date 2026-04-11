import 'package:flutter/material.dart';
import 'package:v2/pool_screen/pool_homepage.dart';

class Multiplayer extends StatefulWidget {
  const Multiplayer({super.key});

  @override
  State<Multiplayer> createState() => _MultiplayerState();
}

class _MultiplayerState extends State<Multiplayer> {
  // Gradient colors as requested
  final List<Color> bgColors = [
    Color(0xFF0E1647), // deep blue
    Color(0xFF3A298F), // purple blue
    Color(0xFF00A3FF), // cyan accent
    Color(0xFF1A2336), // navy
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pool Multiplayer Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return poolHome();
                              },
                            ),
                          );
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pool Multiplayer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Challenge players worldwide',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // Active Tables Widget
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF15256B).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(0xFF00A3FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Live - 892 pool tables active',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.language, color: Colors.white, size: 19),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Create Lobby Card
                  _LobbyCard(
                    icon: Icons.add,
                    title: "Create Lobby",
                    subtitle:
                        "Set up your own pool room and invite friends for epic 8-ball battles",
                    playersText: "Host + Friends",
                    modeText: "Custom Table",
                    features: [
                      "Set table rules",
                      "Friend invites",
                      "Private rooms",
                      "Voice chat",
                    ],
                    buttonLabel: "Create Lobby",
                    buttonColor: Color(0xFF009B8C),
                  ),
                  SizedBox(height: 30),

                  // Join Lobby Card
                  _LobbyCard(
                    icon: Icons.group,
                    title: "Join Lobby",
                    subtitle:
                        "Browse live pool games or enter room codes to join exciting matches",
                    playersText: "Join Matches",
                    modeText: "Quick Join",
                    features: [
                      "Live lobbies",
                      "Skill matching",
                      "Room codes",
                      "Global tables",
                    ],
                    buttonLabel: "Join Lobby",
                    buttonColor: Color(0xFF8866FA),
                  ),
                  SizedBox(height: 38),

                  // Call To Action
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF16205A),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 30,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.crop, color: Color(0xFF00A3FF), size: 22),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              "Master the table, rule the world",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
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
        ),
      ),
    );
  }
}

// Custom Card Widget
class _LobbyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String playersText;
  final String modeText;
  final List<String> features;
  final String buttonLabel;
  final Color buttonColor;

  const _LobbyCard({
    // ignore: unused_element_parameter
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.playersText,
    required this.modeText,
    required this.features,
    required this.buttonLabel,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF181E46).withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title Row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                width: 55,
                height: 55,
                child: Icon(icon, color: buttonColor, size: 33),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 27),
            ],
          ),
          SizedBox(height: 10),
          Text(subtitle, style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 20),
          Row(
            children: [
              _CardInfoBox(text: playersText),
              SizedBox(width: 15),
              _CardInfoBox(text: modeText),
            ],
          ),
          SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 5,
            children: features
                .map(
                  (f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: buttonColor, size: 9),
                      SizedBox(width: 6),
                      Text(
                        f,
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(icon, color: Colors.white, size: 22),
              label: Text(
                buttonLabel,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInfoBox extends StatelessWidget {
  final String text;
  const _CardInfoBox({required this.text});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF202855),
          borderRadius: BorderRadius.circular(13),
        ),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
