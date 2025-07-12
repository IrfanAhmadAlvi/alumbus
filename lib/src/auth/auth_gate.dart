import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/auth/login_screen.dart';
import 'package:alumbus/src/screens/directory_screen.dart';

class AuthGate extends StatelessWidget {
   AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // FIX 1: AuthService() needs parentheses to create an instance.
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Center(child: CircularProgressIndicator());
        }

        // User is not logged in
        if (!snapshot.hasData) {
          // FIX 2: This now correctly refers to the real LoginScreen.
          return LoginScreen();
        }

        // User is logged in
        return DirectoryScreen();
      },
    );
  }
}