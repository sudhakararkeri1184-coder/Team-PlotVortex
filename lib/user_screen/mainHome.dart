// // lib/Homepage.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'package:flutter_animate/flutter_animate.dart';

// // Firebase Imports
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// // Screen Imports
// // import '../carrom_screen/carromHomeScreen.dart';
// // import '../chess_screen/chessHome.dart';
// // import '../pool_screen/pool_homepage.dart';
// // import '../uno_screens/uno_homepage.dart';
// // import 'enhanced_profile_screen.dart';
// import 'user-Profile_screen/profile.dart'; // Corrected Path

// // --- PREMIUM THEME CONSTANTS ---
// const Color kBgColor = Color(0xFF0D0F1C);
// const Color kCardColor = Color(0xFF1F2233);
// const Color _accentGreen = Color(0xFF10B981);
// const Color _accentPurple = Color(0xFF8B5CF6);
// const Color kAccentBlue = Color(0xFF4CC9F0);
// // Add this line with your other color constants

// const Color kAccentGold = Color(0xFFFFD60A);

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   late AnimationController _swipeController,
//       _breathingController,
//       _rotationController,
//       _backgroundController;
//   late Animation<Offset> _swipeAnimation;
//   late Animation<double> _breathingAnimation;

//   static const Duration _swipeDuration = Duration(milliseconds: 600);
//   static const Duration _autoSwipeInterval = Duration(seconds: 4);
//   static const double _swipeThreshold = 100.0, _velocityThreshold = 500.0;

//   int currentIndex = 0;
//   Offset _dragOffset = Offset.zero;
//   Timer? _autoSwipeTimer;
//   bool _isAutoSwiping = true;
//   String? _userName, _userAvatarUrl;
//   bool _isLoading = true;

//   // lib/Homepage.dart

//   // ... (inside the _HomepageState class)

//   // <<< THIS IS THE CORRECTED METHOD >>>
//   Widget _buildLiveStatsRow() {
//     final user = _auth.currentUser;
//     // If user is not logged in, show default stats
//     if (user == null) {
//       return _buildStatsRowFromData(level: 1, xp: 0, time: 0);
//     }

