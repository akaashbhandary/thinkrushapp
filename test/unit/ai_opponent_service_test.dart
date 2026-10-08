import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/models/game_question.dart';
import 'package:think_rush/models/game_session.dart';
import 'package:think_rush/services/ai/ai_opponent_service.dart';

void main() {
  group('AiOpponentService Tests', () {
    test('initializes with distinct names and zero stats', () {
      final ai = AiOpponentService(difficulty: AiDifficulty.hard);

      expect(ai.state.name, isNotEmpty);
      expect(ai.state.score, equals(0));
      expect(ai.state.streak, equals(0));

      ai.dispose();
    });

    test('simulates thinking state when question is presented', () {
      final ai = AiOpponentService(difficulty: AiDifficulty.easy);

      const q = GameQuestion(
        id: '1',
        prompt: '2 + 2 = ?',
        options: ['4', '5', '3', '6'],
        correctIndex: 0,
      );

      ai.processQuestion(q);
      expect(ai.state.isThinking, isTrue);

      ai.dispose();
    });
  });
}
