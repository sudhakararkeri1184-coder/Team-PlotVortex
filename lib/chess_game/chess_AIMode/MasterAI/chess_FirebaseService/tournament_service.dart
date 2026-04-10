import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Join tournament as free player
  Future<bool> joinTournamentAsFree({
    required String tournamentId,
    required String userId,
    required String userName,
  }) async {
    try {
      print('🎮 Joining as Free player...');

      // Check if user already joined
      final existing =
          await _firestore
              .collection('tournament_players')
              .where('tournamentId', isEqualTo: tournamentId)
              .where('userId', isEqualTo: userId)
              .get();

      if (existing.docs.isNotEmpty) {
        print('⚠ User already joined this tournament');
        return false;
      }

      // Add player to tournament
      await _firestore.collection('tournament_players').add({
        'tournamentId': tournamentId,
        'userId': userId,
        'userName': userName,
        'joinType': 'free',
        'paymentId': null,
        'amountPaid': 0,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Successfully joined as free player');
      return true;
    } catch (e) {
      print('❌ Error joining tournament: $e');
      return false;
    }
  }
  // Add these methods to your FirebaseTournamentService class:

  Future<void> recordMatchResult(
    String tournamentId,
    String matchId,
    String winnerId,
  ) async {
    try {
      // Update match result
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .doc(matchId)
          .set({
            'winnerId': winnerId,
            'completedAt': FieldValue.serverTimestamp(),
            'status': 'completed',
          }, SetOptions(merge: true));

      // Advance winner to next round
      await advanceToNextRound(tournamentId, winnerId);
    } catch (e) {
      print('Error recording match result: $e');
    }
  }

  Future<void> advanceToNextRound(String tournamentId, String winnerId) async {
    // Logic to advance winner to next round in bracket
    // This depends on your tournament bracket structure
  }

  Stream<DocumentSnapshot> watchGameState(String tournamentId, String matchId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('games')
        .doc(matchId)
        .snapshots();
  }

  // ✅ Join tournament as premium player
  Future<bool> joinTournamentAsPremium({
    required String tournamentId,
    required String userId,
    required String userName,
    required String paymentId,
    required double amountPaid,
  }) async {
    try {
      print('💳 Joining as Premium player...');

      // Check if user already joined
      final existing =
          await _firestore
              .collection('tournament_players')
              .where('tournamentId', isEqualTo: tournamentId)
              .where('userId', isEqualTo: userId)
              .get();

      if (existing.docs.isNotEmpty) {
        print('⚠ User already joined this tournament');
        return false;
      }

      // Add player to tournament
      await _firestore.collection('tournament_players').add({
        'tournamentId': tournamentId,
        'userId': userId,
        'userName': userName,
        'joinType': 'premium',
        'paymentId': paymentId,
        'amountPaid': amountPaid,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Optionally store payment record
      await _firestore.collection('payments').add({
        'userId': userId,
        'tournamentId': tournamentId,
        'paymentId': paymentId,
        'amount': amountPaid,
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ Successfully joined as premium player');
      return true;
    } catch (e) {
      print('❌ Error joining tournament: $e');
      return false;
    }
  }

  // ✅ Get tournament player count
  Future<int> getTournamentPlayerCount(String tournamentId) async {
    try {
      final snapshot =
          await _firestore
              .collection('tournament_players')
              .where('tournamentId', isEqualTo: tournamentId)
              .get();

      return snapshot.docs.length;
    } catch (e) {
      print('❌ Error getting player count: $e');
      return 0;
    }
  }

  // ✅ Check if user already joined
  Future<bool> hasUserJoined({
    required String tournamentId,
    required String userId,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('tournament_players')
              .where('tournamentId', isEqualTo: tournamentId)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking user joined: $e');
      return false;
    }
  }
}
