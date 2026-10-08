import 'game_session.dart';

class GameResult {
  final GameModeType gameMode;
  final GamePlayType playType;
  final int finalScore;
  final int questionsAnswered;
  final int correctAnswers;
  final int bestStreak;
  final double accuracy;
  final int timeTakenSeconds;
  final int xpEarned;
  final int coinsEarned;
  final int maxDifficultyReached;
  final int? opponentScore;
  final String? opponentName;
  final bool? isWin;
  final bool? isDraw;

  const GameResult({
    required this.gameMode,
    required this.playType,
    required this.finalScore,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.bestStreak,
    required this.accuracy,
    required this.timeTakenSeconds,
    required this.xpEarned,
    required this.coinsEarned,
    required this.maxDifficultyReached,
    this.opponentScore,
    this.opponentName,
    this.isWin,
    this.isDraw,
  });

  bool get isMultiplayerOrAi =>
      playType == GamePlayType.multiplayer || playType == GamePlayType.vsAi;
}
