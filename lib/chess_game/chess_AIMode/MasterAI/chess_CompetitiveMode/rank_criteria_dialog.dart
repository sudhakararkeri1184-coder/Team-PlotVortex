// lib/chess_screen/chess_CompetitiveMode/widgets/rank_criteria_dialog.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/chess_rank_screen.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/rank_info.dart';
// import 'package:v2/chess_screen/chess_CompetitiveMode/models/rank_info.dart';

// Import theme colors
// import 'package:v2/screens/chess_rank_screen.dart';

class RankCriteriaDialog extends StatelessWidget {
  final RankInfo currentRank;
  final int currentProgress;

  const RankCriteriaDialog({
    super.key,
    required this.currentRank,
    required this.currentProgress,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: kCardColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kPrimaryPurple.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: RankInfo.allRanks.length,
                  itemBuilder: (context, index) {
                    final rank = RankInfo.allRanks[index];
                    final isCurrent = rank.name == currentRank.name;
                    return _buildRankCriteriaCard(rank, isCurrent);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events, color: kPrimaryPurple, size: 28),
              SizedBox(width: 12),
              Text(
                "Rank Criteria",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kTextSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: kTextSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCriteriaCard(RankInfo rank, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            isCurrent
                ? LinearGradient(
                  colors: [
                    rank.color.withOpacity(0.3),
                    rank.color.withOpacity(0.1),
                  ],
                )
                : null,
        color: isCurrent ? null : kBgDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? rank.color : kTextSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                rank.name,
                style: TextStyle(
                  color: rank.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rank.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Current",
                    style: TextStyle(
                      color: kBgDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            rank.title,
            style: const TextStyle(color: kTextSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildCriteriaRow(
            Icons.bar_chart,
            "ELO Range",
            "${rank.eloMin} - ${rank.eloMax}",
          ),
          const SizedBox(height: 8),
          if (rank.winsRequired > 0)
            _buildCriteriaRow(
              Icons.star,
              "Wins Required",
              "${rank.winsRequired} wins",
            ),
          if (isCurrent && rank.winsRequired > 0) ...[
            const SizedBox(height: 16),
            const Text(
              "Your Progress",
              style: TextStyle(color: kTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: currentProgress / rank.winsRequired,
                      minHeight: 8,
                      backgroundColor: kTextSecondary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(rank.color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "$currentProgress / ${rank.winsRequired}",
                  style: TextStyle(
                    color: rank.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kTextSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: kTextSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
