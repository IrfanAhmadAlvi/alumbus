// lib/firebase_options.dart
// THIS IS ONLY AN EXAMPLE. DO NOT COPY THIS.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Your actual file has different keys for each platform
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSy*****************YOUR_KEY', // Your file has a real key
          appId: '1:1234567890:android:abcde12345', // Your file has a real ID
          messagingSenderId: '1234567890',
          projectId: 'alumbus-3b85b', // Your project ID
          storageBucket: 'alumbus-3b85b.appspot.com',
        );

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}