// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/game_provider.dart';

// class GameControls extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Color(0xFF2E7D32),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 4,
//             offset: Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildControlButton(
//             icon: Icons.refresh,
//             label: 'Reset',
//             onPressed: () {
//               context.read<GameProvider>().resetGame();
//             },
//           ),
//           Consumer<GameProvider>(
//             builder: (context, gameProvider, child) {
//               return Container(
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: Colors.white24,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.speed, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text(
//                       'Power: ${(gameProvider.shotPower * 100).toInt()}%',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           _buildControlButton(
//             icon: Icons.pause,
//             label: 'Pause',
//             onPressed: () {
//               // Implement pause functionality
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.amber,
//         foregroundColor: Colors.black,
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//     );
//   }
// }