class AppConstants {
  AppConstants._();

  static const String appName = 'Think Rush';
  static const String appTagline = 'Fast Competitive Brain Battles';
  static const String appVersion = '1.0.0';

  // Game rules
  static const int roundDurationSeconds = 60;
  static const int countdownDurationSeconds = 3;
  static const int baseScore = 100;
  static const int streakMultiplier = 10;
  static const int wrongPenaltySeconds = 3;
  static const int maxDifficultyLevel = 6;
  static const int minDifficultyLevel = 1;

  // Progression & rewards
  static const int xpPerWin = 150;
  static const int xpPerPlay = 50;
  static const int coinsPerWin = 50;
  static const int coinsPerPlay = 15;
  static const int xpPerLevel = 300;

  // Networking
  static const int matchmakingTimeoutSeconds = 10;
}
