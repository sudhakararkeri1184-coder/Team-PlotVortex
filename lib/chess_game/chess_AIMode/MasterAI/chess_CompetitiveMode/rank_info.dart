// lib/chess_screen/chess_CompetitiveMode/models/rank_info.dart

import 'package:flutter/material.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/chess_rank_screen.dart';
// import 'package:v2/screens/chess_rank_screen.dart'; // Import for colors

class RankInfo {
  final String name;
  final String title;
  final int eloMin;
  final int eloMax;
  final int winsRequired; // Wins needed to progress *through* this rank
  final IconData icon;
  final Color color;

  const RankInfo({
    required this.name,
    required this.title,
    required this.eloMin,
    required this.eloMax,
    required this.winsRequired,
    required this.icon,
    required this.color,
  });

  // This is the single source of truth for your entire ranking system
  static final List<RankInfo> allRanks = [
    const RankInfo(
      name: "Bronze",
      title: "Beginner",
      eloMin: 0,
      eloMax: 1399,
      winsRequired: 4,
      icon: Icons.shield,
      color: Color(0xFFCD7F32),
    ),
    const RankInfo(
      name: "Silver",
      title: "Novice",
      eloMin: 1400,
      eloMax: 1599,
      winsRequired: 4,
      icon: Icons.security,
      color: Color(0xFFC0C0C0),
    ),
    const RankInfo(
      name: "Gold",
      title: "Skilled Player",
      eloMin: 1600,
      eloMax: 1799,
      winsRequired: 5,
      icon: Icons.workspace_premium,
      color: Color(0xFFFFD700),
    ),
    const RankInfo(
      name: "Platinum",
      title: "Advanced Player",
      eloMin: 1800,
      eloMax: 1999,
      winsRequired: 5,
      icon: Icons.diamond_outlined,
      color: Color(0xFF00CED1),
    ),
    const RankInfo(
      name: "Diamond",
      title: "Expert Player",
      eloMin: 2000,
      eloMax: 2199,
      winsRequired: 6,
      icon: Icons.diamond,
      color: Color(0xFFB9F2FF),
    ),
    const RankInfo(
      name: "Master",
      title: "Master Level",
      eloMin: 2200,
      eloMax: 2499,
      winsRequired: 6,
      icon: Icons.star,
      color: kAccentPink,
    ),
    const RankInfo(
      name: "Grandmaster",
      title: "Elite Level",
      eloMin: 2500,
      eloMax: 9999,
      winsRequired: 0,
      icon: Icons.emoji_events,
      color: kPrimaryPurple,
    ),
  ];

  static RankInfo getRankFromElo(int elo) {
    return allRanks.firstWhere(
      (rank) => elo >= rank.eloMin && elo <= rank.eloMax,
      orElse: () => allRanks.first, // Default to Bronze if something is wrong
    );
  }

  static RankInfo? getNextRank(String currentRankName) {
    final currentIndex = allRanks.indexWhere((r) => r.name == currentRankName);
    if (currentIndex != -1 && currentIndex < allRanks.length - 1) {
      return allRanks[currentIndex + 1];
    }
    return null; // No next rank
  }

  static int getRankIndex(String currentRankName) {
    return allRanks.indexWhere((r) => r.name == currentRankName);
  }
}
