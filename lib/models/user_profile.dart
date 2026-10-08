class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final int avatarIndex;
  final int coins;
  final int xp;
  final int level;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int bestScore;
  final int bestStreak;
  final double accuracy;
  final String favoriteGame;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarIndex = 0,
    this.coins = 500,
    this.xp = 0,
    this.level = 1,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.bestScore = 0,
    this.bestStreak = 0,
    this.accuracy = 0.0,
    this.favoriteGame = 'Math Rush',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.initial({
    required String id,
    required String email,
    String displayName = 'Player',
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: id,
      displayName: displayName,
      email: email,
      avatarIndex: 0,
      coins: 500,
      xp: 150,
      level: 1,
      gamesPlayed: 0,
      wins: 0,
      losses: 0,
      bestScore: 0,
      bestStreak: 0,
      accuracy: 0.0,
      favoriteGame: 'Math Rush',
      createdAt: now,
      updatedAt: now,
    );
  }

  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (wins / gamesPlayed) * 100.0;
  }

  int get xpForCurrentLevel => (level - 1) * 300;
  int get xpForNextLevel => level * 300;
  double get levelProgress {
    final currentSpan = xp - xpForCurrentLevel;
    final totalSpan = xpForNextLevel - xpForCurrentLevel;
    if (totalSpan <= 0) return 1.0;
    return (currentSpan / totalSpan).clamp(0.0, 1.0);
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    int? avatarIndex,
    int? coins,
    int? xp,
    int? level,
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? bestScore,
    int? bestStreak,
    double? accuracy,
    String? favoriteGame,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      bestScore: bestScore ?? this.bestScore,
      bestStreak: bestStreak ?? this.bestStreak,
      accuracy: accuracy ?? this.accuracy,
      favoriteGame: favoriteGame ?? this.favoriteGame,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'email': email,
    'avatarIndex': avatarIndex,
    'coins': coins,
    'xp': xp,
    'level': level,
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'losses': losses,
    'bestScore': bestScore,
    'bestStreak': bestStreak,
    'accuracy': accuracy,
    'favoriteGame': favoriteGame,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Player',
      email: json['email'] as String? ?? '',
      avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 500,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      favoriteGame: json['favoriteGame'] as String? ?? 'Math Rush',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
