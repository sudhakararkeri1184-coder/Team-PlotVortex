// firebase_options.dart
// AUTO-GENERATED FILE - Run: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'board-arena',
    authDomain: 'board-arena.firebaseapp.com',
    storageBucket: 'board-arena.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyClxhJ1AJsSibIaFZXmc8GMVjaWoE8h7Lk",
    appId: "1:455263466399:android:b4d181778063b2a00483aa",
    messagingSenderId: "455263466399",
    projectId: "boardarena-73641",
    storageBucket: "boardarena-73641.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_APP_ID',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'board-arena',
    storageBucket: 'board-arena.appspot.com',
    iosBundleId: 'com.example.v2',
  );
}
