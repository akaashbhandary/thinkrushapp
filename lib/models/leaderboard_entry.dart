class LeaderboardEntry {
  final int rank;
  final String playerId;
  final String displayName;
  final int avatarIndex;
  final int score;
  final int wins;
  final int level;
  final bool isCurrentPlayer;

  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.displayName,
    required this.avatarIndex,
    required this.score,
    required this.wins,
    required this.level,
    this.isCurrentPlayer = false,
  });

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'playerId': playerId,
    'displayName': displayName,
    'avatarIndex': avatarIndex,
    'score': score,
    'wins': wins,
    'level': level,
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {bool isCurrentPlayer = false}) =>
      LeaderboardEntry(
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        playerId: json['playerId'] as String? ?? '',
        displayName: json['displayName'] as String? ?? 'Player',
        avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
        score: (json['score'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        isCurrentPlayer: isCurrentPlayer,
      );
}
