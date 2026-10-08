import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/word_rush_generator.dart';

void main() {
  group('WordRushGenerator Tests', () {
    final generator = WordRushGenerator();

    test('generates valid word puzzles with 4 options and valid answer', () {
      for (int level = 1; level <= 6; level++) {
        final q = generator.generateNextQuestion(difficultyLevel: level);
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, equals(4));
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.options.toSet().length, equals(4)); // all 4 distinct options
      }
    });
  });
}
