import 'dart:math';
import '../../models/game_question.dart';
import 'game_generator.dart';

class PatternFinderGenerator implements GameGenerator {
  final Random _random;

  PatternFinderGenerator([Random? random]) : _random = random ?? Random();

  @override
  GameQuestion generateNextQuestion({required int difficultyLevel}) {
    final clampedLevel = difficultyLevel.clamp(1, 6);
    late List<int> sequence;
    late int correctAnswer;
    late String ruleDescription;

    final ruleType = (clampedLevel <= 2)
        ? _random.nextInt(2)
        : (clampedLevel <= 4)
            ? _random.nextInt(4)
            : _random.nextInt(6);

    switch (ruleType) {
      case 0:
        final diff = _random.nextInt(5 * clampedLevel) + 2;
        final start = _random.nextInt(20) + 1;
        sequence = [start, start + diff, start + 2 * diff, start + 3 * diff];
        correctAnswer = start + 4 * diff;
        ruleDescription = 'Add $diff each step';
        break;

      case 1:
        final diff = _random.nextInt(4 * clampedLevel) + 2;
        final start = (clampedLevel * 15) + (diff * 5) + _random.nextInt(10);
        sequence = [start, start - diff, start - 2 * diff, start - 3 * diff];
        correctAnswer = start - 4 * diff;
        ruleDescription = 'Subtract $diff each step';
        break;

      case 2:
        final multiplier = clampedLevel >= 4 && _random.nextBool() ? 3 : 2;
        final start = _random.nextInt(5) + 2;
        sequence = [
          start,
          start * multiplier,
          start * multiplier * multiplier,
          start * multiplier * multiplier * multiplier,
        ];
        correctAnswer = sequence.last * multiplier;
        ruleDescription = 'Multiply by $multiplier';
        break;

      case 3:
        final isOddDiff = _random.nextBool();
        var current = _random.nextInt(10) + 1;
        sequence = [current];
        var step = isOddDiff ? 3 : 2;
        for (int i = 0; i < 3; i++) {
          current += step;
          sequence.add(current);
          step += isOddDiff ? 2 : 1;
        }
        correctAnswer = current + step;
        ruleDescription = isOddDiff ? 'Add successive odd numbers' : 'Difference increases by 1';
        break;

      case 4:
        final startN = _random.nextInt(4) + 1;
        sequence = [
          startN * startN,
          (startN + 1) * (startN + 1),
          (startN + 2) * (startN + 2),
          (startN + 3) * (startN + 3),
        ];
        correctAnswer = (startN + 4) * (startN + 4);
        ruleDescription = 'Squares of numbers';
        break;

      case 5:
      default:
        final a = _random.nextInt(4) + 1;
        final b = _random.nextInt(4) + a;
        final c = a + b;
        final d = b + c;
        sequence = [a, b, c, d];
        correctAnswer = c + d;
        ruleDescription = 'Sum of previous two numbers';
        break;
    }

    final prompt = '${sequence.join(', ')},  ?';

    final Set<int> optionsSet = {correctAnswer};
    final List<int> deltas = [-4, -3, -2, -1, 1, 2, 3, 4, 5, 8, 10];
    deltas.shuffle(_random);

    for (final delta in deltas) {
      if (optionsSet.length >= 4) break;
      final cand = correctAnswer + delta;
      if (cand != correctAnswer && (cand > 0 || correctAnswer <= 0)) {
        optionsSet.add(cand);
      }
    }

    var fallback = 1;
    while (optionsSet.length < 4) {
      final cand = correctAnswer + fallback;
      optionsSet.add(cand);
      fallback = fallback > 0 ? -fallback - 1 : -fallback + 1;
    }

    final optionsList = optionsSet.toList()..shuffle(_random);
    final correctIndex = optionsList.indexOf(correctAnswer);

    return GameQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: prompt,
      subtitle: ruleDescription,
      options: optionsList.map((e) => e.toString()).toList(),
      correctIndex: correctIndex,
      difficultyLevel: clampedLevel,
    );
  }
}
