import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/game_result.dart';
import '../../models/user_profile.dart';
import '../firebase/firebase_config.dart';

class PlayerService {
  static const String _userProfileKey = 'think_rush_current_user';
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<UserProfile> loadProfile(String userId, {String? defaultName, String? defaultEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_userProfileKey);

    if (cached != null) {
      try {
        _profile = UserProfile.fromJson(jsonDecode(cached));
        return _profile!;
      } catch (e) {
        debugPrint('[PlayerService] Failed to parse cached profile: $e');
      }
    }

    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          _profile = UserProfile.fromJson(doc.data()!);
          await _saveProfileLocally(_profile!);
          return _profile!;
        }
      } catch (e) {
        debugPrint('[PlayerService] Firestore fetch error: $e');
      }
    }

    _profile = UserProfile.initial(
      id: userId,
      email: defaultEmail ?? 'player@thinkrush.com',
      displayName: defaultName ?? 'Player',
    );
    await _saveProfileLocally(_profile!);
    return _profile!;
  }

  Future<UserProfile> updateUsername(String newName) async {
    if (_profile == null) throw Exception('Profile not loaded');
    _profile = _profile!.copyWith(
      displayName: newName.trim(),
      updatedAt: DateTime.now(),
    );
    await _saveProfileLocally(_profile!);
    await _syncToFirestore(_profile!);
    return _profile!;
  }

  Future<UserProfile> updateAvatar(int avatarIndex) async {
    if (_profile == null) throw Exception('Profile not loaded');
    _profile = _profile!.copyWith(
      avatarIndex: avatarIndex,
      updatedAt: DateTime.now(),
    );
    await _saveProfileLocally(_profile!);
    await _syncToFirestore(_profile!);
    return _profile!;
  }

  Future<UserProfile> recordGameResult(GameResult result) async {
    if (_profile == null) throw Exception('Profile not loaded');

    final newGamesPlayed = _profile!.gamesPlayed + 1;
    final isWin = result.isWin == true;
    final isLoss = result.isWin == false && (result.isDraw == false || result.isDraw == null);

    final newWins = isWin ? _profile!.wins + 1 : _profile!.wins;
    final newLosses = isLoss ? _profile!.losses + 1 : _profile!.losses;
    final newBestScore = max(_profile!.bestScore, result.finalScore);
    final newBestStreak = max(_profile!.bestStreak, result.bestStreak);

    final newAccuracy = _profile!.gamesPlayed == 0
        ? result.accuracy
        : ((_profile!.accuracy * _profile!.gamesPlayed) + result.accuracy) / newGamesPlayed;

    final newXp = _profile!.xp + result.xpEarned;
    final newCoins = _profile!.coins + result.coinsEarned;
    final newLevel = max(1, (newXp / 300).floor() + 1);

    _profile = _profile!.copyWith(
      gamesPlayed: newGamesPlayed,
      wins: newWins,
      losses: newLosses,
      bestScore: newBestScore,
      bestStreak: newBestStreak,
      accuracy: double.parse(newAccuracy.toStringAsFixed(1)),
      xp: newXp,
      level: newLevel,
      coins: newCoins,
      updatedAt: DateTime.now(),
    );

    await _saveProfileLocally(_profile!);
    await _syncToFirestore(_profile!);
    return _profile!;
  }

  Future<void> addRewards({int xp = 0, int coins = 0}) async {
    if (_profile == null) return;
    final newXp = _profile!.xp + xp;
    final newCoins = _profile!.coins + coins;
    final newLevel = max(1, (newXp / 300).floor() + 1);

    _profile = _profile!.copyWith(
      xp: newXp,
      coins: newCoins,
      level: newLevel,
      updatedAt: DateTime.now(),
    );
    await _saveProfileLocally(_profile!);
    await _syncToFirestore(_profile!);
  }

  Future<void> _saveProfileLocally(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<void> _syncToFirestore(UserProfile profile) async {
    if (!FirebaseConfig.isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[PlayerService] Firestore sync error: $e');
    }
  }
}
