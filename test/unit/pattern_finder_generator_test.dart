import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/pattern_finder_generator.dart';

void main() {
  group('PatternFinderGenerator Tests', () {
    final generator = PatternFinderGenerator(Random(101));

    test('generates valid sequences with 4 distinct options across levels', () {
      for (int level = 1; level <= 6; level++) {
        for (int i = 0; i < 15; i++) {
          final q = generator.generateNextQuestion(difficultyLevel: level);

          expect(q.prompt, contains('?'));
          expect(q.options.length, equals(4));
          expect(q.options.toSet().length, equals(4),
              reason: 'Options must be unique: ${q.options}');
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.subtitle, isNotNull);
        }
      }
    });
  });
}
