import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _soundKey = 'think_rush_sound';
  static const String _musicKey = 'think_rush_music';
  static const String _hapticKey = 'think_rush_haptic';
  static const String _notifKey = 'think_rush_notif';

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = true;
  bool _notificationsEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundKey) ?? true;
    _musicEnabled = prefs.getBool(_musicKey) ?? true;
    _hapticEnabled = prefs.getBool(_hapticKey) ?? true;
    _notificationsEnabled = prefs.getBool(_notifKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, value);
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifKey, value);
  }
}
