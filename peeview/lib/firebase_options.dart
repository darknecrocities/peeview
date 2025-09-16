// lib/firebase_options.dart

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
        throw UnsupportedError(
          'iOS not configured. Add FirebaseOptions for iOS if needed.',
        );
      default:
        throw UnsupportedError(
          'Unsupported platform for FirebaseOptions.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDYjpW4PbtuVPvbOEUfcDFn5ZOQT-UvOB8',
    appId: '1:173594402514:web:9b3accaea0ad3aded8570b',
    messagingSenderId: '173594402514',
    projectId: 'gen-lang-client-0722950290',
    storageBucket: 'gen-lang-client-0722950290.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYjpW4PbtuVPvbOEUfcDFn5ZOQT-UvOB8',
    appId: '1:173594402514:android:6d7df748e363b85bd8570b',
    messagingSenderId: '173594402514',
    projectId: 'gen-lang-client-0722950290',
    storageBucket: 'gen-lang-client-0722950290.firebasestorage.app',
  );
}
