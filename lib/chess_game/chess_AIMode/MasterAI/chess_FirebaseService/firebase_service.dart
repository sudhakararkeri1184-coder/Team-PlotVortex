// lib/chess_screen/chess_FirebaseService/.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v2/chess_screen/chess_TournamentMode/model/chess_tournament_model.dart';
import 'package:v2/chess_screen/chess_TournamentMode/model/match_model.dart';

class PlayerInfo {
  final String userId;
  final String username;
  final int rating;

  PlayerInfo({
    required this.userId,
    required this.username,
    this.rating = 1200,
  });

  factory PlayerInfo.fromMap(Map<String, dynamic> map) => PlayerInfo(
    userId: map['userId'] ?? '',
    username: map['username'] ?? 'Unknown',
    rating: map['rating'] ?? 1200,
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'username': username,
    'rating': rating,
  };
}

class FirebaseTournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _ensureAuthenticated() async {
    if (_auth.currentUser == null) await _auth.signInAnonymously();
  }

  Future<String> getCurrentUserId() async {
    await _ensureAuthenticated();
    return _auth.currentUser!.uid;
  }

  Future<PlayerInfo> getCurrentPlayerInfo() async {
    final userId = await getCurrentUserId();
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      return PlayerInfo(
        userId: userId,
        username: data['gamertag'] ?? data['username'] ?? 'Player',
        rating: data['elo'] ?? data['rating'] ?? 1200,
      );
    }
    return PlayerInfo(
      userId: userId,
      username: 'Player${userId.substring(0, 4)}',
    );
  }

  Future<void> createTournament(TournamentModel tournament) async {
    final docRef = _firestore
        .collection('tournaments')
        .doc(tournament.tournamentId);
    await docRef.set(tournament.toMap());
  }

  Stream<List<TournamentModel>> getTournamentsStream() => _firestore
      .collection('tournaments')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => TournamentModel.fromFirestore(d)).toList());

  Stream<TournamentModel?> getTournamentStream(String tournamentId) =>
      _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .snapshots()
          .map((d) => d.exists ? TournamentModel.fromFirestore(d) : null);

  Stream<int> getPlayerCountStream(String tournamentId) =>
      getTournamentStream(tournamentId).map((t) => t?.playersCount ?? 0);

  Stream<List<TournamentModel>> getMyCreatedTournamentsStream() async* {
    final userId = await getCurrentUserId();
    yield* _firestore
        .collection('tournaments')
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => TournamentModel.fromFirestore(d)).toList(),
        );
  }

  Stream<List<TournamentModel>> getMyJoinedTournamentsStream() async* {
    final userId = await getCurrentUserId();
    yield* _firestore
        .collection('tournaments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final tournaments = <TournamentModel>[];
          for (final doc in snapshot.docs) {
            final tournament = TournamentModel.fromFirestore(doc);
            final participants =
                doc.data()['participants'] as List<dynamic>? ?? [];
            if (participants.any((p) => p['userId'] == userId)) {
              tournaments.add(tournament);
            }
          }
          return tournaments;
        });
  }

  Future<int?> getUserPositionInTournament(String tournamentId) async {
    final userId = await getCurrentUserId();
    final doc =
        await _firestore.collection('tournaments').doc(tournamentId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data['status'] == 'completed' && data['winnerId'] != null) {
      if (data['winnerId'] == userId) return 1;
    }

    final participants = data['participants'] as List<dynamic>? ?? [];
    final participantIndex = participants.indexWhere(
      (p) => p['userId'] == userId,
    );
    return participantIndex >= 0 ? participantIndex + 1 : null;
  }

  // lib/chess_screen/chess_FirebaseService/.dart

  // lib/chess_screen/chess_FirebaseService/.dart

  // lib/chess_screen/chess_FirebaseService/.dart

  Future<void> joinTournament(String tournamentId, bool isPaid) async {
    final playerInfo = await getCurrentPlayerInfo();
    final docRef = _firestore.collection('tournaments').doc(tournamentId);

    // Step 1: Add player to tournament
    bool shouldStartTournament = false;

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception("Tournament not found");

      final data = doc.data()!;
      final List<dynamic> participants = List.from(data['participants'] ?? []);

      if (participants.any((p) => p['userId'] == playerInfo.userId)) {
        throw Exception("You have already joined this tournament");
      }

      if (participants.length >= 4) {
        throw Exception("Tournament is full (4/4 players)");
      }

      participants.add(playerInfo.toMap());

      transaction.update(docRef, {
        'participants': participants,
        'playersCount': participants.length,
      });

      // Check if we should start tournament after this transaction
      if (participants.length == 4) {
        shouldStartTournament = true;
      }
    });

    // Step 2: If 4 players, start tournament AFTER transaction completes
    if (shouldStartTournament) {
      print('🎮 4 players reached! Auto-starting tournament...');
      await _autoStartTournament(tournamentId);
    }
  }

  // Separate method to start tournament after player join completes
  // lib/chess_screen/chess_FirebaseService/.dart

  // Replace the _autoStartTournament method with this:

  Future<void> _autoStartTournament(String tournamentId) async {
    try {
      final docRef = _firestore.collection('tournaments').doc(tournamentId);

      // Get current tournament state
      final doc = await docRef.get();
      if (!doc.exists) {
        throw Exception("Tournament not found");
      }

      final data = doc.data()!;

      // Double-check we have 4 players and tournament hasn't started
      if (data['playersCount'] != 4) {
        print('⚠️ Tournament does not have 4 players, cannot start');
        return;
      }

      if (data['status'] == 'active') {
        print('⚠️ Tournament already started');
        return;
      }

      final participants = data['participants'] as List<dynamic>;
      final players = participants.map((p) => PlayerInfo.fromMap(p)).toList();

      // Shuffle players for random matchmaking
      players.shuffle(Random());

      print('🎲 Creating matches with shuffled players...');

      // STEP 1: Update tournament to active FIRST
      await docRef.update({
        'status': 'active',
        'currentRound': 1,
        'startedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Tournament status updated to active');

      // Small delay to ensure Firestore propagates the update
      await Future.delayed(const Duration(milliseconds: 500));

      // STEP 2: Create matches AFTER status is updated
      final batch = _firestore.batch();

      // Match 1: Player 1 vs Player 2
      final match1Ref = docRef.collection('matches').doc('semi-final-1');
      batch.set(match1Ref, {
        'matchId': 'semi-final-1',
        'round': 1,
        'matchNumber': 1,
        'player1': players[0].toMap(),
        'player2': players[1].toMap(),
        'status': 'pending',
        'winnerId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Match 2: Player 3 vs Player 4
      final match2Ref = docRef.collection('matches').doc('semi-final-2');
      batch.set(match2Ref, {
        'matchId': 'semi-final-2',
        'round': 1,
        'matchNumber': 2,
        'player1': players[2].toMap(),
        'player2': players[3].toMap(),
        'status': 'pending',
        'winnerId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Commit matches
      await batch.commit();

      print('✅ Tournament auto-started! Brackets created.');
      print('📋 Match 1: ${players[0].username} vs ${players[1].username}');
      print('📋 Match 2: ${players[2].username} vs ${players[3].username}');
    } catch (e) {
      print('❌ Error auto-starting tournament: $e');
      // Don't throw - let the user continue even if auto-start fails
    }
  }

  Future<bool> hasUserJoined(String tournamentId) async {
    final userId = await getCurrentUserId();
    final doc =
        await _firestore.collection('tournaments').doc(tournamentId).get();
    if (!doc.exists) return false;
    return (doc.data()?['participants'] as List<dynamic>? ?? []).any(
      (p) => p['userId'] == userId,
    );
  }

  Future<List<PlayerInfo>> getTournamentPlayers(String tournamentId) async {
    final doc =
        await _firestore.collection('tournaments').doc(tournamentId).get();
    if (!doc.exists) return [];
    final List<dynamic> data = doc.data()?['participants'] ?? [];
    return data.map((d) => PlayerInfo.fromMap(d)).toList();
  }

  // START TOURNAMENT - Creates Semi-Final Brackets
  Future<void> startTournament(String tournamentId) async {
    final ref = _firestore.collection('tournaments').doc(tournamentId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists || doc.data()?['status'] != 'upcoming') {
        throw Exception("Tournament cannot be started.");
      }

      List<PlayerInfo> players =
          (doc.data()?['participants'] as List<dynamic>? ?? [])
              .map((d) => PlayerInfo.fromMap(d))
              .toList();

      if (players.length != 4) {
        throw Exception("Need exactly 4 players to start tournament.");
      }

      // Shuffle players for random matchmaking
      players.shuffle(Random());

      final batch = _firestore.batch();

      // SEMI-FINALS (Round 1)
      // Match 1: Player 1 vs Player 2
      final match1Ref = ref.collection('matches').doc('semi-final-1');
      batch.set(
        match1Ref,
        MatchModel(
          matchId: 'semi-final-1',
          round: 1,
          matchNumber: 1,
          player1: players[0],
          player2: players[1],
          status: 'pending',
        ).toMap(),
      );

      // Match 2: Player 3 vs Player 4
      final match2Ref = ref.collection('matches').doc('semi-final-2');
      batch.set(
        match2Ref,
        MatchModel(
          matchId: 'semi-final-2',
          round: 1,
          matchNumber: 2,
          player1: players[2],
          player2: players[3],
          status: 'pending',
        ).toMap(),
      );

      await batch.commit();

      transaction.update(ref, {
        'status': 'active',
        'currentRound': 1,
        'startedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<MatchModel>> getMatchesStream(String tournamentId, int round) =>
      _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .where('round', isEqualTo: round)
          .orderBy('matchNumber')
          .snapshots()
          .map((s) => s.docs.map((d) => MatchModel.fromFirestore(d)).toList());

  // REPORT MATCH WINNER - Auto advances to next round
  Future<void> reportMatchWinner(
    String tournamentId,
    String matchId,
    String winnerId,
  ) async {
    print('🏆 Reporting match winner: $winnerId for match: $matchId');

    final matchRef = _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .doc(matchId);

    final tournamentRef = _firestore
        .collection('tournaments')
        .doc(tournamentId);

    await _firestore.runTransaction((transaction) async {
      final matchDoc = await transaction.get(matchRef);
      final tournamentDoc = await transaction.get(tournamentRef);

      if (!matchDoc.exists || !tournamentDoc.exists) {
        throw Exception('Match or tournament not found');
      }

      final matchData = matchDoc.data()!;
      if (matchData['status'] == 'completed') {
        print('⚠️ Match already completed');
        return;
      }

      // Update match as completed
      transaction.update(matchRef, {
        'winnerId': winnerId,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      final currentRound = tournamentDoc.data()!['currentRound'] ?? 1;

      // Check if this was a semi-final match
      if (currentRound == 1) {
        await _checkAndCreateFinal(tournamentId, transaction, tournamentRef);
      } else if (currentRound == 2) {
        // Finals completed - declare champion
        transaction.update(tournamentRef, {
          'status': 'completed',
          'winnerId': winnerId,
          'completedAt': FieldValue.serverTimestamp(),
        });
        print('🏆 TOURNAMENT CHAMPION: $winnerId');
      }
    });
  }

  // Create Final Match when both semi-finals are complete
  Future<void> _checkAndCreateFinal(
    String tournamentId,
    Transaction transaction,
    DocumentReference tournamentRef,
  ) async {
    final matchesSnapshot =
        await _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('matches')
            .where('round', isEqualTo: 1)
            .get();

    // Check if both semi-finals are completed
    final matches =
        matchesSnapshot.docs.map((d) => MatchModel.fromFirestore(d)).toList();

    if (matches.length == 2 && matches.every((m) => m.status == 'completed')) {
      print('✅ Both semi-finals completed. Creating final match...');

      // Get winners from semi-finals
      final winner1 = matches[0].winnerId;
      final winner2 = matches[1].winnerId;

      if (winner1 == null || winner2 == null) {
        throw Exception('Semi-final winners not found');
      }

      // Get player info for winners
      PlayerInfo player1Info;
      PlayerInfo player2Info;

      if (matches[0].player1.userId == winner1) {
        player1Info = matches[0].player1;
      } else {
        player1Info = matches[0].player2!;
      }

      if (matches[1].player1.userId == winner2) {
        player2Info = matches[1].player1;
      } else {
        player2Info = matches[1].player2!;
      }

      // Create final match
      final finalMatchRef = _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .doc('final');

      transaction.set(
        finalMatchRef,
        MatchModel(
          matchId: 'final',
          round: 2,
          matchNumber: 1,
          player1: player1Info,
          player2: player2Info,
          status: 'pending',
        ).toMap(),
      );

      // Update tournament to round 2
      transaction.update(tournamentRef, {'currentRound': 2});

      print(
        '🎮 FINAL MATCH CREATED: ${player1Info.username} vs ${player2Info.username}',
      );
    }
  }
}
