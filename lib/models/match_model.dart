import 'game_session.dart';

enum MatchStatus { waiting, countdown, playing, completed, cancelled }

class MatchPlayer {
  final String id;
  final String name;
  final int avatarIndex;
  final int score;
  final int streak;
  final bool hasFinished;

  const MatchPlayer({
    required this.id,
    required this.name,
    this.avatarIndex = 0,
    this.score = 0,
    this.streak = 0,
    this.hasFinished = false,
  });

  MatchPlayer copyWith({
    String? id,
    String? name,
    int? avatarIndex,
    int? score,
    int? streak,
    bool? hasFinished,
  }) => MatchPlayer(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarIndex: avatarIndex ?? this.avatarIndex,
    score: score ?? this.score,
    streak: streak ?? this.streak,
    hasFinished: hasFinished ?? this.hasFinished,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarIndex': avatarIndex,
    'score': score,
    'streak': streak,
    'hasFinished': hasFinished,
  };

  factory MatchPlayer.fromJson(Map<String, dynamic> json) => MatchPlayer(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Player',
    avatarIndex: (json['avatarIndex'] as num?)?.toInt() ?? 0,
    score: (json['score'] as num?)?.toInt() ?? 0,
    streak: (json['streak'] as num?)?.toInt() ?? 0,
    hasFinished: json['hasFinished'] as bool? ?? false,
  );
}

class MatchModel {
  final String matchId;
  final GameModeType gameMode;
  final MatchStatus status;
  final MatchPlayer player1;
  final MatchPlayer? player2;
  final int seed;
  final DateTime createdAt;
  final String? winnerId;
  final String? roomCode;

  const MatchModel({
    required this.matchId,
    required this.gameMode,
    required this.status,
    required this.player1,
    this.player2,
    required this.seed,
    required this.createdAt,
    this.winnerId,
    this.roomCode,
  });

  bool get isFull => player2 != null;

  MatchModel copyWith({
    String? matchId,
    GameModeType? gameMode,
    MatchStatus? status,
    MatchPlayer? player1,
    MatchPlayer? player2,
    int? seed,
    DateTime? createdAt,
    String? winnerId,
    String? roomCode,
  }) => MatchModel(
    matchId: matchId ?? this.matchId,
    gameMode: gameMode ?? this.gameMode,
    status: status ?? this.status,
    player1: player1 ?? this.player1,
    player2: player2 ?? this.player2,
    seed: seed ?? this.seed,
    createdAt: createdAt ?? this.createdAt,
    winnerId: winnerId ?? this.winnerId,
    roomCode: roomCode ?? this.roomCode,
  );

  Map<String, dynamic> toJson() => {
    'matchId': matchId,
    'gameMode': gameMode.index,
    'status': status.index,
    'player1': player1.toJson(),
    'player2': player2?.toJson(),
    'seed': seed,
    'createdAt': createdAt.toIso8601String(),
    'winnerId': winnerId,
    'roomCode': roomCode,
  };

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
    matchId: json['matchId'] as String? ?? '',
    gameMode: GameModeType.values[(json['gameMode'] as num?)?.toInt() ?? 0],
    status: MatchStatus.values[(json['status'] as num?)?.toInt() ?? 0],
    player1: MatchPlayer.fromJson(json['player1'] as Map<String, dynamic>? ?? {}),
    player2: json['player2'] != null ? MatchPlayer.fromJson(json['player2'] as Map<String, dynamic>) : null,
    seed: (json['seed'] as num?)?.toInt() ?? 42,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    winnerId: json['winnerId'] as String?,
    roomCode: json['roomCode'] as String?,
  );
}
