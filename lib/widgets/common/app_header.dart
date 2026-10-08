import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_profile.dart';

class AppHeader extends StatelessWidget {
  final UserProfile? profile;
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppHeader({
    super.key,
    this.profile,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (showBack)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              )
            else if (profile != null)
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Text(
                    profile!.displayName.isNotEmpty ? profile!.displayName[0].toUpperCase() : 'P',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profile != null)
                    Text(
                      'Level ${profile!.level} • ${profile!.coins} Coins',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (profile != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: AppColors.yellow, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${profile!.coins}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
