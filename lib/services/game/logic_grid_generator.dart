import 'dart:math';
import '../../models/game_question.dart';
import 'game_generator.dart';

class LogicGridGenerator implements GameGenerator {
  final Random _random;

  LogicGridGenerator([Random? random]) : _random = random ?? Random();

  static final List<Map<String, dynamic>> _logicChallenges = [
    {
      'prompt': 'Circle is to Sphere as Square is to... ?',
      'correct': 'Cube',
      'options': ['Cube', 'Cone', 'Cylinder', 'Pyramid'],
      'level': 1,
    },
    {
      'prompt': 'Clock is to Time as Thermometer is to... ?',
      'correct': 'Temperature',
      'options': ['Temperature', 'Weather', 'Mercury', 'Pressure'],
      'level': 1,
    },
    {
      'prompt': 'Ocean is to Water as Desert is to... ?',
      'correct': 'Sand',
      'options': ['Sand', 'Cactus', 'Sun', 'Camel'],
      'level': 1,
    },
    {
      'prompt': 'Book is to Author as Painting is to... ?',
      'correct': 'Artist',
      'options': ['Artist', 'Museum', 'Canvas', 'Color'],
      'level': 1,
    },
    {
      'prompt': 'Bird is to Nest as Bee is to... ?',
      'correct': 'Hive',
      'options': ['Hive', 'Flower', 'Honey', 'Wing'],
      'level': 2,
    },
    {
      'prompt': 'Which one does NOT belong?',
      'correct': 'Moon',
      'options': ['Moon', 'Mars', 'Jupiter', 'Venus'],
      'level': 2,
    },
    {
      'prompt': 'Which number does NOT fit the rule: All even numbers?',
      'correct': '27',
      'options': ['27', '18', '44', '62'],
      'level': 1,
    },
    {
      'prompt': 'Which number does NOT belong: All multiples of 5?',
      'correct': '36',
      'options': ['36', '45', '70', '95'],
      'level': 1,
    },
    {
      'prompt': 'Leo is taller than Sam. Sam is taller than Max. Who is the tallest?',
      'correct': 'Leo',
      'options': ['Leo', 'Sam', 'Max', 'Cannot tell'],
      'level': 2,
    },
    {
      'prompt': 'A is faster than B. B is faster than C. Who is the slowest?',
      'correct': 'C',
      'options': ['C', 'A', 'B', 'Both B and C'],
      'level': 2,
    },
    {
      'prompt': 'All roses are flowers. All flowers need sunlight. Therefore:',
      'correct': 'All roses need sunlight',
      'options': ['All roses need sunlight', 'All flowers are roses', 'Only roses need sunlight', 'Sunlight makes roses red'],
      'level': 3,
    },
    {
      'prompt': 'If 2 -> 4, 3 -> 9, 5 -> 25, then 6 -> ?',
      'correct': '36',
      'options': ['36', '30', '42', '12'],
      'level': 3,
    },
    {
      'prompt': 'Every cat has whiskers. Whiskers is a cat. Therefore:',
      'correct': 'Whiskers has whiskers',
      'options': ['Whiskers has whiskers', 'All cats are named Whiskers', 'Whiskers is a dog', 'No other cat has whiskers'],
      'level': 3,
    },
    {
      'prompt': 'If North turns 180° then turns 90° clockwise, which direction is faced?',
      'correct': 'West',
      'options': ['West', 'East', 'South', 'North'],
      'level': 4,
    },
    {
      'prompt': 'If red = 3, blue = 4, green = 5, what is "purple"?',
      'correct': '6',
      'options': ['6', '7', '8', '5'],
      'level': 4,
    },
    {
      'prompt': 'Train is to Track as Submarine is to... ?',
      'correct': 'Water',
      'options': ['Water', 'Sky', 'Torpedo', 'Periscope'],
      'level': 5,
    },
    {
      'prompt': 'Look at the pattern: 2, 6, 12, 20, 30, ? What is next?',
      'correct': '42',
      'options': ['42', '40', '44', '36'],
      'level': 6,
    },
    {
      'prompt': 'If today is Tuesday, what day was it 3 days before yesterday?',
      'correct': 'Friday',
      'options': ['Friday', 'Saturday', 'Thursday', 'Sunday'],
      'level': 6,
    },
  ];

  @override
  GameQuestion generateNextQuestion({required int difficultyLevel}) {
    final clampedLevel = difficultyLevel.clamp(1, 6);

    var candidates = _logicChallenges
        .where((c) => (c['level'] as int) == clampedLevel)
        .toList();

    if (candidates.isEmpty) {
      candidates = _logicChallenges;
    }

    final chosen = candidates[_random.nextInt(candidates.length)];
    final prompt = chosen['prompt'] as String;
    final correctAnswer = chosen['correct'] as String;
    final originalOptions = List<String>.from(chosen['options'] as List);

    final shuffledOptions = List<String>.from(originalOptions)..shuffle(_random);
    final correctIndex = shuffledOptions.indexOf(correctAnswer);

    return GameQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: prompt,
      subtitle: 'Logical Deduction',
      options: shuffledOptions,
      correctIndex: correctIndex,
      difficultyLevel: clampedLevel,
    );
  }
}
