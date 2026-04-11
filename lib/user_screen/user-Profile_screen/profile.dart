// // lib/user_screen/enhanced_profile_screen.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'dart:ui' as ui;
// import 'dart:math' as math;

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';
// import 'package:v2/main.dart';
// import 'package:v2/Authentication/user_auth_screen.dart';
// import 'package:v2/user_screen/aboutus.dart';
// // import 'package:v2/login_screen.dart'; // Assuming you have login_screen.dart from previous steps
// // import 'package:v2/about_us_screen.dart'; // Import the About Us screen

// // ==================== DARK THEME COLORS ====================
// class DarkThemeColors {
//   static const Color primaryBackground = Color(0xFF0A0E21);
//   static const Color secondaryBackground = Color(0xFF1A1A2E);
//   static const Color cardBackground = Color(0xFF16213E);
//   static const Color accentPurple = Color(0xFF9D4EDD);
//   static const Color accentBlue = Color(0xFF4CC9F0);
//   static const Color accentPink = Color(0xFFFF006E);
//   static const Color accentGold = Color(0xFFFFD60A);
//   static const Color accentGreen = Color(0xFF06FFA5);

//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [accentPurple, accentBlue],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   static const LinearGradient secondaryGradient = LinearGradient(
//     colors: [accentPink, accentPurple],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//   static const LinearGradient goldGradient = LinearGradient(
//     colors: [Color(0xFFFFD60A), Color(0xFFFFA500)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }

// // ==================== PROFILE DATA MODEL ====================
// class ProfileData {
//   final String uid, gamertag, rank, country, photoUrl;

//   final int elo,
//       gamesPlayed,
//       wins,
//       losses,
//       draws,
//       tournamentsCreated,
//       tournamentsJoined;
//   final double winPercentage;

//   ProfileData({
//     required this.uid,
//     required this.gamertag,
//     required this.rank,
//     required this.country,
//     required this.photoUrl,
//     required this.elo,
//     required this.gamesPlayed,
//     required this.winPercentage,
//     required this.wins,
//     required this.losses,
//     required this.draws,
//     required this.tournamentsCreated,
//     required this.tournamentsJoined,
//   });

//   factory ProfileData.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> doc,
//   ) {
//     final data = doc.data() ?? {};
//     final int wins = data['wins'] ?? 0;
//     final int losses = data['losses'] ?? 0;
//     final int draws = data['draws'] ?? 0;
//     final int gamesPlayed = wins + losses + draws;
//     final double winPercentage =
//         gamesPlayed > 0 ? (wins / gamesPlayed) * 100 : 0.0;

//     return ProfileData(
//       uid: doc.id,
//       gamertag: data['gamertag'] ?? 'New Player',
//       photoUrl: data['photoUrl'] ?? '',
//       rank: data['rank'] ?? 'Beginner',
//       country: data['country'] ?? 'Global',
//       elo: data['elo'] ?? 1200,
//       gamesPlayed: gamesPlayed,
//       winPercentage: double.parse(winPercentage.toStringAsFixed(1)),
//       wins: wins,
//       losses: losses,
//       draws: draws,
//       tournamentsCreated: data['tournamentsCreated'] ?? 0,
//       tournamentsJoined: data['tournamentsJoined'] ?? 0,
//     );
//   }
// }

// // ==================== MATCH HISTORY MODEL ====================
// class MatchHistoryItem {
//   final String matchId,
//       opponentName,
//       opponentAvatarUrl,
//       opponentUid,
//       result,
//       gameMode;
//   final int eloChange;
//   final DateTime timestamp;

//   MatchHistoryItem({
//     required this.matchId,
//     required this.opponentName,
//     required this.opponentAvatarUrl,
//     required this.opponentUid,
//     required this.result,
//     required this.gameMode,
//     required this.eloChange,
//     required this.timestamp,
//   });

