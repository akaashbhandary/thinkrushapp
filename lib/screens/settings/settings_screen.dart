import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'AUDIO & HAPTICS',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          _buildToggle(
            title: 'Sound Effects',
            subtitle: 'Button clicks, correct and wrong answer sounds',
            value: settings.soundEnabled,
            onChanged: (val) => settings.toggleSound(),
          ),
          _buildToggle(
            title: 'Background Music',
            subtitle: 'Atmospheric theme during matches',
            value: settings.musicEnabled,
            onChanged: (val) => settings.toggleMusic(),
          ),
          _buildToggle(
            title: 'Haptic Feedback',
            subtitle: 'Vibration on touches and penalties',
            value: settings.hapticEnabled,
            onChanged: (val) => settings.toggleHaptic(),
          ),
          const SizedBox(height: 24),

          const Text(
            'NOTIFICATIONS',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          _buildToggle(
            title: 'Daily Reminders',
            subtitle: 'Get notified when daily reward is ready',
            value: settings.notificationsEnabled,
            onChanged: (val) => settings.toggleNotifications(),
          ),
          const SizedBox(height: 24),

          const Text(
            'ACCOUNT & SYSTEM',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('App Version', style: TextStyle(color: Colors.white, fontSize: 15)),
                Text(AppConstants.appVersion, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: () => _confirmSignOut(context, auth),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red.withValues(alpha: 0.2),
              side: const BorderSide(color: AppColors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'SIGN OUT',
              style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.purple,
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return AppColors.textMuted;
            }),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out of Think Rush?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.cyan)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('SIGN OUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
