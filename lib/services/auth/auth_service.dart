import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../firebase/firebase_config.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final UserProfile? user;

  const AuthResult({required this.success, this.errorMessage, this.user});
  factory AuthResult.success(UserProfile user) => AuthResult(success: true, user: user);
  factory AuthResult.failure(String message) => AuthResult(success: false, errorMessage: message);
}

class AuthService {
  static const String _sessionUserKey = 'think_rush_current_user';
  static const String _usersDbKey = 'think_rush_registered_users';

  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<UserProfile?> checkCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(_sessionUserKey);
    if (cached != null) {
      try {
        _currentUser = UserProfile.fromJson(jsonDecode(cached));
        return _currentUser;
      } catch (e) {
        debugPrint('[AuthService] Error restoring session from cache: $e');
      }
    }

    if (FirebaseConfig.isFirebaseAvailable) {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final profile = UserProfile.initial(
          id: fbUser.uid,
          email: fbUser.email ?? 'player@thinkrush.com',
          displayName: fbUser.displayName ?? 'Player',
        );
        _currentUser = profile;
        await prefs.setString(_sessionUserKey, jsonEncode(profile.toJson()));
        return _currentUser;
      }
    }

    _currentUser = null;
    return null;
  }

  Future<AuthResult> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = displayName.trim();

    if (trimmedName.isEmpty) return AuthResult.failure('Please enter your display name.');
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) return AuthResult.failure('Please enter a valid email address.');
    if (password.length < 6) return AuthResult.failure('Password must be at least 6 characters.');

    final prefs = await SharedPreferences.getInstance();

    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: trimmedEmail,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          await fbUser.updateDisplayName(trimmedName);
          final userProfile = UserProfile.initial(
            id: fbUser.uid,
            email: trimmedEmail,
            displayName: trimmedName,
          );
          _currentUser = userProfile;
          await prefs.setString(_sessionUserKey, jsonEncode(userProfile.toJson()));
          return AuthResult.success(userProfile);
        }
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(e.message ?? 'Registration failed.');
      } catch (e) {
        debugPrint('[AuthService] Firebase registration error: $e');
      }
    }

    final usersJson = prefs.getString(_usersDbKey);
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      users = jsonDecode(usersJson) as Map<String, dynamic>;
    }

    if (users.containsKey(trimmedEmail)) {
      return AuthResult.failure('An account with this email already exists.');
    }

    final localId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final userProfile = UserProfile.initial(
      id: localId,
      email: trimmedEmail,
      displayName: trimmedName,
    );

    users[trimmedEmail] = {
      'password': password,
      'profile': userProfile.toJson(),
    };

    await prefs.setString(_usersDbKey, jsonEncode(users));
    await prefs.setString(_sessionUserKey, jsonEncode(userProfile.toJson()));
    _currentUser = userProfile;

    return AuthResult.success(userProfile);
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) return AuthResult.failure('Please enter your email.');
    if (password.isEmpty) return AuthResult.failure('Please enter your password.');

    final prefs = await SharedPreferences.getInstance();

    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: trimmedEmail,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          final cached = prefs.getString(_sessionUserKey);
          UserProfile userProfile = cached != null
              ? UserProfile.fromJson(jsonDecode(cached))
              : UserProfile.initial(
                  id: fbUser.uid,
                  email: trimmedEmail,
                  displayName: fbUser.displayName ?? 'Player',
                );
          _currentUser = userProfile;
          await prefs.setString(_sessionUserKey, jsonEncode(userProfile.toJson()));
          return AuthResult.success(userProfile);
        }
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(e.message ?? 'Invalid credentials.');
      } catch (e) {
        debugPrint('[AuthService] Firebase login error: $e');
      }
    }

    final usersJson = prefs.getString(_usersDbKey);
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      users = jsonDecode(usersJson) as Map<String, dynamic>;
    }

    if (!users.containsKey(trimmedEmail)) {
      final localId = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      final namePart = trimmedEmail.split('@').first;
      final capitalized = namePart.isNotEmpty
          ? '${namePart[0].toUpperCase()}${namePart.substring(1)}'
          : 'Player';
      final guestProfile = UserProfile.initial(
        id: localId,
        email: trimmedEmail,
        displayName: capitalized,
      );
      users[trimmedEmail] = {
        'password': password,
        'profile': guestProfile.toJson(),
      };
      await prefs.setString(_usersDbKey, jsonEncode(users));
      await prefs.setString(_sessionUserKey, jsonEncode(guestProfile.toJson()));
      _currentUser = guestProfile;
      return AuthResult.success(guestProfile);
    }

    final userData = users[trimmedEmail] as Map<String, dynamic>;
    final savedPassword = userData['password'] as String?;
    if (savedPassword != password) {
      return AuthResult.failure('Incorrect password.');
    }

    final userProfile = UserProfile.fromJson(userData['profile'] as Map<String, dynamic>);
    _currentUser = userProfile;
    await prefs.setString(_sessionUserKey, jsonEncode(userProfile.toJson()));

    return AuthResult.success(userProfile);
  }

  Future<AuthResult> signInAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        final credential = await fb.FirebaseAuth.instance.signInAnonymously();
        final fbUser = credential.user;
        if (fbUser != null) {
          final guestProfile = UserProfile.initial(
            id: fbUser.uid,
            email: 'guest_${fbUser.uid.substring(0, 5)}@thinkrush.com',
            displayName: 'Guest_${fbUser.uid.substring(0, 4)}',
          );
          _currentUser = guestProfile;
          await prefs.setString(_sessionUserKey, jsonEncode(guestProfile.toJson()));
          return AuthResult.success(guestProfile);
        }
      } catch (e) {
        debugPrint('[AuthService] Firebase guest error: $e');
      }
    }

    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final guestProfile = UserProfile.initial(
      id: guestId,
      email: 'guest@thinkrush.com',
      displayName: 'Guest Player',
    );
    _currentUser = guestProfile;
    await prefs.setString(_sessionUserKey, jsonEncode(guestProfile.toJson()));
    return AuthResult.success(guestProfile);
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return AuthResult.failure('Please enter a valid email address.');
    }

    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: trimmedEmail);
        return const AuthResult(success: true);
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(e.message ?? 'Failed to send reset email.');
      }
    }

    return const AuthResult(success: true);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserKey);

    if (FirebaseConfig.isFirebaseAvailable) {
      try {
        await fb.FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('[AuthService] Firebase signOut error: $e');
      }
    }
    _currentUser = null;
  }
}
