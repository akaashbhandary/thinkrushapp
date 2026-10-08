import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final profile = player.profile;

    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final winRate = profile.gamesPlayed > 0
        ? ((profile.wins / profile.gamesPlayed) * 100).toStringAsFixed(1)
        : '0.0';

    return Column(
      children: [
        // Top Header
        Container(
          padding: const EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
          color: AppColors.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PLAYER PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              // Profile Badge Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.purple,
                          child: Text(
                            profile.displayName.isNotEmpty ? profile.displayName[0].toUpperCase() : 'P',
                            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showAvatarPicker(context, player),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.cyan,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: AppColors.background, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          profile.displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 18),
                          onPressed: () => _showEditNameDialog(context, player),
                        ),
                      ],
                    ),
                    Text(
                      'Level ${profile.level} Challenger',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    // XP Progress bar to next level
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('XP Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            Text('${profile.xp % 300} / 300 XP', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (profile.xp % 300) / 300.0,
                            minHeight: 6,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purpleLight),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'CAREER STATISTICS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    label: 'Games Played',
                    value: '${profile.gamesPlayed}',
                    icon: Icons.sports_esports_rounded,
                    accentColor: AppColors.purple,
                  ),
                  StatCard(
                    label: 'Victories',
                    value: '${profile.wins}',
                    icon: Icons.emoji_events_rounded,
                    accentColor: AppColors.yellow,
                  ),
                  StatCard(
                    label: 'Win Rate',
                    value: '$winRate%',
                    icon: Icons.pie_chart_rounded,
                    accentColor: AppColors.green,
                  ),
                  StatCard(
                    label: 'Highest Score',
                    value: '${profile.bestScore}',
                    icon: Icons.stars_rounded,
                    accentColor: AppColors.cyan,
                  ),
                  StatCard(
                    label: 'Best Streak',
                    value: '${profile.bestStreak}x',
                    icon: Icons.local_fire_department_rounded,
                    accentColor: AppColors.red,
                  ),
                  StatCard(
                    label: 'Avg Accuracy',
                    value: '${profile.accuracy}%',
                    icon: Icons.track_changes_rounded,
                    accentColor: AppColors.purpleLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAvatarPicker(BuildContext context, PlayerProvider player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Avatar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(6, (index) {
                  final isSelected = player.profile?.avatarIndex == index;
                  return GestureDetector(
                    onTap: () {
                      player.updateAvatar(index);
                      Navigator.of(ctx).pop();
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: isSelected ? AppColors.cyan : AppColors.surfaceLight,
                      child: Text(
                        'A${index + 1}',
                        style: TextStyle(
                          color: isSelected ? AppColors.background : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, PlayerProvider player) {
    final ctrl = TextEditingController(text: player.profile?.displayName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Username', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Username',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.cyan)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                player.updateUsername(newName);
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
