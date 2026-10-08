class GameQuestion {
  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final int difficultyLevel;
  final String? subtitle;
  final List<String>? flashItems;

  const GameQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.difficultyLevel = 1,
    this.subtitle,
    this.flashItems,
  });

  String get correctAnswer => options[correctIndex];
  bool checkAnswer(int selectedIndex) => selectedIndex == correctIndex;
}
