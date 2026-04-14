/// Firebase configuration options generated for the Vixora project.
/// Re-generate with: flutterfire configure --project=vixora-dc924
library;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  /// Returns the [FirebaseOptions] for the current platform.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase options for Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASvKwkn0adXeW8XVjIaof6eJuLEUp_-cI',
    appId: '1:349794555781:android:a991bf39e1bbe0ddcb56ec',
    messagingSenderId: '349794555781',
    projectId: 'vixora-dc924',
    storageBucket: 'vixora-dc924.firebasestorage.app',
  );

  /// Firebase options for iOS (placeholder — update with actual values).
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASvKwkn0adXeW8XVjIaof6eJuLEUp_-cI',
    appId: '1:349794555781:ios:vixora',
    messagingSenderId: '349794555781',
    projectId: 'vixora-dc924',
    storageBucket: 'vixora-dc924.firebasestorage.app',
    iosBundleId: 'com.example.vixora',
  );

  /// Firebase options for Web (placeholder — update with actual values).
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASvKwkn0adXeW8XVjIaof6eJuLEUp_-cI',
    appId: '1:349794555781:web:vixora',
    messagingSenderId: '349794555781',
    projectId: 'vixora-dc924',
    storageBucket: 'vixora-dc924.firebasestorage.app',
    authDomain: 'vixora-dc924.firebaseapp.com',
  );
}
