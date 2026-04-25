/// Firebase configuration options for the Vixora project (vixora-dc924).
/// Manually written — do NOT run flutterfire configure.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASvKwkn0adXeW8XVjIaof6eJuLEUp_-cI',
    appId: '1:349794555781:android:4d5300ada130908acb56ec',
    messagingSenderId: '349794555781',
    projectId: 'vixora-dc924',
    storageBucket: 'vixora-dc924.firebasestorage.app',
  );
}
