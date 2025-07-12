import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:alumbus/src/app.dart';

Future<void> main() async {
  // This line ensures Flutter is ready.
  WidgetsFlutterBinding.ensureInitialized();

  // THIS "if" STATEMENT IS THE FIX.
  // It checks if Firebase is already initialized before trying again.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const App());
}