//     // Use StreamBuilder to listen for live data from Firestore
//     return StreamBuilder<DocumentSnapshot>(
//       stream: _firestore.collection('users').doc(user.uid).snapshots(),
//       builder: (context, snapshot) {
//         // Show a loading state while waiting for data
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return _buildStatsRowFromData(
//             level: 0,
//             xp: 0,
//             time: 0,
//             isLoading: true,
//           );
//         }

//         // If no data, show default state
//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return _buildStatsRowFromData(level: 1, xp: 0, time: 0);
//         }

//         // If data is available, parse it and build the UI
//         final data = snapshot.data!.data() as Map<String, dynamic>;
//         final int level = data['level'] as int? ?? 1;
//         final int xp = data['xp'] as int? ?? 0;
//         final int time = data['timePlayedInHours'] as int? ?? 0;

//         return _buildStatsRowFromData(level: level, xp: xp, time: time);
//       },
//     );
//   }

//   // <<< THIS UI HELPER WIDGET IS NOW CORRECTLY CALLED BY THE STREAMBUILDER >>>
//   Widget _buildStatsRowFromData({
//     required int level,
//     required int xp,
//     required int time,
//     bool isLoading = false,
//   }) {
//     // Inside _buildStatsRowFromData(...)

//     final statsData = [
//       {
//         'icon': Icons.shield_outlined,
//         'value': '$level',
//         'label': 'Level',
//         'color': _accentPurple,
//         'progress': (xp % 1000) / 1000,
//       },
//       {
//         'icon': Icons.star_border_rounded,
//         'value': '${(xp / 1000).toStringAsFixed(1)}K',
//         'label': 'XP',
//         'color': kAccentGold, // <<< THIS LINE WAS ADDED
//         'progress': (xp % 1000) / 1000,
//       },
//       {
//         'icon': Icons.timer_outlined,
//         'value': '${time}h',
//         'label': 'Played',
//         'color': kAccentBlue,
//         'progress': 0.4,
//       },
//     ];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Row(
//         children: List.generate(3, (index) {
//           final stat = statsData[index];
//           return Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 6.0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: BackdropFilter(
//                       filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                         ),
//                         child:
//                             isLoading
//                                 ? const Center(
//                                   child: SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white24,
//                                     ),
//                                   ),
//                                 )
//                                 : Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Icon(
//                                           stat['icon'] as IconData,
//                                           color: stat['color'] as Color,
//                                           size: 20,
//                                         ),
//                                         Text(
//                                           stat['label'] as String,
//                                           style: const TextStyle(
//                                             color: Colors.white70,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       stat['value'] as String,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     // The progress bar was missing in your original code, so I'm adding it back
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(10),
//                                       child: LinearProgressIndicator(
//                                         value: stat['progress'] as double,
//                                         backgroundColor: (stat['color']
//                                                 as Color)
//                                             .withOpacity(0.15),
//                                         color: stat['color'] as Color,
//                                         minHeight: 5,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//               .animate()
//               .fadeIn(delay: (600 + index * 100).ms, duration: 500.ms)
//               .slideY(begin: 0.5);
//         }),
//       ),
//     );
//   }

//   final List<Map<String, dynamic>> cardData = [
//     {
//       "image": "assets/chess.jpg",
//       "gameName": "Chess Master",
//       "description": "Strategic board game",
//       "rating": 4.7,
//       "users": 2.5,
//       "gradient": [const Color(0xFF8B5CF6), const Color(0xFF4F46E5)],
//       "nextAction": "chess",
//     },
//     {
//       "image": "assets/carrom.png",
//       "gameName": "Carrom Master",
//       "description": "Classic strike & pocket",
//       "rating": 4.5,
//       "users": 2.5,
//       "gradient": [const Color(0xFF10B981), const Color(0xFF059669)],
//       "nextAction": "carrom",
//     },
//     {
//       "image": "assets/pool.png",
//       "gameName": "Pool Master",
//       "description": "8-Ball pool challenge",
//       "rating": 4.2,
//       "users": 2.5,
//       "gradient": [const Color(0xFFEC4899), const Color(0xFFDB2777)],
//       "nextAction": "pool",
//     },
//     {
//       "image": "assets/unno.png",
//       "gameName": "UNO",
//       "description": "The classic card game",
//       "rating": 4.2,
//       "users": 2.5,
//       "gradient": [const Color(0xFFF59E0B), const Color(0xFFD97706)],
//       "nextAction": "uno",
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//     _swipeController = AnimationController(
//       vsync: this,
//       duration: _swipeDuration,
//     );
//     _breathingController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//     _rotationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 15),
//     )..repeat();
//     _backgroundController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 30),
//     )..repeat();
//     _breathingAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
//       CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
//     );
//     _startAutoSwipe();
//   }

//   Future<void> _fetchUserData() async {
//     final user = _auth.currentUser;
//     if (user == null) {
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }
//     try {
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       if (doc.exists && mounted) {
//         final data = doc.data() as Map<String, dynamic>;
//         setState(() {
//           _userName = data['gamertag'] as String?;
//           _userAvatarUrl = data['photoUrl'] as String?;
//           _isLoading = false;
//         });
//       } else {
//         if (mounted) setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (mounted) setState(() => _isLoading = false);
//       debugPrint("Error fetching user data for app bar: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _swipeController.dispose();
//     _breathingController.dispose();
//     _rotationController.dispose();
//     _backgroundController.dispose();
//     _autoSwipeTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBgColor,
//       body: Stack(
//         children: [_buildAnimatedBackground(), SafeArea(child: _buildBody())],
//       ),
//     );
//   }

//   Widget _buildAnimatedBackground() {
//     return AnimatedBuilder(
//       animation: _backgroundController,
//       builder:
//           (context, child) => Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 transform: GradientRotation(
//                   _backgroundController.value * math.pi * 2,
//                 ),
//                 colors: [
//                   kBgColor,
//                   _accentPurple.withOpacity(0.1),
//                   kAccentBlue.withOpacity(0.1),
//                   kBgColor,
//                 ],
//                 stops: const [0.0, 0.3, 0.7, 1.0],
//               ),
//             ),
//           ),
//     );
//   }

//   Widget _buildBody() {
//     return Column(
//       children: [
//         _buildPremiumAppBar(),
//         _buildAnimatedGamepad(),
//         const SizedBox(height: 20),
//         _buildLiveStatsRow(),
//         const SizedBox(height: 10),
//         Expanded(
//           child:
//               cardData.isEmpty
//                   ? const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   )
//                   : Stack(
//                     alignment: Alignment.center,
//                     clipBehavior: Clip.none,
//                     children:
//                         List.generate(math.min(3, cardData.length), (i) {
//                           final index = (currentIndex + i) % cardData.length;
//                           if (i == 0) {
//                             return AnimatedBuilder(
//                               animation: Listenable.merge([
//                                 _swipeController,
//                                 _breathingController,
//                               ]),
//                               builder: (context, child) {
//                                 final offset =
//                                     _swipeController.isAnimating
//                                         ? _swipeAnimation.value
//                                         : _dragOffset;
//                                 final rotation = (offset.dx / 500).clamp(
//                                   -0.3,
//                                   0.3,
//                                 );
//                                 return Transform(
//                                   transform:
//                                       Matrix4.identity()
//                                         ..translate(offset.dx, offset.dy)
//                                         ..rotateZ(rotation),
//                                   alignment: Alignment.center,
//                                   child: Transform.scale(
//                                     scale: _breathingAnimation.value,
//                                     child: GestureDetector(
//                                       onTap: () => _onCardTap(index),
//                                       onPanUpdate: _onPanUpdate,
//                                       onPanEnd: _onPanEnd,
//                                       child: _buildGameCard(index, isTop: true),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           } else {
//                             return Transform.translate(
//                               offset: Offset(0, i * 15.0),
//                               child: Transform.scale(
//                                 scale: 1.0 - (i * 0.06),
//                                 child: Opacity(
//                                   opacity: 1.0 - (i * 0.3),
//                                   child: _buildGameCard(index, isTop: false),
//                                 ),
//                               ),
//                             );
//                           }
//                         }).reversed.toList(),
//                   ),
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }

