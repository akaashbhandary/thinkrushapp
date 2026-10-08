import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_result.dart';
import '../../widgets/common/stat_card.dart';
import '../home/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final GameResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isVersus = result.isMultiplayerOrAi;
    String outcomeTitle = 'ROUND FINISHED';
    Color outcomeColor = AppColors.purple;

    if (isVersus) {
      if (result.isWin == true) {
        outcomeTitle = 'VICTORY!';
        outcomeColor = AppColors.green;
      } else if (result.isDraw == true) {
        outcomeTitle = 'DRAW!';
        outcomeColor = AppColors.yellow;
      } else {
        outcomeTitle = 'DEFEAT';
        outcomeColor = AppColors.red;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Outcome Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: outcomeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: outcomeColor),
                ),
                child: Column(
                  children: [
                    Text(
                      outcomeTitle,
                      style: TextStyle(
                        color: outcomeColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.gameMode.name,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scores Comparison (if Versus)
              if (isVersus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('YOU', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(
                            '${result.finalScore}',
                            style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w900, fontSize: 28),
                          ),
                        ],
                      ),
                      const Text(
                        'VS',
                        style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Column(
                        children: [
                          Text(
                            result.opponentName?.toUpperCase() ?? 'OPPONENT',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${result.opponentScore ?? 0}',
                            style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 28),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Text('TOTAL SCORE', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(
                        '${result.finalScore}',
                        style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w900, fontSize: 36),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 18),

              // Rewards Earned
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.surface, AppColors.surfaceLight]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.purpleLight, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '+${result.xpEarned} XP',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: AppColors.yellow, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '+${result.coinsEarned} Coins',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Detailed Stats Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.7,
                  children: [
                    StatCard(
                      label: 'Accuracy',
                      value: '${result.accuracy}%',
                      icon: Icons.track_changes_rounded,
                      accentColor: AppColors.cyan,
                    ),
                    StatCard(
                      label: 'Best Streak',
                      value: '${result.bestStreak}x',
                      icon: Icons.local_fire_department_rounded,
                      accentColor: AppColors.yellow,
                    ),
                    StatCard(
                      label: 'Correct Answers',
                      value: '${result.correctAnswers}',
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppColors.green,
                    ),
                    StatCard(
                      label: 'Max Level',
                      value: 'Lvl ${result.maxDifficultyReached}',
                      icon: Icons.military_tech_rounded,
                      accentColor: AppColors.purpleLight,
                    ),
                  ],
                ),
              ),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('HOME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('PLAY AGAIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
