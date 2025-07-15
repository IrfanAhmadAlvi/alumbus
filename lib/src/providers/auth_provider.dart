import 'package:firebase_auth/firebase_auth.dart'; // Import this to use the User type
import 'package:flutter/material.dart';
import 'package:alumbus/src/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- THIS IS THE FIX ---
  // Add a getter to access the current user from the AuthService
  User? get currentUser => _authService.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
