import 'dart:math';
import '../../models/game_question.dart';
import 'game_generator.dart';

class MathRushGenerator implements GameGenerator {
  final Random _random;

  MathRushGenerator([Random? random]) : _random = random ?? Random();

  @override
  GameQuestion generateNextQuestion({required int difficultyLevel}) {
    final clampedLevel = difficultyLevel.clamp(1, 6);
    late String prompt;
    late int correctAnswer;

    switch (clampedLevel) {
      case 1:
        final isAdd = _random.nextBool();
        final a = _random.nextInt(15) + 1;
        final b = _random.nextInt(15) + 1;
        if (isAdd) {
          prompt = '$a + $b = ?';
          correctAnswer = a + b;
        } else {
          final larger = max(a, b);
          final smaller = min(a, b);
          prompt = '$larger - $smaller = ?';
          correctAnswer = larger - smaller;
        }
        break;

      case 2:
        final isAdd = _random.nextBool();
        final a = _random.nextInt(50) + 20;
        final b = _random.nextInt(40) + 10;
        if (isAdd) {
          prompt = '$a + $b = ?';
          correctAnswer = a + b;
        } else {
          final larger = max(a, b);
          final smaller = min(a, b);
          prompt = '$larger - $smaller = ?';
          correctAnswer = larger - smaller;
        }
        break;

      case 3:
        final a = _random.nextInt(10) + 3;
        final b = _random.nextInt(9) + 2;
        prompt = '$a × $b = ?';
        correctAnswer = a * b;
        break;

      case 4:
        final a = _random.nextInt(15) + 11;
        final b = _random.nextInt(12) + 4;
        prompt = '$a × $b = ?';
        correctAnswer = a * b;
        break;

      case 5:
        final divisor = _random.nextInt(12) + 2;
        final quotient = _random.nextInt(15) + 2;
        final dividend = divisor * quotient;
        prompt = '$dividend ÷ $divisor = ?';
        correctAnswer = quotient;
        break;

      case 6:
      default:
        final op = _random.nextInt(4);
        if (op == 0) {
          final a = _random.nextInt(350) + 120;
          final b = _random.nextInt(350) + 120;
          prompt = '$a + $b = ?';
          correctAnswer = a + b;
        } else if (op == 1) {
          final a = _random.nextInt(450) + 250;
          final b = _random.nextInt(200) + 50;
          prompt = '$a - $b = ?';
          correctAnswer = a - b;
        } else if (op == 2) {
          final a = _random.nextInt(25) + 15;
          final b = _random.nextInt(15) + 8;
          prompt = '$a × $b = ?';
          correctAnswer = a * b;
        } else {
          final divisor = _random.nextInt(20) + 6;
          final quotient = _random.nextInt(30) + 10;
          final dividend = divisor * quotient;
          prompt = '$dividend ÷ $divisor = ?';
          correctAnswer = quotient;
        }
        break;
    }

    final Set<int> optionsSet = {correctAnswer};
    final List<int> deltas = [-10, -5, -3, -2, -1, 1, 2, 3, 5, 10, 15, 20];
    deltas.shuffle(_random);

    for (final delta in deltas) {
      if (optionsSet.length >= 4) break;
      final cand = correctAnswer + delta;
      if (cand >= 0 && cand != correctAnswer) {
        optionsSet.add(cand);
      }
    }

    var fallbackOffset = 1;
    while (optionsSet.length < 4) {
      final cand = correctAnswer + fallbackOffset;
      if (cand >= 0) optionsSet.add(cand);
      fallbackOffset = fallbackOffset > 0 ? -fallbackOffset - 1 : -fallbackOffset + 1;
    }

    final optionsList = optionsSet.toList()..shuffle(_random);
    final correctIndex = optionsList.indexOf(correctAnswer);

    return GameQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: prompt,
      options: optionsList.map((e) => e.toString()).toList(),
      correctIndex: correctIndex,
      difficultyLevel: clampedLevel,
    );
  }
}
