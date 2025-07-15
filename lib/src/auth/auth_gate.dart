import 'package:alumbus/src/auth/login_screen.dart';
import 'package:alumbus/src/auth/verify_email_screen.dart';
import 'package:alumbus/src/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // --- THIS IS THE CORRECTED LINE ---
        // Replace 'AuthService().authStateChanges' with 'FirebaseAuth.instance.userChanges()'
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If the user is not logged in, show the login screen
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // If the user is logged in, check if their email is verified
          final user = snapshot.data!;

          if (user.emailVerified) {
            // If verified, grant access to the main app
            return const HomeScreen();
          } else {
            // If not verified, show the verification screen
            return const VerifyEmailScreen();
          }
        },
      ),
    );
  }
}