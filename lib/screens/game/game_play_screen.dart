import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_session.dart';
import '../../models/match_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/game/option_button.dart';
import '../../widgets/game/penalty_toast.dart';
import '../../widgets/game/streak_badge.dart';
import '../../widgets/game/timer_bar.dart';
import '../results/results_screen.dart';

class GamePlayScreen extends StatefulWidget {
  final GameModeType gameMode;
  final GamePlayType playType;
  final AiDifficulty? difficulty;
  final MatchPlayer? opponentPlayer;
  final String? matchId;
  final int? seed;
  final bool isHost;

  const GamePlayScreen({
    super.key,
    required this.gameMode,
    required this.playType,
    this.difficulty,
    this.opponentPlayer,
    this.matchId,
    this.seed,
    this.isHost = true,
  });

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = context.read<GameProvider>();
      game.startGame(
        mode: widget.gameMode,
        playType: widget.playType,
        difficulty: widget.difficulty ?? AiDifficulty.medium,
        opponentPlayer: widget.opponentPlayer,
        matchId: widget.matchId,
        seed: widget.seed,
        isHost: widget.isHost,
      );
    });
  }

  void _onGameOver() {
    final game = context.read<GameProvider>();
    final player = context.read<PlayerProvider>();

    if (game.gameResult != null) {
      player.recordGameResult(game.gameResult!);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsScreen(result: game.gameResult!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (game.isGameOver && game.gameResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onGameOver());
    }

    final question = game.currentQuestion;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showQuitDialog();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Top Game Bar (Score, Opponent Score, Timer)
              _buildTopBar(game),

              // Timer Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TimerBar(
                  secondsLeft: game.secondsLeft,
                  progress: game.timerProgress,
                ),
              ),

              // Streak / Penalty Toast Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreakBadge(streak: game.streak),
                    if (game.showPenaltyNotice)
                      const PenaltyToast(penaltySeconds: 3)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LVL ${game.difficultyLevel}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Question / Flash Display Card
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: question != null
                      ? _buildQuestionCard(game, question)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),

              const SizedBox(height: 14),

              // Options
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: question != null && !game.isFlashPhase
                      ? _buildOptionsList(game, question)
                      : (game.isFlashPhase
                          ? const Center(
                              child: Text(
                                'MEMORIZE THE SEQUENCE...',
                                style: TextStyle(
                                  color: AppColors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(GameProvider game) {
    final isVersus = game.playType == GamePlayType.multiplayer || game.playType == GamePlayType.vsAi;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Player Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOU', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(
                '${game.score}',
                style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w900, fontSize: 24),
              ),
            ],
          ),

          // Quit Button
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            onPressed: _showQuitDialog,
          ),

          // Opponent Score (if applicable)
          if (isVersus)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  game.opponentName.toUpperCase(),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${game.opponentScore}',
                  style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 24),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('ACCURACY', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(
                  '${game.correctAnswers}/${game.correctAnswers + game.wrongAnswers}',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(GameProvider game, dynamic question) {
    if (game.isFlashPhase && question.flashItems != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.yellow, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow.withValues(alpha: 0.2),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'FLASHING SEQUENCE',
              style: TextStyle(color: AppColors.yellow, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: (question.flashItems as List<String>).map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cyan),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (question.subtitle != null) ...[
            Text(
              question.subtitle!,
              style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            question.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsList(GameProvider game, dynamic question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final optionText = question.options[index];
        final isSelected = game.selectedOptionIndex == index;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: OptionButton(
              text: optionText,
              index: index,
              isSelected: isSelected,
              isCorrect: isSelected ? game.isAnswerCorrect : null,
              onTap: () {
                game.submitAnswer(index);
              },
            ),
          ),
        );
      }),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Leave Match?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Leaving now will forfeit the match and end your session.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.cyan)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<GameProvider>().endGame();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('LEAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
