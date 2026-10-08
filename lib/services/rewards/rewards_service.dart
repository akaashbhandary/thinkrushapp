import 'package:shared_preferences/shared_preferences.dart';
import '../../models/reward_item.dart';
import '../../models/user_profile.dart';

class RewardsService {
  static const String _lastClaimDateKey = 'think_rush_last_reward_claim';
  static const String _streakCountKey = 'think_rush_reward_streak';
  static const String _claimedAchievementsKey = 'think_rush_claimed_achievements';

  final List<DailyReward> _defaultDailyRewards = const [
    DailyReward(day: 1, coins: 50, xp: 25),
    DailyReward(day: 2, coins: 100, xp: 50),
    DailyReward(day: 3, coins: 150, xp: 75),
    DailyReward(day: 4, coins: 200, xp: 100),
    DailyReward(day: 5, coins: 300, xp: 150),
    DailyReward(day: 6, coins: 500, xp: 250),
    DailyReward(day: 7, coins: 1000, xp: 500),
  ];

  Future<List<DailyReward>> getDailyRewards() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_streakCountKey) ?? 0;
    final canClaim = await canClaimToday();

    final currentDay = (streak % 7) + 1;

    return List.generate(7, (index) {
      final dayNumber = index + 1;
      final defaultReward = _defaultDailyRewards[index];
      final isClaimed = dayNumber < currentDay || (dayNumber == currentDay && !canClaim);
      final isToday = dayNumber == currentDay;

      return defaultReward.copyWith(
        isClaimed: isClaimed,
        isToday: isToday,
      );
    });
  }

  Future<bool> canClaimToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaim = prefs.getString(_lastClaimDateKey);
    if (lastClaim == null) return true;

    final lastDate = DateTime.tryParse(lastClaim);
    if (lastDate == null) return true;

    final now = DateTime.now();
    return !(lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day);
  }

  Future<DailyReward?> claimDailyReward() async {
    if (!await canClaimToday()) return null;

    final prefs = await SharedPreferences.getInstance();
    int streak = prefs.getInt(_streakCountKey) ?? 0;
    final lastClaim = prefs.getString(_lastClaimDateKey);

    if (lastClaim != null) {
      final lastDate = DateTime.tryParse(lastClaim);
      if (lastDate != null) {
        final difference = DateTime.now().difference(lastDate).inDays;
        if (difference > 1) {
          streak = 0; // Streak broken
        }
      }
    }

    final currentRewardIndex = streak % 7;
    final reward = _defaultDailyRewards[currentRewardIndex];

    streak += 1;
    await prefs.setInt(_streakCountKey, streak);
    await prefs.setString(_lastClaimDateKey, DateTime.now().toIso8601String());

    return reward;
  }

  Future<List<Achievement>> getAchievements(UserProfile? profile) async {
    final prefs = await SharedPreferences.getInstance();
    final claimedIds = prefs.getStringList(_claimedAchievementsKey) ?? [];

    final wins = profile?.wins ?? 0;
    final streak = profile?.bestStreak ?? 0;
    final level = profile?.level ?? 1;
    final coins = profile?.coins ?? 0;
    final games = profile?.gamesPlayed ?? 0;

    final definitions = [
      Achievement(
        id: 'first_win',
        title: 'First Victory',
        description: 'Win your first competitive match.',
        rewardXp: 100,
        rewardCoins: 50,
        currentProgress: wins,
        maxProgress: 1,
        isClaimed: claimedIds.contains('first_win'),
      ),
      Achievement(
        id: 'streak_5',
        title: 'On Fire!',
        description: 'Achieve a correct answer streak of 5.',
        rewardXp: 150,
        rewardCoins: 100,
        currentProgress: streak,
        maxProgress: 5,
        isClaimed: claimedIds.contains('streak_5'),
      ),
      Achievement(
        id: 'veteran_10',
        title: 'Brain Veteran',
        description: 'Play 10 rounds of brain training.',
        rewardXp: 200,
        rewardCoins: 150,
        currentProgress: games,
        maxProgress: 10,
        isClaimed: claimedIds.contains('veteran_10'),
      ),
      Achievement(
        id: 'level_5',
        title: 'Master Mind',
        description: 'Reach Player Level 5.',
        rewardXp: 300,
        rewardCoins: 250,
        currentProgress: level,
        maxProgress: 5,
        isClaimed: claimedIds.contains('level_5'),
      ),
      Achievement(
        id: 'wealthy_1000',
        title: 'Coin Collector',
        description: 'Accumulate 1,000 coins in your bank.',
        rewardXp: 250,
        rewardCoins: 200,
        currentProgress: coins,
        maxProgress: 1000,
        isClaimed: claimedIds.contains('wealthy_1000'),
      ),
    ];

    return definitions;
  }

  Future<bool> claimAchievement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final claimedIds = prefs.getStringList(_claimedAchievementsKey) ?? [];
    if (claimedIds.contains(id)) return false;

    claimedIds.add(id);
    await prefs.setStringList(_claimedAchievementsKey, claimedIds);
    return true;
  }
}
