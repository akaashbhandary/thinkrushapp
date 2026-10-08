import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reward_item.dart';
import '../../providers/player_provider.dart';
import '../../services/rewards/rewards_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final RewardsService _service = RewardsService();
  List<DailyReward> _dailyRewards = [];
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profile = context.read<PlayerProvider>().profile;
    final daily = await _service.getDailyRewards();
    final ach = await _service.getAchievements(profile);

    if (!mounted) return;
    setState(() {
      _dailyRewards = daily;
      _achievements = ach;
      _isLoading = false;
    });
  }

  Future<void> _claimDaily() async {
    final reward = await _service.claimDailyReward();
    if (reward != null && mounted) {
      await context.read<PlayerProvider>().addRewards(
        coins: reward.coins,
        xp: reward.xp,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed +${reward.coins} Coins and +${reward.xp} XP!'),
          backgroundColor: AppColors.green,
        ),
      );
      _loadData();
    }
  }

  Future<void> _claimAchievement(Achievement ach) async {
    final success = await _service.claimAchievement(ach.id);
    if (success && mounted) {
      await context.read<PlayerProvider>().addRewards(
        coins: ach.rewardCoins,
        xp: ach.rewardXp,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claimed Achievement Reward: +${ach.rewardCoins} Coins!'),
          backgroundColor: AppColors.green,
        ),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
          color: AppColors.background,
          child: const Center(
            child: Text(
              'DAILY REWARDS & ACHIEVEMENTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 7-day Login Rewards
                      const Text(
                        '7-DAY LOGIN STREAK',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDailyCalendar(),
                      const SizedBox(height: 24),

                      // Achievements
                      const Text(
                        'ACHIEVEMENTS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._achievements.map((ach) => _buildAchievementCard(ach)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDailyCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dailyRewards.map((r) => _buildDayItem(r)).toList(),
          ),
          const SizedBox(height: 16),
          FutureBuilder<bool>(
            future: _service.canClaimToday(),
            builder: (context, snapshot) {
              final canClaim = snapshot.data ?? false;
              return ElevatedButton(
                onPressed: canClaim ? _claimDaily : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  canClaim ? 'CLAIM TODAY\'S REWARD' : 'ALREADY CLAIMED TODAY',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(DailyReward reward) {
    Color bg = AppColors.surfaceLight;
    Color border = AppColors.border;

    if (reward.isClaimed) {
      bg = AppColors.green.withValues(alpha: 0.2);
      border = AppColors.green;
    } else if (reward.isToday) {
      bg = AppColors.yellow.withValues(alpha: 0.2);
      border = AppColors.yellow;
    }

    return Column(
      children: [
        Container(
          width: 38,
          height: 52,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'D${reward.day}',
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (reward.isClaimed)
                const Icon(Icons.check_rounded, color: AppColors.green, size: 16)
              else
                const Icon(Icons.monetization_on_rounded, color: AppColors.yellow, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '+${reward.coins}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement ach) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ach.isCompleted ? AppColors.purple.withValues(alpha: 0.2) : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ach.isCompleted ? AppColors.purple : AppColors.border),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: ach.isCompleted ? AppColors.yellow : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  ach.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ach.progressPercentage,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (ach.isClaimed)
            const Text('CLAIMED', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 11))
          else if (ach.isCompleted)
            ElevatedButton(
              onPressed: () => _claimAchievement(ach),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else
            Text(
              '${ach.currentProgress}/${ach.maxProgress}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