//   // <<< NEW PREMIUM APP BAR >>>
//   Widget _buildPremiumAppBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const EnhancedProfileScreen(),
//                   ),
//                 ),
//             child: Container(
//               width: 52,
//               height: 52,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: const LinearGradient(
//                   colors: [kAccentBlue, _accentGreen],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: kAccentBlue.withOpacity(0.5),
//                     blurRadius: 12,
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(2),
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: kCardColor,
//                 ),
//                 padding: const EdgeInsets.all(2),
//                 child: ClipOval(
//                   child:
//                       _isLoading
//                           ? const Padding(
//                             padding: EdgeInsets.all(14.0),
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                           : (_userAvatarUrl != null &&
//                                   _userAvatarUrl!.isNotEmpty
//                               ? Image.network(
//                                 _userAvatarUrl!,
//                                 fit: BoxFit.cover,
//                                 errorBuilder:
//                                     (_, __, ___) => const Icon(
//                                       Icons.person,
//                                       color: Colors.white60,
//                                     ),
//                               )
//                               : const Icon(
//                                 Icons.person,
//                                 color: Colors.white60,
//                               )),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // const Text(
//               //   "Welcome Back",
//               //   style: TextStyle(color: Colors.white70, fontSize: 13),
//               // ),
//               Text(
//                 _userName ?? 'Player',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 25,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           // _appBarButton(Icons.search, () {}),
//           const SizedBox(width: 8),
//           // _appBarButton(Icons.notifications_outlined, () {}),
//         ],
//       ),
//     ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.5);
//   }

//   Widget _appBarButton(IconData icon, VoidCallback onPressed) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: kCardColor.withOpacity(0.6),
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Icon(icon, color: Colors.white, size: 24),
//       ),
//     );
//   }

//   // <<< NEW ENHANCED STATS ROW >>>

//   // --- All original widgets and logic are preserved below this line ---

//   String _formatNumber(int number) {
//     if (number < 1000) return number.toString();
//     return '${(number / 1000.0).toStringAsFixed(1)}K';
//   }

//   void _startAutoSwipe() {
//     if (!_isAutoSwiping || cardData.isEmpty) return;
//     _autoSwipeTimer?.cancel();
//     _autoSwipeTimer = Timer(_autoSwipeInterval, _performAutoSwipe);
//   }

//   void _performAutoSwipe() {
//     if (!mounted) return;
//     final screenWidth = MediaQuery.of(context).size.width;
//     _swipeAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: Offset(screenWidth * 1.5, 0),
//     ).animate(
//       CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut),
//     );
//     _swipeController.forward().whenComplete(() {
//       _nextCard();
//       _swipeController.reset();
//     });
//   }

//   void _nextCard() {
//     HapticFeedback.mediumImpact();
//     setState(() {
//       _dragOffset = Offset.zero;
//       currentIndex = (currentIndex + 1) % cardData.length;
//     });
//     _isAutoSwiping = true;
//     _startAutoSwipe();
//   }

//   void _pauseAutoSwipe() {
//     _isAutoSwiping = false;
//     _autoSwipeTimer?.cancel();
//     _breathingController.stop();
//   }

//   void _resumeAutoSwipe() {
//     if (mounted) {
//       _isAutoSwiping = true;
//       _startAutoSwipe();
//       _breathingController.repeat(reverse: true);
//     }
//   }

//   void _onPanUpdate(DragUpdateDetails details) {
//     _pauseAutoSwipe();
//     setState(() => _dragOffset += details.delta);
//   }

//   void _onPanEnd(DragEndDetails details) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     if (_dragOffset.dx.abs() > _swipeThreshold ||
//         details.velocity.pixelsPerSecond.dx.abs() > _velocityThreshold) {
//       final endOffset = Offset(
//         _dragOffset.dx > 0 ? screenWidth * 1.5 : -screenWidth * 1.5,
//         _dragOffset.dy,
//       );
//       _swipeAnimation = Tween<Offset>(
//         begin: _dragOffset,
//         end: endOffset,
//       ).animate(
//         CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut),
//       );
//       _swipeController.forward().whenComplete(() {
//         _nextCard();
//         _swipeController.reset();
//         _resumeAutoSwipe();
//       });
//     } else {
//       _swipeAnimation = Tween<Offset>(
//         begin: _dragOffset,
//         end: Offset.zero,
//       ).animate(
//         CurvedAnimation(parent: _swipeController, curve: Curves.elasticOut),
//       );
//       _swipeController.forward().whenComplete(() {
//         setState(() => _dragOffset = Offset.zero);
//         _swipeController.reset();
//         _resumeAutoSwipe();
//       });
//     }
//   }

//   // void _onCardTap(int index) {
//   //   _pauseAutoSwipe();
//   //   HapticFeedback.lightImpact();
//   //   final action = cardData[index]['nextAction'];
//   //   switch (action) {
//   //     case "chess":
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => const ChessHomePage()),
//   //       );
//   //       break;
//   //     case "carrom":
//   //       Navigator.push(
//   //         context
//   //       //  MaterialPageRoute(builder: (context) => const Carromhomescreen()),
//   //       );
//   //       break;
//   //     case "pool":
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => const poolHome()),
//   //       );
//   //       break;
//   //     case "uno":
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (context) => const UnoHomepage()),
//   //       );
//   //       break;
//   //   }
//   //   Future.delayed(const Duration(seconds: 3), _resumeAutoSwipe);
//   // }

