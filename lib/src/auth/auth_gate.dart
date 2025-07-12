import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/auth/login_screen.dart';
// 1. REMOVE the old import
// import 'package:alumbus/src/screens/directory_screen.dart';
// 1. ADD the new import for your home screen
import 'package:alumbus/src/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 2. CHANGE THIS WIDGET
        // User is logged in, show the new HomeScreen with the menu
        return const HomeScreen();
      },
    );
  }
}