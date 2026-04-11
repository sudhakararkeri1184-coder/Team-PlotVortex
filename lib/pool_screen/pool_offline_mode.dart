import 'package:flutter/material.dart';

// Custom gradient background for 3D effect
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class OfflineMode extends StatefulWidget {
  const OfflineMode({super.key});

  @override
  State<OfflineMode> createState() => _OfflineModeState();
}

class _OfflineModeState extends State<OfflineMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomAppBar(),
                  SizedBox(height: 20),
                  // Section 1: Person vs Computer Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color.fromARGB(
                        196,
                        11,
                        2,
                        2,
                      ).withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 36, 35, 45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: 48,
                              width: 48,
                              child: Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),

                            Text(
                              'Person vs Computer',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            // Spacer(),
                            // Icon(Icons.star_border, color: Colors.white70),
                            // SizedBox(width: 8),
                            // Icon(Icons.verified, color: Colors.white70),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Test your skills against intelligent AI with adjustable difficulty',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            _infoCard('Players:', '1 vs AI'),
                            SizedBox(width: 16),
                            _infoCard('Mode:', 'Smart\nOpponent'),
                          ],
                        ),
                        SizedBox(height: 18),
                        _featureList([
                          'Adaptive AI',
                          '5 Difficulty levels',
                          'Skill improvement',
                        ]),
                        SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Add functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF6B5AED),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flash_on, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Start AI Challenge',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28),

                  // Section 2: Person vs Person Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white.withOpacity(0.04),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF17C3B2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              height: 48,
                              width: 48,
                              child: Icon(
                                Icons.group,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              'Person vs Person',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Play classic 8-ball pool with your friend on the same device',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                        SizedBox(height: 18),
                        Row(
                          children: [
                            _infoCard('Players:', '2 Players'),
                            SizedBox(width: 16),
                            _infoCard('Mode:', 'Pass & Play'),
                          ],
                        ),
                        SizedBox(height: 18),
                        _featureList([
                          'Turn-based gameplay',
                          'Score tracking',
                          'Classic 8-ball rules',
                        ]),
                        SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Add functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF17C3B2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Start Game',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28),

                  // Bottom selector
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            color: Color(0xFF00A3FF),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Choose your preferred offline experience',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
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

  Widget _infoCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white54, fontSize: 13)),
          SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Text(
              "offline mode",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Trophy icon
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
          //     ),
          //     borderRadius: BorderRadius.circular(12),
          //     boxShadow: [
          //       BoxShadow(
          //         color: const Color(0xFFFFD700).withOpacity(0.5),
          //         blurRadius: 12,
          //         offset: const Offset(0, 4),
          //       ),
          //     ],
          //   ),
          //   child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
          // ),
        ],
      ),
    );
  }
}

Widget _featureList(List<String> features) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:
        features
            .map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: Colors.white54),
                    SizedBox(width: 9),
                    Text(
                      f,
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
  );
}
