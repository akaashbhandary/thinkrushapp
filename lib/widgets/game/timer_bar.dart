import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TimerBar extends StatelessWidget {
  final int secondsLeft;
  final double progress;

  const TimerBar({
    super.key,
    required this.secondsLeft,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isLowTime = secondsLeft <= 10;
    final color = isLowTime ? AppColors.red : (secondsLeft <= 25 ? AppColors.yellow : AppColors.cyan);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${secondsLeft}s',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (isLowTime)
              const Text(
                'TIME RUNNING OUT!',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
