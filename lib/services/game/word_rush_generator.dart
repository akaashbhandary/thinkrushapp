import 'dart:math';
import '../../models/game_question.dart';
import 'game_generator.dart';

class WordRushGenerator implements GameGenerator {
  final Random _random;

  WordRushGenerator([Random? random]) : _random = random ?? Random();

  static final List<Map<String, dynamic>> _wordChallenges = [
    {
      'type': 'unscramble',
      'scrambled': 'B R N A I',
      'correct': 'BRAIN',
      'options': ['BRAIN', 'BARON', 'BRINE', 'BRAWN'],
      'level': 1,
    },
    {
      'type': 'unscramble',
      'scrambled': 'S U R H',
      'correct': 'RUSH',
      'options': ['RUSH', 'SHUR', 'HURS', 'RUSK'],
      'level': 1,
    },
    {
      'type': 'unscramble',
      'scrambled': 'S F T A',
      'correct': 'FAST',
      'options': ['FAST', 'FIST', 'FEAT', 'FATS'],
      'level': 1,
    },
    {
      'type': 'unscramble',
      'scrambled': 'S M R T A',
      'correct': 'SMART',
      'options': ['SMART', 'START', 'STORM', 'SMACK'],
      'level': 2,
    },
    {
      'type': 'unscramble',
      'scrambled': 'P U Z L E Z',
      'correct': 'PUZZLE',
      'options': ['PUZZLE', 'PUDDLE', 'MUZZLE', 'NOZZLE'],
      'level': 2,
    },
    {
      'type': 'spelling',
      'prompt': 'Which word is spelled CORRECTLY?',
      'correct': 'Receive',
      'options': ['Receive', 'Recieve', 'Receeve', 'Riceive'],
      'level': 2,
    },
    {
      'type': 'spelling',
      'prompt': 'Which word is spelled CORRECTLY?',
      'correct': 'Separate',
      'options': ['Separate', 'Seperate', 'Seprate', 'Sepperate'],
      'level': 3,
    },
    {
      'type': 'synonym',
      'prompt': 'What is the SYNONYM for "Rapid"?',
      'correct': 'Quick',
      'options': ['Quick', 'Sluggish', 'Heavy', 'Gentle'],
      'level': 1,
    },
    {
      'type': 'antonym',
      'prompt': 'What is the ANTONYM for "Ancient"?',
      'correct': 'Modern',
      'options': ['Modern', 'Old', 'Historic', 'Antique'],
      'level': 2,
    },
    {
      'type': 'synonym',
      'prompt': 'What is the SYNONYM for "Shrewd"?',
      'correct': 'Astute',
      'options': ['Astute', 'Foolish', 'Naive', 'Blunt'],
      'level': 4,
    },
    {
      'type': 'odd',
      'prompt': 'Which word does NOT belong?',
      'correct': 'Table',
      'options': ['Table', 'Apple', 'Banana', 'Orange'],
      'level': 1,
    },
    {
      'type': 'odd',
      'prompt': 'Which word does NOT belong?',
      'correct': 'Helium',
      'options': ['Helium', 'Gold', 'Silver', 'Copper'],
      'level': 4,
    },
  ];

  @override
  GameQuestion generateNextQuestion({required int difficultyLevel}) {
    final clampedLevel = difficultyLevel.clamp(1, 6);

    var candidates = _wordChallenges
        .where((c) => (c['level'] as int) == clampedLevel)
        .toList();

    if (candidates.isEmpty) {
      candidates = _wordChallenges;
    }

    final chosen = candidates[_random.nextInt(candidates.length)];
    final type = chosen['type'] as String;
    late String prompt;
    late String subtitle;

    if (type == 'unscramble') {
      prompt = 'Unscramble:  ${chosen['scrambled']}';
      subtitle = 'Find the correct word';
    } else {
      prompt = chosen['prompt'] as String;
      subtitle = type == 'spelling'
          ? 'Check Spelling'
          : type == 'odd'
              ? 'Find Odd Word'
              : 'Word Relationship';
    }

    final correctAnswer = chosen['correct'] as String;
    final originalOptions = List<String>.from(chosen['options'] as List);

    final shuffledOptions = List<String>.from(originalOptions)..shuffle(_random);
    final correctIndex = shuffledOptions.indexOf(correctAnswer);

    return GameQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: prompt,
      subtitle: subtitle,
      options: shuffledOptions,
      correctIndex: correctIndex,
      difficultyLevel: clampedLevel,
    );
  }
}
