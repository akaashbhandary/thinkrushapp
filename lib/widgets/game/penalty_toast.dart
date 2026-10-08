import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PenaltyToast extends StatelessWidget {
  final int penaltySeconds;

  const PenaltyToast({
    super.key,
    this.penaltySeconds = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            '-${penaltySeconds}s PENALTY!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
