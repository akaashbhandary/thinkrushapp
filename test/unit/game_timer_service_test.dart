import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/services/game/game_timer_service.dart';

void main() {
  group('GameTimerService Tests', () {
    test('initializes with default 60s countdown', () {
      final timer = GameTimerService(initialSeconds: 60);
      expect(timer.secondsLeft, equals(60));
      expect(timer.isFinished, isFalse);
      timer.dispose();
    });

    test('applies penalty correctly and clamps to zero', () {
      bool timeUpTriggered = false;
      final timer = GameTimerService(
        initialSeconds: 5,
        onTimeUp: () {
          timeUpTriggered = true;
        },
      );

      timer.applyPenalty(3);
      expect(timer.secondsLeft, equals(2));
      expect(timeUpTriggered, isFalse);

      timer.applyPenalty(3);
      expect(timer.secondsLeft, equals(0));
      expect(timeUpTriggered, isTrue);
      expect(timer.isFinished, isTrue);

      timer.dispose();
    });
  });
}
