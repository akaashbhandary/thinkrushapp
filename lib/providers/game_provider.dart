import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/audio/sound_service.dart';
import '../core/constants/app_constants.dart';
import '../models/game_question.dart';
import '../models/game_result.dart';
import '../models/game_session.dart';
import '../models/match_model.dart';
import '../services/ai/ai_opponent_service.dart';
import '../services/firebase/firebase_config.dart';
import '../services/game/game_generator.dart';
import '../services/game/game_timer_service.dart';
import '../services/game/logic_grid_generator.dart';
import '../services/game/math_rush_generator.dart';
import '../services/game/memory_flash_generator.dart';
import '../services/game/pattern_finder_generator.dart';
import '../services/game/scoring_service.dart';
import '../services/game/word_rush_generator.dart';

class GameProvider extends ChangeNotifier {
  final ScoringService _scoringService = const ScoringService();
  GameTimerService? _timer;
  AiOpponentService? _aiService;
  StreamSubscription<DocumentSnapshot>? _matchSubscription;

  GameModeType _mode = GameModeType.mathRush;
  GamePlayType _playType = GamePlayType.singlePlayer;
  AiDifficulty _difficulty = AiDifficulty.medium;

  String? _matchId;
  int? _seed;
  bool _isHost = true;
  Random? _gameRandom;

  GameQuestion? _currentQuestion;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _difficultyLevel = 1;
  int _maxDifficultyReached = 1;

  int _opponentScore = 0;
  int _opponentStreak = 0;
  String _opponentName = 'Opponent';
  int _opponentAvatar = 0;

  bool _isFlashPhase = false;
  Timer? _flashTimer;

  bool _isGameOver = false;
  int? _selectedOptionIndex;
  bool? _isAnswerCorrect;
  bool _showPenaltyNotice = false;
  DateTime _questionStartTime = DateTime.now();

  GameResult? _gameResult;

  // Getters
  GameModeType get mode => _mode;
  GamePlayType get playType => _playType;
  AiDifficulty get difficulty => _difficulty;
  GameQuestion? get currentQuestion => _currentQuestion;
  int get score => _score;
  int get streak => _streak;
  int get bestStreak => _bestStreak;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  int get difficultyLevel => _difficultyLevel;
  int get secondsLeft => _timer?.secondsLeft ?? AppConstants.roundDurationSeconds;
  double get timerProgress => _timer?.progress ?? 1.0;
  bool get isGameOver => _isGameOver;
  bool get isFlashPhase => _isFlashPhase;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool? get isAnswerCorrect => _isAnswerCorrect;
  bool get showPenaltyNotice => _showPenaltyNotice;
  GameResult? get gameResult => _gameResult;

  int get opponentScore => _opponentScore;
  int get opponentStreak => _opponentStreak;
  String get opponentName => _opponentName;
  int get opponentAvatar => _opponentAvatar;
  String? get matchId => _matchId;
  int? get seed => _seed;
  bool get isHost => _isHost;

  GameGenerator _getGenerator() {
    final rnd = _gameRandom ?? Random();
    switch (_mode) {
      case GameModeType.mathRush:
        return MathRushGenerator(rnd);
      case GameModeType.patternFinder:
        return PatternFinderGenerator(rnd);
      case GameModeType.memoryFlash:
        return MemoryFlashGenerator(rnd);
      case GameModeType.logicGrid:
        return LogicGridGenerator(rnd);
      case GameModeType.wordRush:
        return WordRushGenerator(rnd);
    }
  }

