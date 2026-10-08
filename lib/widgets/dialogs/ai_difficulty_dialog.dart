import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/game_session.dart';

class AiDifficultyDialog extends StatelessWidget {
  final ValueChanged<AiDifficulty> onSelect;

  const AiDifficultyDialog({
    super.key,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, color: AppColors.cyan, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Select AI Difficulty',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your offline computer opponent strength:',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _buildOption(
              context,
              difficulty: AiDifficulty.easy,
              title: 'Easy',
              subtitle: '70–80% Accuracy • Slower Speed',
              color: AppColors.green,
            ),
            const SizedBox(height: 10),
            _buildOption(
              context,
              difficulty: AiDifficulty.medium,
              title: 'Medium',
              subtitle: '80–90% Accuracy • Moderate Speed',
              color: AppColors.yellow,
            ),
            const SizedBox(height: 10),
            _buildOption(
              context,
              difficulty: AiDifficulty.hard,
              title: 'Hard',
              subtitle: '90–97% Accuracy • Fast Reflexes',
              color: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required AiDifficulty difficulty,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onSelect(difficulty);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
