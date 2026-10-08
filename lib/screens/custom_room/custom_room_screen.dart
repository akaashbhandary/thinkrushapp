import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_session.dart';
import '../../models/match_model.dart';
import '../../providers/matchmaking_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/common/app_header.dart';
import '../game/game_play_screen.dart';

class CustomRoomScreen extends StatefulWidget {
  const CustomRoomScreen({super.key});

  @override
  State<CustomRoomScreen> createState() => _CustomRoomScreenState();
}

class _CustomRoomScreenState extends State<CustomRoomScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Create, 1 = Join
  GameModeType _selectedMode = GameModeType.mathRush;

  // Host state
  String? _hostedRoomCode;
  StreamSubscription<MatchModel?>? _hostRoomSubscription;

  // Join state
  final TextEditingController _joinCodeCtrl = TextEditingController();
  bool _isJoining = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hostRoomSubscription?.cancel();
    _pulseController.dispose();
    _joinCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoom() async {
    final player = context.read<PlayerProvider>().profile;
    if (player == null) return;

    final code = '${1000 + Random().nextInt(9000)}';
    final mm = context.read<MatchmakingProvider>();

    try {
      await mm.createCustomRoomDocument(
        mode: _selectedMode,
        player: player,
        roomCode: code,
      );

      setState(() {
        _hostedRoomCode = code;
      });

      // Listen for Player 2 to join (Strictly human opponent, zero bots, zero timeout)
      _hostRoomSubscription?.cancel();
      _hostRoomSubscription = mm.streamCustomRoom(code).listen((match) {
        if (!mounted || match == null) return;

        if (match.status == MatchStatus.countdown && match.player2 != null) {
          _hostRoomSubscription?.cancel();
          mm.startHostCountdown(
            match: match,
            onGameReady: () => _navigateToGame(match, isHost: true),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelHostRoom() async {
    if (_hostedRoomCode != null) {
      final code = _hostedRoomCode!;
      _hostRoomSubscription?.cancel();
      setState(() => _hostedRoomCode = null);
      await context.read<MatchmakingProvider>().cancelCustomRoom(code);
    }
  }

  Future<void> _handleJoinRoom() async {
    final code = _joinCodeCtrl.text.trim();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 4-digit room code.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final player = context.read<PlayerProvider>().profile;
    if (player == null) return;

    setState(() => _isJoining = true);
    final mm = context.read<MatchmakingProvider>();

    final success = await mm.joinRoom(
      roomCode: code,
      player: player,
      onGameReady: () {
        if (mm.currentMatch != null) {
          _navigateToGame(mm.currentMatch!, isHost: false);
        }
      },
    );

    if (mounted) {
      setState(() => _isJoining = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mm.lastError ?? 'Could not join room. Check the code and try again.'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  void _navigateToGame(MatchModel match, {required bool isHost}) {
    if (!mounted) return;
    final opponent = isHost ? match.player2 : match.player1;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GamePlayScreen(
          gameMode: match.gameMode,
          playType: GamePlayType.multiplayer,
          opponentPlayer: opponent,
          matchId: match.matchId,
          seed: match.seed,
          isHost: isHost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>().profile;
    final mm = context.watch<MatchmakingProvider>();
    final isCountdown = mm.state == MatchmakingState.matchFound || mm.state == MatchmakingState.countdown;

    return PopScope(
      canPop: !isCountdown && _hostedRoomCode == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_hostedRoomCode != null) {
          _handleCancelHostRoom();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  profile: player,
                  title: 'CUSTOM ROOM',
                  showBack: !isCountdown,
                ),
                if (_hostedRoomCode == null && !isCountdown) _buildTabBar(),
                Expanded(
                  child: isCountdown
                      ? _buildCountdownView(mm)
                      : _hostedRoomCode != null
                          ? _buildHostWaitingView(player)
                          : (_selectedTab == 0 ? _buildCreateView() : _buildJoinView()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'CREATE ROOM',
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.cyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'JOIN ROOM',
                    style: TextStyle(
                      color: _selectedTab == 1 ? AppColors.background : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '1. SELECT GAME MODE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          ...GameModeType.values.map((mode) {
            final isSelected = _selectedMode == mode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => _selectedMode = mode),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? mode.accentColor.withValues(alpha: 0.15) : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? mode.accentColor : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: mode.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(mode.icon, color: mode.accentColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
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
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? mode.accentColor : AppColors.textMuted,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.green, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Human vs Human Match',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bots are strictly disabled. The battle only begins when your friend enters the 4-digit code.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _handleCreateRoom,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: const Text('CREATE ROOM & GET CODE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHostWaitingView(dynamic player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedMode.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _selectedMode.accentColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_selectedMode.icon, color: _selectedMode.accentColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  _selectedMode.name.toUpperCase(),
                  style: TextStyle(
                    color: _selectedMode.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'ROOM CODE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),

          // Code display card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hostedRoomCode ?? '----',
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8.0,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                  onPressed: () {
                    if (_hostedRoomCode != null) {
                      Clipboard.setData(ClipboardData(text: _hostedRoomCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room code copied to clipboard!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          const Text(
            'Share this code with your friend on their phone.\nMatch will start automatically once they connect.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 36),

          // Waiting indicator
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.purple.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.cyan),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'WAITING FOR FRIEND TO JOIN...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            'No bots • No timeout',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),

          const Spacer(),

          OutlinedButton(
            onPressed: _handleCancelHostRoom,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.red),
              foregroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('CANCEL & CLOSE ROOM', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildJoinView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ENTER 4-DIGIT ROOM CODE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type the 4-digit code shown on the host device to connect directly.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _joinCodeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 14,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '••••',
              hintStyle: const TextStyle(color: AppColors.textMuted, letterSpacing: 14),
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.cyan, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: _isJoining ? null : _handleJoinRoom,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: _isJoining
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background),
                  )
                : const Text(
                    'JOIN ROOM & BATTLE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                  ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_tethering_rounded, color: AppColors.cyan, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Both devices must have an active internet connection to synchronize puzzle rounds.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownView(MatchmakingProvider mm) {
    final opponent = mm.getOpponent(context.read<PlayerProvider>().profile?.id ?? '');

    return Center(
      child: Column(
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
              'ROOM READY! PLAYERS CONNECTED',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'VS ${opponent?.name ?? 'Opponent'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            '${mm.countdownSeconds}',
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 84,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'PREPARE FOR BATTLE...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
