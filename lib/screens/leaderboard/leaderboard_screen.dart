import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/leaderboard_entry.dart';
import '../../providers/player_provider.dart';
import '../../services/leaderboard/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _service = LeaderboardService();
  int _selectedTab = 0; // 0 = Global, 1 = Weekly, 2 = Friends
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = context.read<PlayerProvider>().profile;
    final list = await _service.getLeaderboard(
      tabIndex: _selectedTab,
      currentUser: user,
    );
    if (!mounted) return;
    setState(() {
      _entries = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
        Container(
          padding: const EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
          color: AppColors.background,
          child: Column(
            children: [
              const Text(
                'LEADERBOARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              // Segmented Tab
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _buildTabItem(0, 'Global'),
                    _buildTabItem(1, 'Weekly'),
                    _buildTabItem(2, 'Friends'),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // Top 3 Podium
                      if (_entries.length >= 3) _buildPodium(),
                      const SizedBox(height: 16),

                      // Rest of entries
                      ..._entries.skip(3).map((e) => _buildEntryTile(e)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedTab != index) {
            setState(() => _selectedTab = index);
            _loadData();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final first = _entries[0];
    final second = _entries[1];
    final third = _entries[2];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumSpot(second, rank: 2, color: const Color(0xFFC0C0C0), height: 80),
          // 1st Place
          _buildPodiumSpot(first, rank: 1, color: const Color(0xFFFFD700), height: 110),
          // 3rd Place
          _buildPodiumSpot(third, rank: 3, color: const Color(0xFFCD7F32), height: 60),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(LeaderboardEntry entry, {required int rank, required Color color, required double height}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 32 : 26,
              backgroundColor: color.withValues(alpha: 0.3),
              child: Text(
                entry.displayName.isNotEmpty ? entry.displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: rank == 1 ? 22 : 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(
                '$rank',
                style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.displayName,
          style: TextStyle(
            color: entry.isCurrentPlayer ? AppColors.cyan : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.score} pts',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryTile(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentPlayer ? AppColors.purple.withValues(alpha: 0.2) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isCurrentPlayer ? AppColors.purple : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: entry.isCurrentPlayer ? AppColors.cyan : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              entry.displayName.isNotEmpty ? entry.displayName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    color: entry.isCurrentPlayer ? AppColors.cyan : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Level ${entry.level} • ${entry.wins} Wins',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score} pts',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
