// lib/src/auth/auth_service.dart
import 'package:alumbus/src/services/directory_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DirectoryService _directoryService = DirectoryService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // --- THIS METHOD IS NOW UPDATED ---
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // First, create the user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If the user was created successfully, update their profile
      if (userCredential.user != null) {
        // --- THIS IS THE FIX ---
        // Update the user's display name in Firebase Auth
        await userCredential.user?.updateDisplayName(fullName);

        // Then, create the user's profile document in Firestore as before
        await _directoryService.createUserProfile(userCredential.user!, fullName);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}