import 'package:alumbus/src/services/directory_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DirectoryService _directoryService = DirectoryService();

  /// A stream that notifies about changes to the user's sign-in state.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently signed-in user, if any.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with their email and password.
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

  /// Registers a new user, sends a verification email, and creates their profile.
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update the user's profile display name in Firebase Auth
        await user.updateDisplayName(fullName);

        // Send the verification email
        await user.sendEmailVerification();

        // Create the corresponding user profile document in Firestore
        await _directoryService.createUserProfile(user, fullName);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a password reset link to the specified email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}