import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool _isLoading = false;
  String? _errorMessage;

  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  Future<UserProfile?>? _sessionFuture;

  AuthProvider() {
    checkSession();
  }

  Future<UserProfile?> checkSession() {
    if (_isInitialized && _authService.currentUser != null) {
      return Future.value(_authService.currentUser);
    }
    _sessionFuture ??= _authService.checkCurrentSession().then((user) {
      _isInitialized = true;
      notifyListeners();
      return user;
    });
    return _sessionFuture!;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;
    _isInitialized = true;
    if (result.success) {
      _sessionFuture = Future.value(result.user);
    } else {
      _errorMessage = result.errorMessage ?? 'Failed to sign in.';
    }
    notifyListeners();
    return result.success;
  }

  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signUp(
      displayName: displayName,
      email: email,
      password: password,
    );

    _isLoading = false;
    _isInitialized = true;
    if (result.success) {
      _sessionFuture = Future.value(result.user);
    } else {
      _errorMessage = result.errorMessage ?? 'Failed to create account.';
    }
    notifyListeners();
    return result.success;
  }

  Future<bool> signInGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signInAsGuest();
    _isLoading = false;
    _isInitialized = true;
    if (result.success) {
      _sessionFuture = Future.value(result.user);
    } else {
      _errorMessage = result.errorMessage ?? 'Failed to sign in as guest.';
    }
    notifyListeners();
    return result.success;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.sendPasswordReset(email);
    _isLoading = false;
    if (!result.success) {
      _errorMessage = result.errorMessage ?? 'Failed to send password reset email.';
      notifyListeners();
      throw Exception(_errorMessage);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _sessionFuture = Future.value(null);
    _isInitialized = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
