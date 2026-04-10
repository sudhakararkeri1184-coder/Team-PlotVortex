// lib/chess_screen/chess_CompetitiveMode/services/firebase_game_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/rank_info.dart';
import 'package:v2/chess_screen/chess_CompetitiveMode/services/elo_calculator.dart';

class FirebaseGameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateGameState({
    required String lobbyId,
    required String fen,
    required String turn,
    required List<dynamic> moves,
    String? lastMove,
    String? statusMessage,
  }) async {
    await _firestore.collection('competitive_lobbies').doc(lobbyId).update({
      'gameState.fen': fen,
      'gameState.turn': turn,
      'gameState.moves': moves,
      'gameState.lastMove': lastMove,
      'gameState.statusMessage': statusMessage ?? '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> endGame({
    required String lobbyId,
    required String winnerId,
    required String loserId,
    bool isDraw = false,
  }) async {
    final lobbyRef = _firestore.collection('competitive_lobbies').doc(lobbyId);

    try {
      await _firestore.runTransaction((transaction) async {
        // --- STEP 1: READ ALL DOCUMENTS FIRST ---
        final lobbyDoc = await transaction.get(lobbyRef);

        if (!lobbyDoc.exists || lobbyDoc.data()?['status'] == 'completed') {
          debugPrint("Game already completed or does not exist.");
          return;
        }

        final data = lobbyDoc.data()!;
        final hostData = data['host'] as Map<String, dynamic>;
        final guestData = data['guest'] as Map<String, dynamic>;

        final hostRef = _firestore.collection('users').doc(hostData['uid']);
        final guestRef = _firestore.collection('users').doc(guestData['uid']);

        final hostUserDoc = await transaction.get(hostRef);
        final guestUserDoc = await transaction.get(guestRef);

        if (!hostUserDoc.exists || !guestUserDoc.exists) {
          throw Exception("One or both player profiles could not be found.");
        }

        // --- STEP 2: PERFORM ALL CALCULATIONS ---
        int hostElo = hostData['elo'] ?? 1200;
        int guestElo = guestData['elo'] ?? 1200;

        Map<String, int> newRatings;
        if (isDraw) {
          newRatings = EloCalculator.calculateNewRatings(
            winnerElo: hostElo,
            loserElo: guestElo,
            isDraw: true,
          );
        } else {
          bool hostWon = winnerId == hostData['uid'];
          newRatings =
              hostWon
                  ? EloCalculator.calculateNewRatings(
                    winnerElo: hostElo,
                    loserElo: guestElo,
                  )
                  : EloCalculator.calculateNewRatings(
                    winnerElo: guestElo,
                    loserElo: hostElo,
                  );

          if (!hostWon) {
            newRatings = {
              'winner': newRatings['loser']!,
              'loser': newRatings['winner']!,
            };
          }
        }

        final hostUpdateMap = _calculatePlayerUpdateMap(
          won: !isDraw && winnerId == hostData['uid'],
          draw: isDraw,
          newElo:
              isDraw
                  ? newRatings['winner']!
                  : (winnerId == hostData['uid']
                      ? newRatings['winner']!
                      : newRatings['loser']!),
          oldElo: hostElo,
          currentUserData: hostUserDoc.data()!,
        );

        final guestUpdateMap = _calculatePlayerUpdateMap(
          won: !isDraw && winnerId == guestData['uid'],
          draw: isDraw,
          newElo:
              isDraw
                  ? newRatings['loser']!
                  : (winnerId == guestData['uid']
                      ? newRatings['winner']!
                      : newRatings['loser']!),
          oldElo: guestElo,
          currentUserData: guestUserDoc.data()!,
        );

        // --- STEP 3: PERFORM ALL WRITES ---
        // Add fields required by Firestore security rules to allow
        // updating the opponent's user document
        hostUpdateMap['is_game_end_transaction'] = true;
        hostUpdateMap['transaction_lobby_id'] = lobbyId;
        guestUpdateMap['is_game_end_transaction'] = true;
        guestUpdateMap['transaction_lobby_id'] = lobbyId;

        // Update users FIRST (before lobby), so the security rule's
        // get() on the lobby still sees the original host/guest data
        transaction.update(hostRef, hostUpdateMap);
        transaction.update(guestRef, guestUpdateMap);

        // Update lobby LAST
        transaction.update(lobbyRef, {
          'status': 'completed',
          'winner': isDraw ? 'draw' : winnerId,
          'completedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error ending game transaction: $e');
      rethrow;
    }
  }

  // ✅✅✅ THIS IS THE NEW, CORRECTED RANK PROMOTION LOGIC ✅✅✅
  Map<String, dynamic> _calculatePlayerUpdateMap({
    required bool won,
    required bool draw,
    required int newElo,
    required int oldElo,
    required Map<String, dynamic> currentUserData,
  }) {
    // --- SETUP ---
    int currentProgress = currentUserData['rank_progress_wins'] ?? 0;
    RankInfo oldRank = RankInfo.getRankFromElo(oldElo);
    RankInfo newRankBasedOnElo = RankInfo.getRankFromElo(newElo);
    RankInfo finalRank =
        newRankBasedOnElo; // Start by assuming the rank is based on the new ELO
    bool wasPromoted = false;

    // --- STEP 1: CALCULATE NEW WIN PROGRESS ---
    int updatedProgress = currentProgress;
    if (won) {
      // Only increment progress if the rank requires wins
      if (oldRank.winsRequired > 0) {
        updatedProgress++;
      }
    } else if (!draw) {
      // Any loss resets progress
      updatedProgress = 0;
    }
    // On a draw, progress remains unchanged.

    // --- STEP 2: CHECK FOR PROMOTION ---
    // A player can be promoted if they win, and after that win,
    // they meet both the ELO and win requirements.
    if (won) {
      final nextRank = RankInfo.getNextRank(oldRank.name);
      if (nextRank != null && oldRank.winsRequired > 0) {
        // Check the two conditions for promotion:
        bool hasEnoughWins = updatedProgress >= oldRank.winsRequired;
        bool hasEnoughElo = newElo >= nextRank.eloMin;

        if (hasEnoughWins && hasEnoughElo) {
          // *** PROMOTION! ***
          wasPromoted = true;
          // The new rank is determined by their new ELO, which we already calculated.
          finalRank = newRankBasedOnElo;
          // Reset progress for the new rank.
          updatedProgress = 0;
        }
      }
    }

    // --- STEP 3: HANDLE RANK CHANGES (PROMOTION/DEMOTION) ---
    // If the player's rank changed for any reason (promotion via wins,
    // or demotion via ELO loss), their progress in the new rank must be 0.
    if (finalRank.name != oldRank.name) {
      updatedProgress = 0;
    }

    // --- STEP 4: BUILD THE FINAL UPDATE MAP ---
    return {
      'elo': newElo,
      'wins': FieldValue.increment(won ? 1 : 0),
      'losses': FieldValue.increment(!won && !draw ? 1 : 0),
      'draws': FieldValue.increment(draw ? 1 : 0),
      'matches_played': FieldValue.increment(1),

      // Use the final calculated progress. It's either incremented, reset, or unchanged.
      'rank_progress_wins': updatedProgress,

      // ✅ THIS IS THE MOST IMPORTANT LINE.
      // It saves the determined rank's name (e.g., "Silver") to the database.
      // The UI will now read this correct, updated value.
      'rank': finalRank.name,
      'rank_index': RankInfo.getRankIndex(finalRank.name),

      'last_match': FieldValue.serverTimestamp(),
    };
  }

  // The rest of the methods are correct and don't need changes.

  Future<void> resignGame(String lobbyId, String resigningPlayerId) async {
    final lobbyDoc =
        await _firestore.collection('competitive_lobbies').doc(lobbyId).get();
    if (!lobbyDoc.exists) return;
    final data = lobbyDoc.data()!;
    final hostUid = data['host']['uid'];
    final guestUid = data['guest']['uid'];
    final winnerId = resigningPlayerId == hostUid ? guestUid : hostUid;
    await endGame(
      lobbyId: lobbyId,
      winnerId: winnerId,
      loserId: resigningPlayerId,
    );
  }

  Future<void> offerDraw(String lobbyId, String offeringPlayerId) async {
    await _firestore.collection('competitive_lobbies').doc(lobbyId).update({
      'drawOffer': offeringPlayerId,
      'drawOfferTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptDraw(String lobbyId) async {
    final lobbyDoc =
        await _firestore.collection('competitive_lobbies').doc(lobbyId).get();
    if (!lobbyDoc.exists) return;
    final data = lobbyDoc.data()!;
    await endGame(
      lobbyId: lobbyId,
      winnerId: data['host']['uid'],
      loserId: data['guest']['uid'],
      isDraw: true,
    );
  }

  Future<void> declineDraw(String lobbyId) async {
    await _firestore.collection('competitive_lobbies').doc(lobbyId).update({
      'drawOffer': null,
      'drawOfferTime': null,
    });
  }
}
