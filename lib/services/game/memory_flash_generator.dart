import 'dart:math';
import '../../models/game_question.dart';
import 'game_generator.dart';

class MemoryFlashGenerator implements GameGenerator {
  final Random _random;

  static const List<String> symbolPool = [
    '●', '▲', '■', '★', '◆', '✦', '⬟', '✚', '♥', '⚡',
  ];

  MemoryFlashGenerator([Random? random]) : _random = random ?? Random();

  @override
  GameQuestion generateNextQuestion({required int difficultyLevel}) {
    final clampedLevel = difficultyLevel.clamp(1, 6);
    final count = clampedLevel + 2;

    final shuffledPool = List<String>.from(symbolPool)..shuffle(_random);
    final flashSymbols = shuffledPool.sublist(0, min(count, symbolPool.length));

    final challengeType = _random.nextInt(3);
    late String prompt;
    late String subtitle;
    late String correctAnswer;

    if (challengeType == 0) {
      final targetIndex = _random.nextInt(flashSymbols.length);
      correctAnswer = flashSymbols[targetIndex];
      prompt = 'Which symbol was at position ${targetIndex + 1}?';
      subtitle = 'Recall the flash sequence';
    } else if (challengeType == 1) {
      final remainingSymbols = symbolPool.where((s) => !flashSymbols.contains(s)).toList();
      if (remainingSymbols.isNotEmpty) {
        remainingSymbols.shuffle(_random);
        correctAnswer = remainingSymbols.first;
        prompt = 'Which symbol was NOT shown?';
        subtitle = 'Recall the flash sequence';
      } else {
        correctAnswer = flashSymbols.first;
        prompt = 'Which symbol was at position 1?';
        subtitle = 'Recall the flash sequence';
      }
    } else {
      correctAnswer = flashSymbols.last;
      prompt = 'Which symbol was the LAST in sequence?';
      subtitle = 'Recall the flash sequence';
    }

    final Set<String> optionsSet = {correctAnswer};
    final List<String> otherSymbols = symbolPool.where((s) => s != correctAnswer).toList()..shuffle(_random);

    for (final s in otherSymbols) {
      if (optionsSet.length >= 4) break;
      optionsSet.add(s);
    }

    final optionsList = optionsSet.toList()..shuffle(_random);
    final correctIndex = optionsList.indexOf(correctAnswer);

    return GameQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: prompt,
      subtitle: subtitle,
      options: optionsList,
      correctIndex: correctIndex,
      difficultyLevel: clampedLevel,
      flashItems: flashSymbols,
    );
  }
}
