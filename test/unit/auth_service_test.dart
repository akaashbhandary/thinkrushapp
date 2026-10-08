import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:think_rush/models/user_profile.dart';
import 'package:think_rush/providers/auth_provider.dart';
import 'package:think_rush/services/auth/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Session Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('checkCurrentSession returns null when no session is cached', () async {
      final authService = AuthService();
      final user = await authService.checkCurrentSession();
      expect(user, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('checkCurrentSession restores user from cached SharedPreferences', () async {
      final savedUser = UserProfile.initial(
        id: 'usr_test_123',
        email: 'player@example.com',
        displayName: 'BrainChamp',
      );

      SharedPreferences.setMockInitialValues({
        'think_rush_current_user': jsonEncode(savedUser.toJson()),
      });

      final authService = AuthService();
      final user = await authService.checkCurrentSession();

      expect(user, isNotNull);
      expect(user!.id, 'usr_test_123');
      expect(user.displayName, 'BrainChamp');
      expect(user.email, 'player@example.com');
      expect(authService.isAuthenticated, isTrue);
    });

    test('signOut removes cached session and resets authentication state', () async {
      final savedUser = UserProfile.initial(
        id: 'usr_test_456',
        email: 'logout@example.com',
        displayName: 'Speedy',
      );

      SharedPreferences.setMockInitialValues({
        'think_rush_current_user': jsonEncode(savedUser.toJson()),
      });

      final authService = AuthService();
      final restored = await authService.checkCurrentSession();
      expect(restored, isNotNull);

      await authService.signOut();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);

      final nextSession = await authService.checkCurrentSession();
      expect(nextSession, isNull);
    });

    test('AuthProvider checkSession resolves cached session properly', () async {
      final savedUser = UserProfile.initial(
        id: 'usr_prov_789',
        email: 'provider@example.com',
        displayName: 'QuizMaster',
      );

      SharedPreferences.setMockInitialValues({
        'think_rush_current_user': jsonEncode(savedUser.toJson()),
      });

      final authProvider = AuthProvider();
      final user = await authProvider.checkSession();

      expect(user, isNotNull);
      expect(user!.displayName, 'QuizMaster');
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isInitialized, isTrue);
    });
  });
}
