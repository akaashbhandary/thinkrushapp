import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/math_rush_generator.dart';

void main() {
  group('MathRushGenerator Tests', () {
    final generator = MathRushGenerator(Random(42));

    test('generates valid questions across all difficulty levels 1 to 6', () {
      for (int level = 1; level <= 6; level++) {
        for (int i = 0; i < 20; i++) {
          final q = generator.generateNextQuestion(difficultyLevel: level);

          expect(q.prompt, isNotEmpty);
          expect(q.options.length, equals(4));
          expect(q.options.toSet().length, equals(4),
              reason: 'Options must be distinct: ${q.options}');
          expect(q.correctIndex, inInclusiveRange(0, 3));

          final correctVal = int.parse(q.options[q.correctIndex]);
          expect(correctVal, isNonNegative);

          // Verify operations are strictly single-operation
          final hasSingleOp = q.prompt.contains('+') ||
              q.prompt.contains('-') ||
              q.prompt.contains('×') ||
              q.prompt.contains('÷');
          expect(hasSingleOp, isTrue);

          // Verify no mixed operations in a single expression
          final opCount = RegExp(r'[+\-×÷]').allMatches(q.prompt).length;
          expect(opCount, equals(1),
              reason: 'Must never combine operations: ${q.prompt}');
        }
      }
    });

    test('Level 5 division produces whole numbers only', () {
      for (int i = 0; i < 30; i++) {
        final q = generator.generateNextQuestion(difficultyLevel: 5);
        if (q.prompt.contains('÷')) {
          final parts = q.prompt.replaceAll(' = ?', '').split(' ÷ ');
          final dividend = int.parse(parts[0].trim());
          final divisor = int.parse(parts[1].trim());

          expect(dividend % divisor, equals(0),
              reason: 'Division must produce whole-number answers: $dividend ÷ $divisor');
        }
      }
    });
  });
}
