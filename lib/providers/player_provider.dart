import 'package:flutter/material.dart';
import '../models/game_result.dart';
import '../models/user_profile.dart';
import '../services/player/player_service.dart';

class PlayerProvider extends ChangeNotifier {
  final PlayerService _playerService = PlayerService();

  UserProfile? get profile => _playerService.profile;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String userId, {String? defaultName, String? defaultEmail}) async {
    _isLoading = true;
    notifyListeners();

    await _playerService.loadProfile(
      userId,
      defaultName: defaultName,
      defaultEmail: defaultEmail,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUsername(String newName) async {
    await _playerService.updateUsername(newName);
    notifyListeners();
  }

  Future<void> updateAvatar(int avatarIndex) async {
    await _playerService.updateAvatar(avatarIndex);
    notifyListeners();
  }

  Future<void> recordGameResult(GameResult result) async {
    await _playerService.recordGameResult(result);
    notifyListeners();
  }

  Future<void> addRewards({int xp = 0, int coins = 0}) async {
    await _playerService.addRewards(xp: xp, coins: coins);
    notifyListeners();
  }
}
