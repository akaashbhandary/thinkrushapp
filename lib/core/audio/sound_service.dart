import 'package:flutter/services.dart';

class SoundService {
  SoundService._();

  static bool soundEnabled = true;
  static bool musicEnabled = true;
  static bool vibrationEnabled = true;

  static void playButtonClick() {
    if (vibrationEnabled) HapticFeedback.selectionClick();
  }

  static void playCorrect() {
    if (vibrationEnabled) HapticFeedback.lightImpact();
  }

  static void playWrong() {
    if (vibrationEnabled) HapticFeedback.heavyImpact();
  }

  static void playCountdownTick() {
    if (vibrationEnabled) HapticFeedback.selectionClick();
  }

  static void playGo() {
    if (vibrationEnabled) HapticFeedback.mediumImpact();
  }

  static void playMatchFound() {
    if (vibrationEnabled) HapticFeedback.heavyImpact();
  }

  static void playVictory() {
    if (vibrationEnabled) HapticFeedback.heavyImpact();
  }

  static void playDefeat() {
    if (vibrationEnabled) HapticFeedback.lightImpact();
  }
}
