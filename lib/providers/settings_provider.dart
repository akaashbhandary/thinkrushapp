import 'package:flutter/material.dart';
import '../services/settings/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  bool get soundEnabled => _service.soundEnabled;
  bool get musicEnabled => _service.musicEnabled;
  bool get hapticEnabled => _service.hapticEnabled;
  bool get notificationsEnabled => _service.notificationsEnabled;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    await _service.loadSettings();
    notifyListeners();
  }

  Future<void> toggleSound() async {
    await _service.setSoundEnabled(!soundEnabled);
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    await _service.setMusicEnabled(!musicEnabled);
    notifyListeners();
  }

  Future<void> toggleHaptic() async {
    await _service.setHapticEnabled(!hapticEnabled);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    await _service.setNotificationsEnabled(!notificationsEnabled);
    notifyListeners();
  }
}