//   factory MatchHistoryItem.fromFirestore(
//     Map<String, dynamic> data,
//     String currentUserId,
//   ) {
//     String opponentName = '',
//         opponentAvatar = '',
//         opponentUid = '',
//         result = '';
//     int eloChange = 0;
//     try {
//       if (data['player1Id'] == currentUserId) {
//         opponentName = data['player2Name'] ?? 'Unknown';
//         opponentAvatar = data['player2Avatar'] ?? '';
//         opponentUid = data['player2Id'] ?? '';
//         if (data['winnerId'] == currentUserId) {
//           result = 'win';
//           eloChange = data['player1EloGain'] ?? 0;
//         } else if (data['winnerId'] == 'draw') {
//           result = 'draw';
//           eloChange = data['player1EloChange'] ?? 0;
//         } else {
//           result = 'loss';
//           eloChange = data['player1EloLoss'] ?? 0;
//         }
//       } else {
//         opponentName = data['player1Name'] ?? 'Unknown';
//         opponentAvatar = data['player1Avatar'] ?? '';
//         opponentUid = data['player1Id'] ?? '';
//         if (data['winnerId'] == currentUserId) {
//           result = 'win';
//           eloChange = data['player2EloGain'] ?? 0;
//         } else if (data['winnerId'] == 'draw') {
//           result = 'draw';
//           eloChange = data['player2EloChange'] ?? 0;
//         } else {
//           result = 'loss';
//           eloChange = data['player2EloLoss'] ?? 0;
//         }
//       }
//     } catch (e) {
//       debugPrint('Error parsing match data: $e');
//     }
//     return MatchHistoryItem(
//       matchId: data['matchId'] ?? '',
//       opponentName: opponentName,
//       opponentAvatarUrl: opponentAvatar,
//       opponentUid: opponentUid,
//       result: result,
//       gameMode: data['gameMode'] ?? 'Competitive',
//       eloChange: eloChange,
//       timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
//     );
//   }
// }

// // ==================== ANIMATED PARTICLE ====================
// class AnimatedParticle {
//   Offset position;
//   double radius;
//   Color color;
//   double speed;
//   double angle;
//   AnimatedParticle({
//     required this.position,
//     required this.radius,
//     required this.color,
//     required this.speed,
//     required this.angle,
//   });
// }

// // ==================== MAIN SCREEN ====================
// class EnhancedProfileScreen extends StatefulWidget {
//   const EnhancedProfileScreen({super.key});
//   @override
//   State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
// }

// class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _shimmerController,
//       _pulseController,
//       _backgroundController;
//   late Animation<double> _pulseAnimation;
//   ProfileData? _currentUserProfile;
//   List<MatchHistoryItem> _matchHistory = [];
//   bool _isLoadingProfile = true, _isLoadingMatches = true;
//   String? _currentUserId, _matchLoadError;
//   final List<AnimatedParticle> _particles = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _initializeParticles();
//     _loadUserData();
//   }

//   void _initializeAnimations() {
//     _shimmerController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);
//     _backgroundController = AnimationController(
//       duration: const Duration(seconds: 30),
//       vsync: this,
//     )..repeat();
//     _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   void _initializeParticles() {
//     final random = math.Random();
//     for (int i = 0; i < 25; i++) {
//       _particles.add(
//         AnimatedParticle(
//           position: Offset(
//             random.nextDouble() * 400,
//             random.nextDouble() * 800,
//           ),
//           radius: random.nextDouble() * 2.5 + 0.5,
//           color:
//               [
//                 DarkThemeColors.accentPurple.withOpacity(0.4),
//                 DarkThemeColors.accentBlue.withOpacity(0.3),
//                 DarkThemeColors.accentPink.withOpacity(0.3),
//                 DarkThemeColors.accentGreen.withOpacity(0.2),
//               ][random.nextInt(4)],
//           speed: random.nextDouble() * 0.4 + 0.2,
//           angle: random.nextDouble() * math.pi * 2,
//         ),
//       );
//     }
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         setState(() => _currentUserId = user.uid);
//         await _loadCurrentUserProfile();
//         await _loadMatchHistory();
//       } else {
//         setState(() {
//           _isLoadingProfile = false;
//           _isLoadingMatches = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error loading user data: $e');
//       setState(() {
//         _isLoadingProfile = false;
//         _isLoadingMatches = false;
//       });
//     }
//   }

