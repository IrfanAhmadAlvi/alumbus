import 'package:flutter/material.dart';
import 'package:alumbus/src/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
  }

  // THIS METHOD IS NOW UPDATED
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName, // The required fullName parameter is now added
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      // The fullName is now correctly passed to the auth service
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
