import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      // Try to initialize Firebase using DefaultFirebaseOptions
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('Firebase successfully initialized!');
    } catch (e) {
      debugPrint('Firebase initialization failed or not configured: $e');
      debugPrint('Falling back to Mock Repository mode.');
      _isInitialized = false;
    }
  }
}
