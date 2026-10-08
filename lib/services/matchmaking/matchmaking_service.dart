import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/game_session.dart';
import '../../models/match_model.dart';
import '../../models/user_profile.dart';
import '../firebase/firebase_config.dart';

class MatchmakingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Random _rnd = Random();

  bool _isSearching = false;
  String? _activeMatchId;
  bool _isHost = false;
  StreamSubscription<DocumentSnapshot>? _activeMatchSubscription;
  Completer<MatchModel?>? _matchCompleter;

  final List<String> _simulatedOpponentNames = [
    'NovaMind', 'CipherKing', 'ApexLogic', 'HyperSynapse',
    'PixelHero', 'QuantumDrift', 'Aura_IQ', 'BrainStormer',
    'ShadowRider', 'SpeedySam', 'ZenithMind', 'CosmicPulse'
  ];

  bool get isSearching => _isSearching;
  bool get isHost => _isHost;
  String? get activeMatchId => _activeMatchId;

  Stream<MatchModel>? streamMatch(String matchId) {
    if (!FirebaseConfig.isFirebaseAvailable) return null;
    return _firestore.collection('matches').doc(matchId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        throw Exception('Match session was closed');
      }
      return MatchModel.fromJson(snap.data()!);
    });
  }

  Future<MatchModel?> findMatch({
    required GameModeType mode,
    required UserProfile player,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    _isSearching = true;
    _activeMatchId = null;
    _isHost = false;

    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        final match = await _findOrCreateCloudMatch(mode, player, timeout);
        if (match != null) {
          _isSearching = false;
          return match;
        }
      } catch (e) {
        debugPrint('[MatchmakingService] Cloud matchmaking error: $e');
      }
    }

    // Fallback: If Firebase is not configured or no online opponent joined within timeout
    return _createSimulatedMatch(mode, player);
  }

  Future<MatchModel?> _findOrCreateCloudMatch(
    GameModeType mode,
    UserProfile player,
    Duration timeout,
  ) async {
    final now = DateTime.now();

    // 1. Look for existing open rooms for this game mode
    final openMatchesQuery = await _firestore
        .collection('matches')
        .where('gameMode', isEqualTo: mode.index)
        .where('status', isEqualTo: MatchStatus.waiting.index)
        .where('roomCode', isNull: true)
        .limit(10)
        .get();

    for (final doc in openMatchesQuery.docs) {
      final data = doc.data();
      final p1Data = data['player1'] as Map<String, dynamic>?;
      final p1Id = p1Data?['id'] as String?;
      final createdAtStr = data['createdAt'] as String?;
      final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;

      // Ensure not matching with self and match was created recently (< 45s)
      if (p1Id != player.id &&
          createdAt != null &&
          now.difference(createdAt).inSeconds < 45) {
        final p2 = MatchPlayer(
          id: player.id,
          name: player.displayName,
          avatarIndex: player.avatarIndex,
        );

        try {
          await doc.reference.update({
            'player2': p2.toJson(),
            'status': MatchStatus.countdown.index,
          });

          _activeMatchId = doc.id;
          _isHost = false;

          final updatedDoc = await doc.reference.get();
          if (updatedDoc.exists && updatedDoc.data() != null) {
            return MatchModel.fromJson(updatedDoc.data()!);
          }
        } catch (e) {
          debugPrint('[MatchmakingService] Race condition joining match: $e');
          // Someone else might have joined, continue searching
        }
      }
    }

    if (!_isSearching) return null;

    // 2. No open room found: Create a new room as host (player1)
    final matchId = 'match_${DateTime.now().millisecondsSinceEpoch}_${_rnd.nextInt(9999)}';
    final seed = _rnd.nextInt(1000000);

    final p1 = MatchPlayer(
      id: player.id,
      name: player.displayName,
      avatarIndex: player.avatarIndex,
    );

    final newMatch = MatchModel(
      matchId: matchId,
      gameMode: mode,
      status: MatchStatus.waiting,
      player1: p1,
      player2: null,
      seed: seed,
      createdAt: DateTime.now(),
    );

    final docRef = _firestore.collection('matches').doc(matchId);
    await docRef.set(newMatch.toJson());
    _activeMatchId = matchId;
    _isHost = true;

    // 3. Listen for player2 to join
    _matchCompleter = Completer<MatchModel?>();
    _activeMatchSubscription = docRef.snapshots().listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;
      final matchData = snapshot.data()!;
      final statusIndex = matchData['status'] as int?;

      if (statusIndex == MatchStatus.countdown.index && matchData['player2'] != null) {
        _activeMatchSubscription?.cancel();
        if (_matchCompleter != null && !_matchCompleter!.isCompleted) {
          _matchCompleter!.complete(MatchModel.fromJson(matchData));
        }
      }
    });

    // Wait until opponent joins or timeout expires
    Timer(timeout, () {
      if (_matchCompleter != null && !_matchCompleter!.isCompleted) {
        _matchCompleter!.complete(null); // Triggers fallback to simulated player
        docRef.update({'status': MatchStatus.cancelled.index}).catchError((_) {});
      }
    });

    return _matchCompleter!.future;
  }

  Future<MatchModel?> _createSimulatedMatch(GameModeType mode, UserProfile player) async {
    final delayMs = 1500 + _rnd.nextInt(1500);
    await Future.delayed(Duration(milliseconds: delayMs));

    if (!_isSearching) return null;

    final opponentName = _simulatedOpponentNames[_rnd.nextInt(_simulatedOpponentNames.length)];
    final opponentAvatar = _rnd.nextInt(6);
    final matchId = 'sim_match_${DateTime.now().millisecondsSinceEpoch}_${_rnd.nextInt(9999)}';

    final p1 = MatchPlayer(
      id: player.id,
      name: player.displayName,
      avatarIndex: player.avatarIndex,
    );

    final p2 = MatchPlayer(
      id: 'opp_${_rnd.nextInt(99999)}',
      name: opponentName,
      avatarIndex: opponentAvatar,
    );

    _isSearching = false;
    _isHost = true;

    return MatchModel(
      matchId: matchId,
      gameMode: mode,
      status: MatchStatus.countdown,
      player1: p1,
      player2: p2,
      seed: _rnd.nextInt(1000000),
      createdAt: DateTime.now(),
    );
  }

  Stream<MatchModel?> streamCustomRoom(String roomCode) {
    if (!FirebaseConfig.isFirebaseAvailable) {
      return Stream.value(null);
    }
    final matchId = 'room_${roomCode.trim()}';
    return _firestore.collection('matches').doc(matchId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return MatchModel.fromJson(snap.data()!);
    });
  }

  Future<String> createCustomRoomDocument({
    required GameModeType mode,
    required UserProfile player,
    required String roomCode,
  }) async {
    if (!FirebaseConfig.isFirebaseAvailable) {
      throw Exception('Cloud services are offline. Please check your internet connection.');
    }

    final cleanCode = roomCode.trim();
    final matchId = 'room_$cleanCode';
    final seed = _rnd.nextInt(1000000);

    final p1 = MatchPlayer(
      id: player.id,
      name: player.displayName,
      avatarIndex: player.avatarIndex,
    );

    final newMatch = MatchModel(
      matchId: matchId,
      gameMode: mode,
      status: MatchStatus.waiting,
      player1: p1,
      player2: null,
      seed: seed,
      createdAt: DateTime.now(),
      roomCode: cleanCode,
    );

    final docRef = _firestore.collection('matches').doc(matchId);
    await docRef.set(newMatch.toJson());
    _activeMatchId = matchId;
    _isHost = true;

    return matchId;
  }

  Future<MatchModel?> createCustomRoom({
    required GameModeType mode,
    required UserProfile player,
    required String roomCode,
  }) async {
    if (!FirebaseConfig.isFirebaseAvailable) return null;

    final matchId = await createCustomRoomDocument(
      mode: mode,
      player: player,
      roomCode: roomCode,
    );

    final docRef = _firestore.collection('matches').doc(matchId);
    _matchCompleter = Completer<MatchModel?>();
    _activeMatchSubscription = docRef.snapshots().listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;
      final matchData = snapshot.data()!;
      final statusIndex = matchData['status'] as int?;

      if (statusIndex == MatchStatus.countdown.index && matchData['player2'] != null) {
        _activeMatchSubscription?.cancel();
        if (_matchCompleter != null && !_matchCompleter!.isCompleted) {
          _matchCompleter!.complete(MatchModel.fromJson(matchData));
        }
      }
    });

    return _matchCompleter!.future;
  }

  Future<MatchModel> joinCustomRoom({
    required String roomCode,
    required UserProfile player,
  }) async {
    if (!FirebaseConfig.isFirebaseAvailable) {
      throw Exception('Cloud services are offline. Please check your internet connection.');
    }

    final cleanCode = roomCode.trim();
    final matchId = 'room_$cleanCode';
    final docRef = _firestore.collection('matches').doc(matchId);
    final doc = await docRef.get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Room code $cleanCode not found. Please verify with the host.');
    }

    final match = MatchModel.fromJson(doc.data()!);
    if (match.status != MatchStatus.waiting) {
      throw Exception('Room is already full or battle in progress.');
    }

    // Ensure distinct ID if 2 phones are testing with the same user profile
    final p2Id = (player.id == match.player1.id) ? '${player.id}_p2' : player.id;
    final p2Name = (player.id == match.player1.id && player.displayName == match.player1.name)
        ? '${player.displayName} (2)'
        : player.displayName;

    final p2 = MatchPlayer(
      id: p2Id,
      name: p2Name,
      avatarIndex: (player.avatarIndex == match.player1.avatarIndex)
          ? (player.avatarIndex + 1) % 6
          : player.avatarIndex,
    );

    await docRef.update({
      'player2': p2.toJson(),
      'status': MatchStatus.countdown.index,
    });

    _activeMatchId = matchId;
    _isHost = false;

    return match.copyWith(
      player2: p2,
      status: MatchStatus.countdown,
    );
  }

  Future<void> cancelCustomRoom(String roomCode) async {
    final cleanCode = roomCode.trim();
    final matchId = 'room_$cleanCode';
    _activeMatchSubscription?.cancel();
    _activeMatchSubscription = null;
    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        await _firestore.collection('matches').doc(matchId).update({
          'status': MatchStatus.cancelled.index,
        });
      } catch (_) {}
    }
    if (_activeMatchId == matchId) {
      _activeMatchId = null;
    }
    _isSearching = false;
  }

  Future<void> updatePlayerScore({
    required String matchId,
    required bool isHost,
    required int score,
    required int streak,
    bool hasFinished = false,
  }) async {
    if (!FirebaseConfig.isFirebaseAvailable || matchId.startsWith('sim_')) return;

    try {
      final docRef = _firestore.collection('matches').doc(matchId);
      final fieldPrefix = isHost ? 'player1' : 'player2';

      await docRef.update({
        '$fieldPrefix.score': score,
        '$fieldPrefix.streak': streak,
        if (hasFinished) '$fieldPrefix.hasFinished': true,
      });
    } catch (e) {
      debugPrint('[MatchmakingService] Score update error: $e');
    }
  }

  void cancelMatchmaking() {
    _isSearching = false;
    _activeMatchSubscription?.cancel();
    if (_activeMatchId != null && _isHost && FirebaseConfig.isFirebaseAvailable) {
      _firestore.collection('matches').doc(_activeMatchId).update({
        'status': MatchStatus.cancelled.index,
      }).catchError((_) {});
    }
    if (_matchCompleter != null && !_matchCompleter!.isCompleted) {
      _matchCompleter!.complete(null);
    }
  }
}
