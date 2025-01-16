// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBMrUQW-Tfbnzme6zlxgJKSv4YOl52Xtow',
    appId: '1:207870710729:web:25fe6dc1dc1e9cc5254e18',
    messagingSenderId: '207870710729',
    projectId: 'challengeflutter-5d5eb',
    authDomain: 'challengeflutter-5d5eb.firebaseapp.com',
    storageBucket: 'challengeflutter-5d5eb.firebasestorage.app',
    measurementId: 'G-FX6CXRJ8LP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaKmkcHZXwJqf6KcTOPkInJtDRI_F9rWA',
    appId: '1:207870710729:android:bd330028d3418ae0254e18',
    messagingSenderId: '207870710729',
    projectId: 'challengeflutter-5d5eb',
    storageBucket: 'challengeflutter-5d5eb.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBMrUQW-Tfbnzme6zlxgJKSv4YOl52Xtow',
    appId: '1:207870710729:web:81a88ecdd011bac5254e18',
    messagingSenderId: '207870710729',
    projectId: 'challengeflutter-5d5eb',
    authDomain: 'challengeflutter-5d5eb.firebaseapp.com',
    storageBucket: 'challengeflutter-5d5eb.firebasestorage.app',
    measurementId: 'G-316ZL89S88',
  );

}