//   Widget _buildAnimatedGamepad() {
//     return Column(
//       children: [
//         const SizedBox(height: 10),
//         RotationTransition(
//           turns: _rotationController,
//           child: Container(
//             height: 80,
//             width: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const LinearGradient(
//                 colors: [_accentPurple, Color(0xFFEC4899)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 transform: GradientRotation(math.pi / 4),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: _accentPurple.withOpacity(0.5),
//                   blurRadius: 20,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.gamepad_outlined,
//               color: Colors.white,
//               size: 40,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           "Welcome Back, Champion!",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           "Ready for your next adventure?",
//           style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
//         ),
//       ],
//     ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
//   }

//   Widget _buildGameCard(int index, {required bool isTop}) {
//     final data = cardData[index];
//     final gradientColors = data['gradient'] as List<Color>;

//     return Container(
//       height: 420,
//       width: 320,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(
//           color:
//               isTop ? gradientColors[0].withOpacity(0.5) : Colors.transparent,
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 isTop
//                     ? gradientColors[0].withOpacity(0.35)
//                     : Colors.black.withOpacity(0.4),
//             blurRadius: 30,
//             spreadRadius: 1,
//             offset: Offset(0, isTop ? 10 : 4),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(30),
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: Image.asset(data['image'], fit: BoxFit.cover),
//             ),
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: RadialGradient(
//                     center: Alignment.bottomLeft,
//                     radius: 1.2,
//                     colors: [
//                       gradientColors[0].withOpacity(0.3),
//                       Colors.transparent,
//                     ],
//                     stops: const [0.0, 0.8],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.4),
//                       Colors.black.withOpacity(0.9),
//                     ],
//                     stops: const [0.0, 0.5, 1.0],
//                   ),
//                 ),
//               ),
//             ),
//             Positioned.fill(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         _buildStatBadge(
//                           "${_formatNumber((data['users'] * 1000).toInt())}",
//                           Icons.people_rounded,
//                           _accentGreen,
//                         ),
//                         _buildStatBadge(
//                           "${data['rating']}",
//                           Icons.star_rounded,
//                           const Color(0xFFF59E0B),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     Text(
//                       data['gameName'],
//                       style: const TextStyle(
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         letterSpacing: 0.5,
//                         shadows: [
//                           Shadow(
//                             color: Colors.black54,
//                             blurRadius: 10,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       data['description'],
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Color(0xFF9CA3AF),
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatBadge(String value, IconData icon, Color color) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: kCardColor.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: color.withOpacity(0.5), width: 1),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 18, color: color),
//               const SizedBox(width: 6),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _onCardTap(int index) {}
// }

