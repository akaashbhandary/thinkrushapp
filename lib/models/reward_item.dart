class DailyReward {
  final int day;
  final int coins;
  final int xp;
  final bool isClaimed;
  final bool isToday;

  const DailyReward({
    required this.day,
    required this.coins,
    required this.xp,
    this.isClaimed = false,
    this.isToday = false,
  });

  DailyReward copyWith({bool? isClaimed, bool? isToday}) => DailyReward(
    day: day,
    coins: coins,
    xp: xp,
    isClaimed: isClaimed ?? this.isClaimed,
    isToday: isToday ?? this.isToday,
  );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final int rewardXp;
  final int rewardCoins;
  final int currentProgress;
  final int maxProgress;
  final bool isClaimed;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.rewardCoins,
    required this.currentProgress,
    required this.maxProgress,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= maxProgress;
  double get progressPercentage => (currentProgress / maxProgress).clamp(0.0, 1.0);

  Achievement copyWith({int? currentProgress, bool? isClaimed}) => Achievement(
    id: id,
    title: title,
    description: description,
    rewardXp: rewardXp,
    rewardCoins: rewardCoins,
    currentProgress: currentProgress ?? this.currentProgress,
    maxProgress: maxProgress,
    isClaimed: isClaimed ?? this.isClaimed,
  );
}
