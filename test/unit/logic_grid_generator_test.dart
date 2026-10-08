import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/logic_grid_generator.dart';

void main() {
  group('LogicGridGenerator Tests', () {
    final generator = LogicGridGenerator();

    test('generates valid logic questions with 4 options and valid correct index', () {
      for (int level = 1; level <= 6; level++) {
        final q = generator.generateNextQuestion(difficultyLevel: level);
        expect(q.prompt, isNotEmpty);
        expect(q.options.length, equals(4));
        expect(q.correctIndex, inInclusiveRange(0, 3));
        expect(q.options[q.correctIndex], isNotEmpty);
      }
    });
  });
}
