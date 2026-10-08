import 'package:flutter_test/flutter_test.dart';
import 'package:think_rush/models/user_profile.dart';
import 'package:think_rush/services/leaderboard/leaderboard_service.dart';

void main() {
  group('LeaderboardService Tests', () {
    final service = LeaderboardService();

    test('returns sorted leaderboard entries including current user', () async {
      final user = UserProfile.initial(
        id: 'current_user_1',
        email: 'user1@test.com',
        displayName: 'MyChampion',
      ).copyWith(bestScore: 7500, wins: 50);

      final list = await service.getLeaderboard(
        tabIndex: 0,
        currentUser: user,
      );

      expect(list, isNotEmpty);
      expect(list.any((e) => e.isCurrentPlayer), isTrue);

      // Verify descending order of scores
      for (int i = 0; i < list.length - 1; i++) {
        expect(list[i].score, greaterThanOrEqualTo(list[i + 1].score));
        expect(list[i].rank, equals(i + 1));
      }
    });
  });
}
