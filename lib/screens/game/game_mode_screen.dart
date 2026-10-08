import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_session.dart';
import '../../providers/player_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/dialogs/ai_difficulty_dialog.dart';
import '../matchmaking/matchmaking_screen.dart';
import 'game_play_screen.dart';

class GameModeScreen extends StatelessWidget {
  final GamePlayType playType;

  const GameModeScreen({super.key, required this.playType});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppHeader(
            profile: player.profile,
            title: playType.title,
            showBack: true,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              itemCount: GameModeType.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final mode = GameModeType.values[index];
                return _buildModeCard(context, mode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, GameModeType mode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleModeSelect(context, mode),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: mode.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: mode.accentColor.withValues(alpha: 0.4)),
                ),
                child: Icon(mode.icon, color: mode.accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _handleModeSelect(BuildContext context, GameModeType mode) {
    if (playType == GamePlayType.multiplayer) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MatchmakingScreen(gameMode: mode),
        ),
      );
    } else if (playType == GamePlayType.vsAi) {
      showDialog(
        context: context,
        builder: (_) => AiDifficultyDialog(
          onSelect: (difficulty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GamePlayScreen(
                  gameMode: mode,
                  playType: GamePlayType.vsAi,
                  difficulty: difficulty,
                ),
              ),
            );
          },
        ),
      );
    } else {
      // Single player
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GamePlayScreen(
            gameMode: mode,
            playType: GamePlayType.singlePlayer,
          ),
        ),
      );
    }
  }
}
