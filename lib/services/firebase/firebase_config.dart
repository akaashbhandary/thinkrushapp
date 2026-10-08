import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  FirebaseConfig._();
  static bool _isInitialized = false;
  static bool get isFirebaseAvailable => _isInitialized;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('[ThinkRush] Firebase initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[ThinkRush] Running with local persistent data engine ($e).');
    }
  }
}