//   Future<void> _loadCurrentUserProfile() async {
//     if (_currentUserId == null) {
//       setState(() => _isLoadingProfile = false);
//       return;
//     }
//     try {
//       final doc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(_currentUserId)
//               .get();
//       if (doc.exists && mounted) {
//         setState(() {
//           _currentUserProfile = ProfileData.fromFirestore(doc);
//           _isLoadingProfile = false;
//         });
//       } else {
//         setState(() => _isLoadingProfile = false);
//       }
//     } catch (e) {
//       debugPrint('Error loading profile: $e');
//       if (mounted) setState(() => _isLoadingProfile = false);
//     }
//   }

//   Future<void> _loadMatchHistory() async {
//     setState(() {
//       _isLoadingMatches = true;
//       _matchLoadError = null;
//     });
//     if (_currentUserId == null) {
//       setState(() {
//         _isLoadingMatches = false;
//         _matchLoadError = 'User not logged in';
//       });
//       return;
//     }
//     try {
//       final snapshot =
//           await FirebaseFirestore.instance
//               .collection('matches')
//               .where('players', arrayContains: _currentUserId)
//               .orderBy('timestamp', descending: true)
//               .limit(10)
//               .get();
//       List<MatchHistoryItem> matches =
//           snapshot.docs
//               .map(
//                 (doc) =>
//                     MatchHistoryItem.fromFirestore(doc.data(), _currentUserId!),
//               )
//               .toList();
//       if (mounted)
//         setState(() {
//           _matchHistory = matches;
//           _isLoadingMatches = false;
//         });
//     } catch (e) {
//       debugPrint('Error loading match history: $e');
//       String errorMessage = 'Unable to load matches';
//       if (e.toString().contains('index'))
//         errorMessage =
//             'Database index required. Please create it in Firestore.';
//       if (mounted)
//         setState(() {
//           _isLoadingMatches = false;
//           _matchLoadError = errorMessage;
//         });
//     }
//   }

//   Future<void> _handleLogout() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (ctx) => AlertDialog(
//             backgroundColor: DarkThemeColors.cardBackground,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(24),
//               side: BorderSide(
//                 color: DarkThemeColors.accentPurple.withOpacity(0.3),
//               ),
//             ),
//             title: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.red.withOpacity(0.2),
//                         Colors.redAccent.withOpacity(0.1),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.red.withOpacity(0.3)),
//                   ),
//                   child: const Icon(
//                     Icons.logout_rounded,
//                     color: Colors.redAccent,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'Logout',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             content: const Text(
//               'Are you sure you want to log out?',
//               style: TextStyle(color: Colors.white70, fontSize: 15),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(false),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.white.withOpacity(0.6)),
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Colors.redAccent, Colors.red],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.red.withOpacity(0.3),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(ctx).pop(true);
//                   },
//                   child: const Text(
//                     'Logout',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true && mounted) {
//       try {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.clear();

