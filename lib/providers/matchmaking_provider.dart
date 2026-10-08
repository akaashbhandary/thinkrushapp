import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_session.dart';
import '../models/match_model.dart';
import '../models/user_profile.dart';
import '../services/matchmaking/matchmaking_service.dart';

enum MatchmakingState { idle, searching, matchFound, countdown, cancelled }

class MatchmakingProvider extends ChangeNotifier {
  final MatchmakingService _service = MatchmakingService();

  MatchmakingState _state = MatchmakingState.idle;
  MatchModel? _currentMatch;
  int _countdownSeconds = 3;
  Timer? _countdownTimer;

  MatchmakingState get state => _state;
  MatchModel? get currentMatch => _currentMatch;
  int get countdownSeconds => _countdownSeconds;
  bool get isHost => _service.isHost;

  MatchPlayer? getOpponent(String currentPlayerId) {
    if (_currentMatch == null) return null;
    return _currentMatch!.player1.id == currentPlayerId
        ? _currentMatch!.player2
        : _currentMatch!.player1;
  }

  Future<void> startMatchmaking({
    required GameModeType mode,
    required UserProfile player,
    required VoidCallback onGameReady,
  }) async {
    _state = MatchmakingState.searching;
    _currentMatch = null;
    _countdownSeconds = 3;
    notifyListeners();

    final match = await _service.findMatch(mode: mode, player: player);

    if (_state != MatchmakingState.searching) return; // Cancelled

    if (match != null) {
      _currentMatch = match;
      _state = MatchmakingState.matchFound;
      notifyListeners();

      // Trigger synchronized 3..2..1 countdown
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
          notifyListeners();
        } else {
          timer.cancel();
          _state = MatchmakingState.countdown;
          notifyListeners();
          onGameReady();
        }
      });
    } else {
      _state = MatchmakingState.idle;
      notifyListeners();
    }
  }

  String? _lastError;
  String? get lastError => _lastError;

  Stream<MatchModel?> streamCustomRoom(String roomCode) =>
      _service.streamCustomRoom(roomCode);

  Future<String> createCustomRoomDocument({
    required GameModeType mode,
    required UserProfile player,
    required String roomCode,
  }) async {
    _currentMatch = null;
    _lastError = null;
    _countdownSeconds = 3;
    _state = MatchmakingState.searching;
    notifyListeners();
    return await _service.createCustomRoomDocument(
      mode: mode,
      player: player,
      roomCode: roomCode,
    );
  }

  void startHostCountdown({
    required MatchModel match,
    required VoidCallback onGameReady,
  }) {
    if (_state == MatchmakingState.matchFound || _state == MatchmakingState.countdown) return;
    _currentMatch = match;
    _state = MatchmakingState.matchFound;
    _countdownSeconds = 3;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        _countdownSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _state = MatchmakingState.countdown;
        notifyListeners();
        onGameReady();
      }
    });
  }

  Future<void> cancelCustomRoom(String roomCode) async {
    _countdownTimer?.cancel();
    await _service.cancelCustomRoom(roomCode);
    _state = MatchmakingState.idle;
    _currentMatch = null;
    notifyListeners();
  }

  Future<bool> createRoom({
    required GameModeType mode,
    required UserProfile player,
    required String roomCode,
    required VoidCallback onGameReady,
  }) async {
    _state = MatchmakingState.searching;
    _currentMatch = null;
    _countdownSeconds = 3;
    notifyListeners();

    try {
      final match = await _service.createCustomRoom(
        mode: mode,
        player: player,
        roomCode: roomCode,
      );

      if (_state != MatchmakingState.searching) return false;

      if (match != null) {
        _currentMatch = match;
        _state = MatchmakingState.matchFound;
        notifyListeners();

        _countdownTimer?.cancel();
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_countdownSeconds > 1) {
            _countdownSeconds--;
            notifyListeners();
          } else {
            timer.cancel();
            _state = MatchmakingState.countdown;
            notifyListeners();
            onGameReady();
          }
        });
        return true;
      }
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    }

    _state = MatchmakingState.idle;
    notifyListeners();
    return false;
  }

  Future<bool> joinRoom({
    required String roomCode,
    required UserProfile player,
    required VoidCallback onGameReady,
  }) async {
    _state = MatchmakingState.searching;
    _currentMatch = null;
    _lastError = null;
    _countdownSeconds = 3;
    notifyListeners();

    try {
      final match = await _service.joinCustomRoom(
        roomCode: roomCode,
        player: player,
      );

      _currentMatch = match;
      _state = MatchmakingState.matchFound;
      notifyListeners();

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdownSeconds > 1) {
          _countdownSeconds--;
          notifyListeners();
        } else {
          timer.cancel();
          _state = MatchmakingState.countdown;
          notifyListeners();
          onGameReady();
        }
      });
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      _state = MatchmakingState.idle;
      notifyListeners();
      return false;
    }
  }

  void cancelMatchmaking() {
    _service.cancelMatchmaking();
    _countdownTimer?.cancel();
    _state = MatchmakingState.cancelled;
    _currentMatch = null;
    notifyListeners();
  }

  void reset() {
    _countdownTimer?.cancel();
    _state = MatchmakingState.idle;
    _currentMatch = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
