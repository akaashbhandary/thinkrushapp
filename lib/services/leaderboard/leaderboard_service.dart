import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/user_profile.dart';
import '../firebase/firebase_config.dart';

class LeaderboardService {
  final List<LeaderboardEntry> _mockGlobal = [
    const LeaderboardEntry(rank: 1, playerId: 'm1', displayName: 'NovaMind', avatarIndex: 1, score: 9850, wins: 88, level: 12),
    const LeaderboardEntry(rank: 2, playerId: 'm2', displayName: 'ApexCortex', avatarIndex: 2, score: 8720, wins: 76, level: 11),
    const LeaderboardEntry(rank: 3, playerId: 'm3', displayName: 'CipherKing', avatarIndex: 3, score: 7940, wins: 69, level: 10),
    const LeaderboardEntry(rank: 4, playerId: 'm4', displayName: 'SpeedyLogic', avatarIndex: 4, score: 6890, wins: 58, level: 9),
    const LeaderboardEntry(rank: 5, playerId: 'm5', displayName: 'MathWizard', avatarIndex: 0, score: 6200, wins: 51, level: 8),
    const LeaderboardEntry(rank: 6, playerId: 'm6', displayName: 'FlashSynapse', avatarIndex: 5, score: 5410, wins: 44, level: 7),
    const LeaderboardEntry(rank: 7, playerId: 'm7', displayName: 'GridMaster', avatarIndex: 2, score: 4830, wins: 39, level: 6),
    const LeaderboardEntry(rank: 8, playerId: 'm8', displayName: 'QuickReflex', avatarIndex: 1, score: 4120, wins: 32, level: 5),
    const LeaderboardEntry(rank: 9, playerId: 'm9', displayName: 'ZenithIQ', avatarIndex: 3, score: 3670, wins: 28, level: 5),
    const LeaderboardEntry(rank: 10, playerId: 'm10', displayName: 'QuantumByte', avatarIndex: 4, score: 3100, wins: 22, level: 4),
  ];

  final List<LeaderboardEntry> _mockWeekly = [
    const LeaderboardEntry(rank: 1, playerId: 'w1', displayName: 'ApexCortex', avatarIndex: 2, score: 3240, wins: 29, level: 11),
    const LeaderboardEntry(rank: 2, playerId: 'w2', displayName: 'NovaMind', avatarIndex: 1, score: 2980, wins: 26, level: 12),
    const LeaderboardEntry(rank: 3, playerId: 'w3', displayName: 'SpeedyLogic', avatarIndex: 4, score: 2640, wins: 23, level: 9),
    const LeaderboardEntry(rank: 4, playerId: 'w4', displayName: 'MathWizard', avatarIndex: 0, score: 2150, wins: 19, level: 8),
    const LeaderboardEntry(rank: 5, playerId: 'w5', displayName: 'CipherKing', avatarIndex: 3, score: 1890, wins: 16, level: 10),
    const LeaderboardEntry(rank: 6, playerId: 'w6', displayName: 'FlashSynapse', avatarIndex: 5, score: 1420, wins: 12, level: 7),
  ];

  final List<LeaderboardEntry> _mockFriends = [
    const LeaderboardEntry(rank: 1, playerId: 'f1', displayName: 'Alex_Friend', avatarIndex: 3, score: 4500, wins: 35, level: 6),
    const LeaderboardEntry(rank: 2, playerId: 'f2', displayName: 'Sara_Logic', avatarIndex: 5, score: 3800, wins: 30, level: 5),
    const LeaderboardEntry(rank: 3, playerId: 'f3', displayName: 'Rohan_Math', avatarIndex: 0, score: 2900, wins: 21, level: 4),
  ];

  Future<List<LeaderboardEntry>> getLeaderboard({
    required int tabIndex, // 0 = Global, 1 = Weekly, 2 = Friends
    UserProfile? currentUser,
  }) async {
    List<LeaderboardEntry> list;
    if (tabIndex == 1) {
      list = List.from(_mockWeekly);
    } else if (tabIndex == 2) {
      list = List.from(_mockFriends);
    } else {
      list = List.from(_mockGlobal);
    }

    if (currentUser != null) {
      final userScore = currentUser.bestScore > 0 ? currentUser.bestScore : (currentUser.wins * 150);
      final userEntry = LeaderboardEntry(
        rank: 0,
        playerId: currentUser.id,
        displayName: currentUser.displayName,
        avatarIndex: currentUser.avatarIndex,
        score: userScore,
        wins: currentUser.wins,
        level: currentUser.level,
        isCurrentPlayer: true,
      );

      list.removeWhere((e) => e.playerId == currentUser.id);
      list.add(userEntry);
      list.sort((a, b) => b.score.compareTo(a.score));

      // Reassign rank numbers
      for (int i = 0; i < list.length; i++) {
        list[i] = LeaderboardEntry(
          rank: i + 1,
          playerId: list[i].playerId,
          displayName: list[i].displayName,
          avatarIndex: list[i].avatarIndex,
          score: list[i].score,
          wins: list[i].wins,
          level: list[i].level,
          isCurrentPlayer: list[i].playerId == currentUser.id,
        );
      }
    }

    return list;
  }

  Future<void> syncUserScore(UserProfile user) async {
    if (!FirebaseConfig.isFirebaseAvailable) return;
    try {
      await FirebaseFirestore.instance.collection('leaderboard').doc(user.id).set({
        'playerId': user.id,
        'displayName': user.displayName,
        'avatarIndex': user.avatarIndex,
        'score': user.bestScore,
        'wins': user.wins,
        'level': user.level,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
