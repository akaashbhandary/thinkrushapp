import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/memory_flash_generator.dart';

void main() {
  group('MemoryFlashGenerator Tests', () {
    final generator = MemoryFlashGenerator(Random(77));

    test('scales symbol count from 3 to 8 across levels 1 to 6', () {
      for (int level = 1; level <= 6; level++) {
        final q = generator.generateNextQuestion(difficultyLevel: level);

        expect(q.flashItems, isNotNull);
        expect(q.flashItems!.length, equals(level + 2));
        expect(q.options.length, equals(4));
        expect(q.options.toSet().length, equals(4));
        expect(q.correctIndex, inInclusiveRange(0, 3));
      }
    });
  });
}
