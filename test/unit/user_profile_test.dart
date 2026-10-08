import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('initial creates default user profile with 500 coins and level 1', () {
      final user = UserProfile.initial(
        id: 'usr_test_123',
        email: 'test@thinkrush.com',
        displayName: 'TestPlayer',
      );

      expect(user.id, equals('usr_test_123'));
      expect(user.displayName, equals('TestPlayer'));
      expect(user.coins, equals(500));
      expect(user.level, equals(1));
      expect(user.wins, equals(0));
      expect(user.losses, equals(0));
    });

    test('serializes and deserializes to JSON correctly', () {
      final user = UserProfile.initial(
        id: 'u1',
        email: 'u1@test.com',
        displayName: 'Brainiac',
      );

      final json = user.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.id, equals(user.id));
      expect(restored.displayName, equals(user.displayName));
      expect(restored.coins, equals(user.coins));
      expect(restored.level, equals(user.level));
    });
  });
}
