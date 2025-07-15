import 'dart:async';
import 'package:alumbus/src/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Check initial verification status
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // If not verified, send the email and start checking
    if (!_isEmailVerified) {
      sendVerificationEmail();

      // Start a timer to check verification status every 3 seconds
      _timer = Timer.periodic(
        const Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    // Be sure to cancel the timer when the screen is disposed
    _timer?.cancel();
    super.dispose();
  }

  /// Checks the user's latest verification status from Firebase.
  Future<void> checkEmailVerified() async {
    // You must reload the user to get the latest emailVerified state
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    // If the email is now verified, the timer can be stopped.
    // The AuthGate will automatically navigate to the home screen.
    if (_isEmailVerified) {
      _timer?.cancel();
    }
  }

  /// Sends the verification email and enables the resend button after a short cooldown.
  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      // Disable the resend button temporarily to prevent spamming
      setState(() => _canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() => _canResendEmail = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The AuthGate handles navigation, so this screen just shows the UI.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.indigo),
            const SizedBox(height: 24),
            const Text(
              "Check Your Email",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "We've sent a verification link to:\n${FirebaseAuth.instance.currentUser?.email}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Resend Link"),
              onPressed: _canResendEmail ? sendVerificationEmail : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => AuthService().signOut(),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}