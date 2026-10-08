import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/game_question.dart';
import '../../models/game_session.dart';
import '../game/scoring_service.dart';

class AiOpponentState {
  final String name;
  final int avatarIndex;
  final int score;
  final int streak;
  final int bestStreak;
  final int questionsAnswered;
  final int correctAnswers;
  final bool isThinking;
  final bool? lastAnswerCorrect;

  const AiOpponentState({
    required this.name,
    this.avatarIndex = 1,
    this.score = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.isThinking = false,
    this.lastAnswerCorrect,
  });

  double get accuracy =>
      questionsAnswered == 0 ? 0.0 : (correctAnswers / questionsAnswered) * 100.0;

  AiOpponentState copyWith({
    String? name,
    int? avatarIndex,
    int? score,
    int? streak,
    int? bestStreak,
    int? questionsAnswered,
    int? correctAnswers,
    bool? isThinking,
    bool? lastAnswerCorrect,
  }) {
    return AiOpponentState(
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isThinking: isThinking ?? this.isThinking,
      lastAnswerCorrect: lastAnswerCorrect,
    );
  }
}

class AiOpponentService {
  final AiDifficulty difficulty;
  final ScoringService _scoringService;
  final Random _random;
  final ValueChanged<AiOpponentState>? onStateChanged;

  Timer? _thinkTimer;
  AiOpponentState _state;
  bool _isDisposed = false;

  static const List<String> aiNames = [
    'CyberBot', 'NovaBrain', 'QuantumX', 'PixelPulse', 'ApexMind', 'Synapse'
  ];

  AiOpponentService({
    required this.difficulty,
    ScoringService? scoringService,
    Random? random,
    this.onStateChanged,
  })  : _scoringService = scoringService ?? const ScoringService(),
        _random = random ?? Random(),
        _state = AiOpponentState(
          name: aiNames[Random().nextInt(aiNames.length)],
          avatarIndex: Random().nextInt(5) + 1,
        );

  AiOpponentState get state => _state;

  void startRound() {
    _state = _state.copyWith(
      score: 0,
      streak: 0,
      bestStreak: 0,
      questionsAnswered: 0,
      correctAnswers: 0,
      isThinking: false,
    );
    onStateChanged?.call(_state);
  }

  void processQuestion(GameQuestion question) {
    if (_isDisposed) return;
    _thinkTimer?.cancel();

    _state = _state.copyWith(isThinking: true);
    onStateChanged?.call(_state);

    final delay = _calculateResponseDelay();

    _thinkTimer = Timer(Duration(milliseconds: (delay * 1000).toInt()), () {
      if (_isDisposed) return;

      final isCorrect = _determineAccuracy();
      final newTotalQuestions = _state.questionsAnswered + 1;

      if (isCorrect) {
        final scoreCalc = _scoringService.calculateCorrect(
          currentScore: _state.score,
          currentStreak: _state.streak,
          responseTimeSeconds: delay,
        );
        final nextStreak = scoreCalc.newStreak;
        final bestStreak = max(_state.bestStreak, nextStreak);

        _state = _state.copyWith(
          score: scoreCalc.newTotalScore,
          streak: nextStreak,
          bestStreak: bestStreak,
          questionsAnswered: newTotalQuestions,
          correctAnswers: _state.correctAnswers + 1,
          isThinking: false,
          lastAnswerCorrect: true,
        );
      } else {
        final scoreCalc = _scoringService.calculateWrong(currentScore: _state.score);
        _state = _state.copyWith(
          score: scoreCalc.newTotalScore,
          streak: 0,
          questionsAnswered: newTotalQuestions,
          isThinking: false,
          lastAnswerCorrect: false,
        );
      }

      onStateChanged?.call(_state);
    });
  }

  double _calculateResponseDelay() {
    switch (difficulty) {
      case AiDifficulty.easy: return 2.5 + (_random.nextDouble() * 1.5);
      case AiDifficulty.medium: return 1.5 + (_random.nextDouble() * 1.2);
      case AiDifficulty.hard: return 0.8 + (_random.nextDouble() * 0.8);
    }
  }

  bool _determineAccuracy() {
    final roll = _random.nextDouble();
    switch (difficulty) {
      case AiDifficulty.easy: return roll < 0.75;
      case AiDifficulty.medium: return roll < 0.85;
      case AiDifficulty.hard: return roll < 0.94;
    }
  }

  void stop() {
    _thinkTimer?.cancel();
    _thinkTimer = null;
  }

  void dispose() {
    _isDisposed = true;
    _thinkTimer?.cancel();
    _thinkTimer = null;
  }
}
