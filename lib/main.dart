import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:alumbus/src/app.dart';

Future<void> main() async {
  // Ensure Flutter is properly initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase only if it hasn't been already
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Handle hot restart or duplicate init safely
    if (e.toString().contains('duplicate-app')) {
      debugPrint('⚠️ Firebase already initialized. Ignoring duplicate-app error.');
    } else {
      rethrow; // Any other error should still crash
    }
  }

  runApp(const App());
}