//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (context) => const Center(
//                 child: CircularProgressIndicator(
//                   color: DarkThemeColors.accentPurple,
//                 ),
//               ),
//         );
//         await Provider.of<UserProvider>(context, listen: false).logout();
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading spinner
//         Fluttertoast.showToast(
//           msg: '✅ Logged out successfully',
//           backgroundColor: DarkThemeColors.accentGreen.withOpacity(0.9),
//           textColor: Colors.black,
//         );
//         if (mounted)
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const AuthSwitcher()),
//             (route) => false,
//           );
//       } catch (e) {
//         if (mounted) Navigator.of(context).pop(); // Dismiss loading spinner
//         Fluttertoast.showToast(
//           msg: '❌ Error logging out',
//           backgroundColor: Colors.red.withOpacity(0.9),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _shimmerController.dispose();
//     _pulseController.dispose();
//     _backgroundController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: DarkThemeColors.primaryBackground,
//       body: Stack(
//         children: [
//           _buildAnimatedBackground(),
//           AnimatedBuilder(
//             animation: _backgroundController,
//             builder:
//                 (context, child) => CustomPaint(
//                   painter: ParticlePainter(
//                     particles: _particles,
//                     animation: _backgroundController.value,
//                   ),
//                   child: Container(),
//                 ),
//           ),
//           SafeArea(
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 SliverAppBar(
//                   leading: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: InkWell(
//                       onTap: () => Navigator.of(context).pop(),
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: DarkThemeColors.secondaryBackground
//                               .withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.1),
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                   ),
//                   actions: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: InkWell(
//                         onTap: _handleLogout,
//                         borderRadius: BorderRadius.circular(12),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.red.withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.red.withOpacity(0.3),
//                             ),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(
//                                 Icons.logout_rounded,
//                                 color: Colors.redAccent,
//                                 size: 18,
//                               ),
//                               SizedBox(width: 6),
//                               Text(
//                                 'Logout',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   pinned: true,
//                 ),
//                 SliverToBoxAdapter(
//                   child:
//                       _isLoadingProfile
//                           ? _buildLoadingState()
//                           : (_currentUserProfile == null
//                               ? _buildEmptyState()
//                               : _buildProfileContent(_currentUserProfile!)),
//                 ),
//               ],
//             ),
//           ),
//         ],
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
//                   DarkThemeColors.primaryBackground,
//                   DarkThemeColors.accentPurple.withOpacity(0.1),
//                   DarkThemeColors.accentBlue.withOpacity(0.1),
//                   DarkThemeColors.primaryBackground,
//                 ],
//                 stops: const [0.0, 0.3, 0.7, 1.0],
//               ),
//             ),
//           ),
//     );
//   }

//   Widget _buildProfileContent(ProfileData profile) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: [
//           _buildEnhancedProfileCard(profile),
//           const SizedBox(height: 24),
//           _buildQuickStats(profile),
//           const SizedBox(height: 24),
//           _buildDetailedStats(profile),
//           const SizedBox(height: 32), // Added some space
//           // ======== NEW, STYLED BUTTON ========
//           GradientButton(
//             width: 220,
//             height: 55,
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => const AboutUsScreen()),
//               );
//             },
//             child: const Text(
//               'ABOUT US',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 letterSpacing: 1.5,
//               ),
//             ),
//           ),
//           const SizedBox(height: 32), // Added some space
//           // _buildRecentMatches(),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 0.7,
//       child: Center(
//         child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 110,
//                   height: 110,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: LinearGradient(
//                       colors: [
//                         DarkThemeColors.accentPurple.withOpacity(0.3),
//                         DarkThemeColors.accentBlue.withOpacity(0.3),
//                       ],
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: DarkThemeColors.accentPurple.withOpacity(0.3),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: const Center(
//                     child: CircularProgressIndicator(
//                       color: DarkThemeColors.accentPurple,
//                       strokeWidth: 3.5,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 _buildShimmerText('Loading Profile...', 18),
//               ],
//             )
//             .animate(onPlay: (c) => c.repeat())
//             .shimmer(duration: 1500.ms, color: Colors.white12),
//       ),
//     );
//   }

//   Widget _buildShimmerText(String text, double fontSize) {
//     return Text(
//       text,
//       style: TextStyle(
//         color: Colors.white.withOpacity(0.5),
//         fontSize: fontSize,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 0.6,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(32),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     DarkThemeColors.accentPurple.withOpacity(0.2),
//                     DarkThemeColors.accentBlue.withOpacity(0.2),
//                   ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: DarkThemeColors.accentPurple.withOpacity(0.15),
//                     blurRadius: 30,
//                     spreadRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.person_off_rounded,
//                 size: 80,
//                 color: Colors.white.withOpacity(0.6),
//               ),
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'Profile Not Found',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Unable to load your profile data.\nPlease try again later.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.5),
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
//       ),
//     );
//   }

