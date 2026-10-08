import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StreakBadge extends StatelessWidget {
  final int streak;

  const StreakBadge({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    if (streak <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.yellow,
            AppColors.red,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '${streak}x STREAK',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