  void startGame({
    required GameModeType mode,
    required GamePlayType playType,
    AiDifficulty difficulty = AiDifficulty.medium,
    MatchPlayer? opponentPlayer,
    String? matchId,
    int? seed,
    bool isHost = true,
  }) {
    _mode = mode;
    _playType = playType;
    _difficulty = difficulty;
    _matchId = matchId;
    _seed = seed;
    _isHost = isHost;

    // Deterministic random seed ensures identical questions for both devices
    _gameRandom = seed != null ? Random(seed) : Random();

    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _difficultyLevel = 1;
    _maxDifficultyReached = 1;
    _isGameOver = false;
    _selectedOptionIndex = null;
    _isAnswerCorrect = null;
    _showPenaltyNotice = false;
    _gameResult = null;

    if (playType == GamePlayType.vsAi) {
      _aiService?.dispose();
      _aiService = AiOpponentService(
        difficulty: difficulty,
        onStateChanged: (state) {
          if (!_isGameOver) {
            _opponentScore = state.score;
            _opponentStreak = state.streak;
            notifyListeners();
          }
        },
      );
      _opponentName = _aiService!.state.name;
      _opponentAvatar = _aiService!.state.avatarIndex;
      _opponentScore = 0;
      _opponentStreak = 0;
      _aiService!.startRound();
    } else if (playType == GamePlayType.multiplayer) {
      if (opponentPlayer != null) {
        _opponentName = opponentPlayer.name;
        _opponentAvatar = opponentPlayer.avatarIndex;
      }
      _opponentScore = 0;
      _opponentStreak = 0;

      // Subscribe to real-time live score updates from Cloud Firestore
      if (_matchId != null &&
          FirebaseConfig.isFirebaseAvailable &&
          !_matchId!.startsWith('sim_')) {
        _matchSubscription?.cancel();
        _matchSubscription = FirebaseFirestore.instance
            .collection('matches')
            .doc(_matchId)
            .snapshots()
            .listen((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return;
          final matchData = snapshot.data()!;
          final oppData = _isHost ? matchData['player2'] : matchData['player1'];
          if (oppData != null && oppData is Map<String, dynamic>) {
            _opponentScore = (oppData['score'] as num?)?.toInt() ?? _opponentScore;
            _opponentStreak = (oppData['streak'] as num?)?.toInt() ?? _opponentStreak;
            notifyListeners();
          }
        });
      }
    }

    _timer?.dispose();
    _timer = GameTimerService(
      initialSeconds: AppConstants.roundDurationSeconds,
      onTick: (seconds) {
        notifyListeners();
      },
      onTimeUp: () {
        endGame();
      },
    );
    _timer!.start();

    _nextQuestion();
    notifyListeners();
  }

  void _nextQuestion() {
    _selectedOptionIndex = null;
    _isAnswerCorrect = null;
    _showPenaltyNotice = false;

    final generator = _getGenerator();
    _currentQuestion = generator.generateNextQuestion(difficultyLevel: _difficultyLevel);
    _questionStartTime = DateTime.now();

    if (_mode == GameModeType.memoryFlash && _currentQuestion?.flashItems != null) {
      _startMemoryFlashPhase();
    }

    if (_playType == GamePlayType.vsAi && _aiService != null && _currentQuestion != null) {
      _aiService!.processQuestion(_currentQuestion!);
    }

    notifyListeners();
  }

  void _startMemoryFlashPhase() {
    _isFlashPhase = true;
    _flashTimer?.cancel();

    _flashTimer = Timer(const Duration(milliseconds: 2200), () {
      _isFlashPhase = false;
      _questionStartTime = DateTime.now();
      notifyListeners();
    });
  }

