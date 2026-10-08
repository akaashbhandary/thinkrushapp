import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors.surface;
    Color borderColor = AppColors.border;
    Color textColor = AppColors.white;

    if (isSelected) {
      if (isCorrect == true) {
        backgroundColor = AppColors.green.withValues(alpha: 0.25);
        borderColor = AppColors.green;
        textColor = AppColors.green;
      } else if (isCorrect == false) {
        backgroundColor = AppColors.red.withValues(alpha: 0.25);
        borderColor = AppColors.red;
        textColor = AppColors.red;
      } else {
        backgroundColor = AppColors.purple.withValues(alpha: 0.25);
        borderColor = AppColors.purple;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.purple.withValues(alpha: 0.3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected && isCorrect != null)
                Icon(
                  isCorrect! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isCorrect! ? AppColors.green : AppColors.red,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