// class EnhancedProfileScreen {
//   const EnhancedProfileScreen();
// }

// class BlobPainter extends CustomPainter {
//   final double animation;
//   final double scrollOffset;
//   BlobPainter({required this.animation, required this.scrollOffset});
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
//     void drawBlob(
//       Color color,
//       Offset position,
//       double baseRadius,
//       double blurRadius,
//     ) {
//       paint.color = color.withOpacity(0.3);
//       paint.maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius);
//       final path = Path();
//       const points = 8;
//       for (int i = 0; i < points; i++) {
//         final angle = (i / points) * 2 * math.pi;
//         final animatedRadius =
//             baseRadius +
//             20 * math.sin(animation * 2 * math.pi + i) +
//             10 * math.cos(animation * 3 * math.pi + i * 0.5);
//         final x = position.dx + animatedRadius * math.cos(angle);
//         final y =
//             position.dy + animatedRadius * math.sin(angle) - scrollOffset * 0.3;
//         if (i == 0) {
//           path.moveTo(x, y);
//         } else {
//           final prevAngle = ((i - 1) / points) * 2 * math.pi;
//           final prevRadius =
//               baseRadius +
//               20 * math.sin(animation * 2 * math.pi + (i - 1)) +
//               10 * math.cos(animation * 3 * math.pi + (i - 1) * 0.5);
//           final prevX = position.dx + prevRadius * math.cos(prevAngle);
//           final prevY =
//               position.dy +
//               prevRadius * math.sin(prevAngle) -
//               scrollOffset * 0.3;
//           final cpX = (prevX + x) / 2;
//           final cpY = (prevY + y) / 2;
//           path.quadraticBezierTo(cpX, cpY, x, y);
//         }
//       }
//       path.close();
//       canvas.drawPath(path, paint);
//     }

//     final w = size.width;
//     final h = size.height;
//     final t = animation;
//     drawBlob(
//       const Color(0xFF6F49FF),
//       Offset(w * (0.2 + 0.02 * math.sin(t * math.pi * 2)), h * 0.15),
//       140,
//       24,
//     );
//     drawBlob(
//       const Color(0xFF00C2FF),
//       Offset(w * 0.85, h * (0.25 + 0.02 * math.cos(t * math.pi * 2))),
//       120,
//       22,
//     );
//     drawBlob(
//       const Color(0xFF22D38A),
//       Offset(w * 0.2, h * (0.7 + 0.03 * math.sin(t * math.pi))),
//       160,
//       26,
//     );
//     drawBlob(
//       const Color(0xFFFF9A32),
//       Offset(w * (0.7 + 0.03 * math.cos(t * math.pi)), h * 0.9),
//       130,
//       20,
//     );
//   }

//   @override
//   bool shouldRepaint(BlobPainter oldDelegate) => true;
// }
