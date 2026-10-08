import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/matchmaking_provider.dart';
import 'providers/player_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/firebase/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to vertical / portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Safe initialize Firebase (offline fallback if google-services.json not configured)
  await FirebaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(), lazy: false),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => MatchmakingProvider()),
      ],
      child: const ThinkRushApp(),
    ),
  );
}

class ThinkRushApp extends StatelessWidget {
  const ThinkRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Think Rush',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
