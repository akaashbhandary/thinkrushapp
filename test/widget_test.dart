import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:think_rush/main.dart';
import 'package:think_rush/providers/auth_provider.dart';
import 'package:think_rush/providers/game_provider.dart';
import 'package:think_rush/providers/matchmaking_provider.dart';
import 'package:think_rush/providers/player_provider.dart';
import 'package:think_rush/providers/settings_provider.dart';

void main() {
  testWidgets('Think Rush app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => GameProvider()),
          ChangeNotifierProvider(create: (_) => MatchmakingProvider()),
        ],
        child: const ThinkRushApp(),
      ),
    );

    // Initial frame builds ThinkRushApp and SplashScreen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('THINK RUSH'), findsOneWidget);

    // Pump timer duration so SplashScreen finishes smoothly
    await tester.pump(const Duration(seconds: 2));
  });
}