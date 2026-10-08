import '../../core/constants/app_constants.dart';

class ScoreResult {
  final int pointsAdded;
  final int basePoints;
  final int streakBonus;
  final int speedBonus;
  final int newStreak;
  final int newTotalScore;

  const ScoreResult({
    required this.pointsAdded,
    required this.basePoints,
    required this.streakBonus,
    required this.speedBonus,
    required this.newStreak,
    required this.newTotalScore,
  });
}

class ScoringService {
  final int baseScore;
  final int streakMultiplier;

  const ScoringService({
    this.baseScore = AppConstants.baseScore,
    this.streakMultiplier = AppConstants.streakMultiplier,
  });

  ScoreResult calculateCorrect({
    required int currentScore,
    required int currentStreak,
    required double responseTimeSeconds,
  }) {
    final nextStreak = currentStreak + 1;
    final streakBonus = (nextStreak - 1) * streakMultiplier;

    int speedBonus = 0;
    if (responseTimeSeconds < 1.5) {
      speedBonus = 50;
    } else if (responseTimeSeconds < 2.5) {
      speedBonus = 30;
    } else if (responseTimeSeconds < 4.0) {
      speedBonus = 15;
    }

    final totalAdded = baseScore + streakBonus + speedBonus;
    final newScore = currentScore + totalAdded;

    return ScoreResult(
      pointsAdded: totalAdded,
      basePoints: baseScore,
      streakBonus: streakBonus,
      speedBonus: speedBonus,
      newStreak: nextStreak,
      newTotalScore: newScore,
    );
  }

  ScoreResult calculateWrong({required int currentScore}) {
    return ScoreResult(
      pointsAdded: 0,
      basePoints: 0,
      streakBonus: 0,
      speedBonus: 0,
      newStreak: 0,
      newTotalScore: currentScore < 0 ? 0 : currentScore,
    );
  }
}