//   Widget _buildEnhancedProfileCard(ProfileData profile) {
//     final isTopPlayer =
//         profile.rank.toLowerCase().contains('master') ||
//         profile.rank.toLowerCase().contains('champion');

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(32),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             DarkThemeColors.accentPurple.withOpacity(0.15),
//             DarkThemeColors.accentBlue.withOpacity(0.12),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: DarkThemeColors.accentPurple.withOpacity(0.25),
//             blurRadius: 25,
//             offset: const Offset(0, 12),
//             spreadRadius: -5,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(32),
//         child: BackdropFilter(
//           filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(32),
//               border: Border.all(color: Colors.white.withOpacity(0.1)),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Colors.white.withOpacity(0.08),
//                   Colors.white.withOpacity(0.03),
//                 ],
//               ),
//             ),
//             child: Column(
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     ScaleTransition(
//                       scale: _pulseAnimation,
//                       child: Container(
//                         width: 140,
//                         height: 140,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: (isTopPlayer
//                                   ? DarkThemeColors.goldGradient
//                                   : DarkThemeColors.primaryGradient)
//                               .scale(0.5),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient:
//                             isTopPlayer
//                                 ? DarkThemeColors.goldGradient
//                                 : DarkThemeColors.primaryGradient,
//                         boxShadow: [
//                           BoxShadow(
//                             color: (isTopPlayer
//                                     ? DarkThemeColors.accentGold
//                                     : DarkThemeColors.accentPurple)
//                                 .withOpacity(0.5),
//                             blurRadius: 25,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: CircleAvatar(
//                         radius: 58,
//                         backgroundColor: DarkThemeColors.cardBackground,
//                         backgroundImage:
//                             profile.photoUrl.isNotEmpty
//                                 ? NetworkImage(profile.photoUrl)
//                                 : null,
//                         child:
//                             profile.photoUrl.isEmpty
//                                 ? const Icon(
//                                   Icons.person_rounded,
//                                   size: 55,
//                                   color: Colors.white60,
//                                 )
//                                 : null,
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 8,
//                       right: 8,
//                       child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: DarkThemeColors.cardBackground,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 2),
//                             ),
//                             child: Container(
//                               width: 12,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: DarkThemeColors.accentGreen,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: DarkThemeColors.accentGreen
//                                         .withOpacity(0.8),
//                                     blurRadius: 8,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           )
//                           .animate(onPlay: (c) => c.repeat())
//                           .scale(
//                             duration: 1500.ms,
//                             begin: const Offset(0.9, 0.9),
//                             end: const Offset(1.2, 1.2),
//                             curve: Curves.easeInOut,
//                           )
//                           .then()
//                           .scale(
//                             begin: const Offset(1.2, 1.2),
//                             end: const Offset(0.9, 0.9),
//                           ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   profile.gamertag,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: DarkThemeColors.secondaryBackground.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(color: Colors.white.withOpacity(0.1)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         isTopPlayer
//                             ? Icons.workspace_premium_rounded
//                             : Icons.star_rounded,
//                         color:
//                             isTopPlayer
//                                 ? DarkThemeColors.accentGold
//                                 : DarkThemeColors.accentPurple,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         profile.rank,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9));
//   }

//   Widget _buildQuickStats(ProfileData profile) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildQuickStatCard(
//             icon: Icons.leaderboard_rounded,
//             value: profile.elo.toString(),
//             label: 'ELO',
//             gradient: [DarkThemeColors.accentGold, Colors.orange],
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildQuickStatCard(
//             icon: Icons.percent_rounded,
//             value: '${profile.winPercentage.toStringAsFixed(0)}%',
//             label: 'Win Rate',
//             gradient: [DarkThemeColors.accentGreen, Colors.teal],
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildQuickStatCard(
//             icon: Icons.sports_esports_rounded,
//             value: profile.gamesPlayed.toString(),
//             label: 'Games',
//             gradient: [DarkThemeColors.accentBlue, Colors.indigo],
//           ),
//         ),
//       ],
//     ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3);
//   }

//   Widget _buildQuickStatCard({
//     required IconData icon,
//     required String value,
//     required String label,
//     required List<Color> gradient,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(22),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: gradient.map((c) => c.withOpacity(0.85)).toList(),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: gradient.first.withOpacity(0.4),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//             spreadRadius: -2,
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.white, size: 26),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.95),
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailedStats(ProfileData profile) {
//     return Container(
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         color: DarkThemeColors.secondaryBackground.withOpacity(0.6),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   gradient: DarkThemeColors.primaryGradient,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Icon(
//                   Icons.analytics_rounded,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//               ),
//               const SizedBox(width: 14),
//               const Text(
//                 'Performance Stats',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 19,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),
//           _buildStatBar(
//             'Wins',
//             profile.wins,
//             profile.gamesPlayed,
//             DarkThemeColors.accentGreen,
//           ),
//           const SizedBox(height: 14),
//           _buildStatBar(
//             'Losses',
//             profile.losses,
//             profile.gamesPlayed,
//             Colors.redAccent,
//           ),
//           const SizedBox(height: 14),
//           _buildStatBar(
//             'Draws',
//             profile.draws,
//             profile.gamesPlayed,
//             Colors.orangeAccent,
//           ),
//         ],
//       ),
//     ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.2);
//   }

//   Widget _buildStatBar(String label, int value, int total, Color color) {
//     final percentage = total > 0 ? (value / total) : 0.0;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.85),
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             Text(
//               value.toString(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 17,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         LayoutBuilder(
//           builder:
//               (context, constraints) => ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: Container(
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: AnimatedContainer(
//                       duration: 1200.ms,
//                       curve: Curves.easeOutCubic,
//                       width: constraints.maxWidth * percentage,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [color, color.withOpacity(0.7)],
//                         ),
//                         borderRadius: BorderRadius.circular(6),
//                         boxShadow: [
//                           BoxShadow(
//                             color: color.withOpacity(0.5),
//                             blurRadius: 8,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRecentMatches() {
//     return Container(
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         color: DarkThemeColors.secondaryBackground.withOpacity(0.6),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       gradient: DarkThemeColors.secondaryGradient,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: const Icon(
//                       Icons.history_rounded,
//                       color: Colors.white,
//                       size: 22,
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   const Text(
//                     'Recent Matches',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               IconButton(
//                 onPressed: _loadMatchHistory,
//                 icon: Icon(
//                   Icons.refresh_rounded,
//                   color: Colors.white.withOpacity(0.6),
//                   size: 22,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _isLoadingMatches
//               ? const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(24),
//                   child: CircularProgressIndicator(
//                     color: DarkThemeColors.accentBlue,
//                     strokeWidth: 3,
//                   ),
//                 ),
//               )
//               : _matchLoadError != null
//               ? Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.error_outline_rounded,
//                       size: 52,
//                       color: Colors.orangeAccent.withOpacity(0.8),
//                     ),
//                     const SizedBox(height: 14),
//                     Text(
//                       _matchLoadError!,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.75),
//                         fontSize: 15,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Check Firestore rules or database setup.',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.4),
//                         fontSize: 13,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               )
//               : _matchHistory.isEmpty
//               ? Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.sports_esports_outlined,
//                       size: 52,
//                       color: Colors.white.withOpacity(0.3),
//                     ),
//                     const SizedBox(height: 14),
//                     Text(
//                       'No matches played yet',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.6),
//                         fontSize: 15,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//               : Column(
//                 children:
//                     _matchHistory
//                         .asMap()
//                         .entries
//                         .map(
//                           (e) => _buildMatchHistoryTile(e.value)
//                               .animate(delay: (100 + e.key * 50).ms)
//                               .fadeIn()
//                               .slideY(begin: 0.2),
//                         )
//                         .toList(),
//               ),
//         ],
//       ),
//     ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.2);
//   }

//   Widget _buildMatchHistoryTile(MatchHistoryItem match) {
//     Color resultColor;
//     String resultText;
//     switch (match.result) {
//       case 'win':
//         resultColor = DarkThemeColors.accentGreen;
//         resultText = 'WIN';
//         break;
//       case 'loss':
//         resultColor = Colors.redAccent;
//         resultText = 'LOSS';
//         break;
//       default:
//         resultColor = Colors.orangeAccent;
//         resultText = 'DRAW';
//         break;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: DarkThemeColors.cardBackground.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.white.withOpacity(0.05)),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(18),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18),
//           onTap: () {},
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 24,
//                   backgroundColor: DarkThemeColors.secondaryBackground,
//                   backgroundImage:
//                       match.opponentAvatarUrl.isNotEmpty
//                           ? NetworkImage(match.opponentAvatarUrl)
//                           : null,
//                   child:
//                       match.opponentAvatarUrl.isEmpty
//                           ? const Icon(
//                             Icons.person_rounded,
//                             color: Colors.white60,
//                             size: 22,
//                           )
//                           : null,
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         match.opponentName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time_rounded,
//                             size: 13,
//                             color: Colors.white.withOpacity(0.5),
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             _formatTime(match.timestamp),
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.5),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: resultColor.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: resultColor.withOpacity(0.4)),
//                       ),
//                       child: Text(
//                         resultText,
//                         style: TextStyle(
//                           color: resultColor,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       '${match.eloChange >= 0 ? '+' : ''}${match.eloChange} ELO',
//                       style: TextStyle(
//                         color:
//                             match.eloChange >= 0
//                                 ? DarkThemeColors.accentGreen
//                                 : Colors.red,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatTime(DateTime timestamp) {
//     final difference = DateTime.now().difference(timestamp);
//     if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
//     if (difference.inHours < 24) return '${difference.inHours}h ago';
//     if (difference.inDays < 7) return '${difference.inDays}d ago';
//     return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
//   }
// }

// // ==================== PARTICLE PAINTER ====================
// class ParticlePainter extends CustomPainter {
//   final List<AnimatedParticle> particles;
//   final double animation;

//   ParticlePainter({required this.particles, required this.animation});

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (size.width <= 0 || size.height <= 0) return;
//     final paint =
//         Paint()
//           ..style = PaintingStyle.fill
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
//     for (var p in particles) {
//       paint.color = p.color;
//       final newX =
//           p.position.dx + math.sin(animation * math.pi * 2 + p.angle) * 35;
//       final newY =
//           p.position.dy - (animation * size.height * p.speed) % size.height;
//       canvas.drawCircle(
//         Offset(newX, newY < 0 ? size.height + newY : newY),
//         p.radius,
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // ==================== GRADIENT BUTTON WIDGET ====================
// class GradientButton extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onPressed;
//   final Gradient gradient;
//   final double? width;
//   final double height;

//   const GradientButton({
//     Key? key,
//     required this.child,
//     required this.onPressed,
//     this.width,
//     this.height = 50.0,
//     this.gradient = const LinearGradient(
//       colors: [DarkThemeColors.accentPurple, DarkThemeColors.accentBlue],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         gradient: gradient,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: DarkThemeColors.accentPurple.withOpacity(0.4),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(16),
//           child: Center(child: child),
//         ),
//       ),
//     );
//   }
// }

// // Extension for gradient scaling
// extension GradientExtension on LinearGradient {
//   LinearGradient scale(double opacity) {
//     return LinearGradient(
//       colors: colors.map((c) => c.withOpacity(opacity)).toList(),
//       begin: begin,
//       end: end,
//     );
//   }
// }