  void submitAnswer(int optionIndex) {
    if (_isGameOver || _isFlashPhase || _selectedOptionIndex != null || _currentQuestion == null) return;

    _selectedOptionIndex = optionIndex;
    final isCorrect = _currentQuestion!.checkAnswer(optionIndex);
    _isAnswerCorrect = isCorrect;

    final responseSeconds = DateTime.now().difference(_questionStartTime).inMilliseconds / 1000.0;

    if (isCorrect) {
      SoundService.playCorrect();
      _correctAnswers++;
      final scoreRes = _scoringService.calculateCorrect(
        currentScore: _score,
        currentStreak: _streak,
        responseTimeSeconds: responseSeconds,
      );
      _score = scoreRes.newTotalScore;
      _streak = scoreRes.newStreak;
      if (_streak > _bestStreak) _bestStreak = _streak;

      // Adaptive difficulty: level up every 3 consecutive streak
      if (_streak > 0 && _streak % 3 == 0 && _difficultyLevel < AppConstants.maxDifficultyLevel) {
        _difficultyLevel++;
        if (_difficultyLevel > _maxDifficultyReached) {
          _maxDifficultyReached = _difficultyLevel;
        }
      }
    } else {
      SoundService.playWrong();
      _wrongAnswers++;
      _streak = 0;
      _showPenaltyNotice = true;

      // Penalize timer by -3 seconds
      _timer?.applyPenalty(AppConstants.wrongPenaltySeconds);

      // Reset level slightly on error
      if (_difficultyLevel > AppConstants.minDifficultyLevel) {
        _difficultyLevel--;
      }
    }

    notifyListeners();

    // Sync live score to Cloud Firestore
    if (_playType == GamePlayType.multiplayer &&
        _matchId != null &&
        FirebaseConfig.isFirebaseAvailable &&
        !_matchId!.startsWith('sim_')) {
      final fieldPrefix = _isHost ? 'player1' : 'player2';
      FirebaseFirestore.instance.collection('matches').doc(_matchId).update({
        '$fieldPrefix.score': _score,
        '$fieldPrefix.streak': _streak,
      }).catchError((e) {
        debugPrint('[GameProvider] Live score broadcast error: $e');
      });
    } else if (_playType == GamePlayType.multiplayer && !_isGameOver) {
      // Offline fallback: simulated progression
      if (isCorrect) {
        _opponentScore += (80 + (_score % 40));
      }
    }

    // Delay briefly to show option feedback, then transition to next question
    Timer(const Duration(milliseconds: 650), () {
      if (!_isGameOver) {
        _nextQuestion();
      }
    });
  }

  void endGame() {
    if (_isGameOver) return;
    _isGameOver = true;
    _timer?.pause();
    _flashTimer?.cancel();
    _aiService?.dispose();

    // Broadcast final score and finish state to Firestore
    if (_playType == GamePlayType.multiplayer &&
        _matchId != null &&
        FirebaseConfig.isFirebaseAvailable &&
        !_matchId!.startsWith('sim_')) {
      final fieldPrefix = _isHost ? 'player1' : 'player2';
      FirebaseFirestore.instance.collection('matches').doc(_matchId).update({
        '$fieldPrefix.score': _score,
        '$fieldPrefix.streak': _streak,
        '$fieldPrefix.hasFinished': true,
      }).catchError((_) {});
    }

    final totalAnswers = _correctAnswers + _wrongAnswers;
    final accuracy = totalAnswers > 0
        ? double.parse(((_correctAnswers / totalAnswers) * 100).toStringAsFixed(1))
        : 0.0;

    final isMultiplayerOrAi = _playType == GamePlayType.multiplayer || _playType == GamePlayType.vsAi;
    final isWin = isMultiplayerOrAi ? _score > _opponentScore : null;
    final isDraw = isMultiplayerOrAi ? _score == _opponentScore : null;

    final baseCoins = (_score / 20).round();
    final winBonusCoins = isWin == true ? 50 : 0;
    final earnedCoins = baseCoins + winBonusCoins;

    final baseExp = (_score / 10).round();
    final winBonusExp = isWin == true ? 100 : 0;
    final earnedXp = baseExp + winBonusExp;

    _gameResult = GameResult(
      gameMode: _mode,
      playType: _playType,
      finalScore: _score,
      questionsAnswered: totalAnswers,
      correctAnswers: _correctAnswers,
      bestStreak: _bestStreak,
      accuracy: accuracy,
      timeTakenSeconds: AppConstants.roundDurationSeconds - (_timer?.secondsLeft ?? 0),
      xpEarned: earnedXp,
      coinsEarned: earnedCoins,
      maxDifficultyReached: _maxDifficultyReached,
      opponentScore: isMultiplayerOrAi ? _opponentScore : null,
      opponentName: isMultiplayerOrAi ? _opponentName : null,
      isWin: isWin,
      isDraw: isDraw,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.dispose();
    _flashTimer?.cancel();
    _aiService?.dispose();
    _matchSubscription?.cancel();
    super.dispose();
  }
}
