import '../../models/game_question.dart';

abstract class GameGenerator {
  GameQuestion generateNextQuestion({required int difficultyLevel});
}
