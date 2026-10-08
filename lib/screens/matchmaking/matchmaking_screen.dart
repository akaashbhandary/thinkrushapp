import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_session.dart';
import '../../providers/matchmaking_provider.dart';
import '../../providers/player_provider.dart';
import '../game/game_play_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  final GameModeType gameMode;

  const MatchmakingScreen({super.key, required this.gameMode});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSearch();
    });
  }

  void _startSearch() {
    final player = context.read<PlayerProvider>().profile;
    if (player == null) return;

    final mm = context.read<MatchmakingProvider>();
    mm.startMatchmaking(
      mode: widget.gameMode,
      player: player,
      onGameReady: () => _navigateToGame(mm, player.id),
    );
  }

  void _navigateToGame(MatchmakingProvider mm, String playerId) {
    if (!mounted) return;
    final match = mm.currentMatch;
    final opponent = mm.getOpponent(playerId);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GamePlayScreen(
          gameMode: widget.gameMode,
          playType: GamePlayType.multiplayer,
          opponentPlayer: opponent,
          matchId: match?.matchId,
          seed: match?.seed,
          isHost: mm.isHost,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mm = context.watch<MatchmakingProvider>();
    final player = context.watch<PlayerProvider>().profile;
    final isMatched = mm.state == MatchmakingState.matchFound || mm.state == MatchmakingState.countdown;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        mm.cancelMatchmaking();
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () {
              mm.cancelMatchmaking();
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            widget.gameMode.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: isMatched
                ? _buildMatchFoundView(mm, player)
                : _buildSearchingView(mm, player),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingView(MatchmakingProvider mm, dynamic player) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160 + (_radarController.value * 50),
                    height: 160 + (_radarController.value * 50),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 1.0 - _radarController.value),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cyan, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.radar_rounded, color: AppColors.cyan, size: 54),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 36),
          const Text(
            'SEARCHING FOR OPPONENT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Looking for another player worldwide...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public_rounded, size: 16, color: AppColors.cyan),
                SizedBox(width: 8),
                Text(
                  'Global Matchmaking Queue Active',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchFoundView(MatchmakingProvider mm, dynamic player) {
    final opponent = mm.getOpponent(player?.id ?? '');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.green),
          ),
          child: const Text(
            'MATCH FOUND!',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // User
            Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.purple,
                  child: Text(
                    player?.displayName.isNotEmpty == true ? player.displayName[0].toUpperCase() : 'P',
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  player?.displayName ?? 'You',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Lvl ${player?.level ?? 1}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),

            // VS Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'VS',
                style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),

            // Opponent
            Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.cyan,
                  child: Text(
                    opponent?.name.isNotEmpty == true ? opponent!.name[0].toUpperCase() : 'O',
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  opponent?.name ?? 'Opponent',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  'Challenger',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 50),

        // Countdown Circle
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.purple, AppColors.cyan]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.5),
                blurRadius: 18,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${mm.countdownSeconds}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'BATTLE STARTING...',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
