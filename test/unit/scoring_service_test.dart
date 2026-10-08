import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/scoring_service.dart';

void main() {
  group('ScoringService Tests', () {
    const service = ScoringService();

    test('calculates correct answer with base 100 points and speed bonus', () {
      final res = service.calculateCorrect(
        currentScore: 0,
        currentStreak: 0,
        responseTimeSeconds: 1.0, // fast < 1.5s -> +50
      );

      // base: 100, streak bonus: (1 - 1)*10 = 0, speed: 50 -> 150
      expect(res.basePoints, equals(100));
      expect(res.streakBonus, equals(0));
      expect(res.speedBonus, equals(50));
      expect(res.pointsAdded, equals(150));
      expect(res.newStreak, equals(1));
      expect(res.newTotalScore, equals(150));
    });

    test('adds streak bonus for successive correct answers', () {
      final res = service.calculateCorrect(
        currentScore: 150,
        currentStreak: 4,
        responseTimeSeconds: 3.0, // moderate < 4.0s -> +15
      );

      // next streak = 5, streak bonus = (5 - 1)*10 = 40, speed = 15 -> 100 + 40 + 15 = 155
      expect(res.newStreak, equals(5));
      expect(res.streakBonus, equals(40));
      expect(res.pointsAdded, equals(155));
      expect(res.newTotalScore, equals(305));
    });

    test('resets streak on incorrect answer and never allows score below 0', () {
      final res = service.calculateWrong(currentScore: 100);

      expect(res.newStreak, equals(0));
      expect(res.pointsAdded, equals(0));
      expect(res.newTotalScore, equals(100));

      final resZero = service.calculateWrong(currentScore: -10);
      expect(resZero.newTotalScore, equals(0));
    });
  });
}
