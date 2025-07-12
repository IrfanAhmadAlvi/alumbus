// lib/src/auth/auth_service.dart
import 'package:alumbus/src/services/directory_service.dart'; // Import DirectoryService
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Create an instance of DirectoryService to use its methods
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

  // THIS METHOD IS NOW UPDATED
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName, // 1. ADD the fullName parameter
  }) async {
    try {
      // 2. First, create the user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. If successful, create the user's profile document in Firestore
      if (userCredential.user != null) {
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
