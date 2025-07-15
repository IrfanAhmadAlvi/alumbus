// lib/src/services/directory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class DirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- THIS METHOD IS NOW UPDATED ---
  Future<void> updateAlumProfile(String userId, Map<String, dynamic> data) async {
    try {
      // 1. First, update the Firestore document as before.
      await _firestore.collection('alumniProfiles').doc(userId).update(data);

      // 2. --- THIS IS THE FIX ---
      // If the 'fullName' is part of the updated data, we also update
      // the displayName on the Firebase Auth user object.
      if (data.containsKey('fullName')) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(data['fullName']);
      }
    } catch (e) {
      print("Error updating alum profile: $e");
      rethrow;
    }
  }

  Future<Alum?> getAlumById(String userId) async {
    try {
      final doc = await _firestore.collection('alumniProfiles').doc(userId).get();
      if (doc.exists) {
        print('Raw Firestore Data: ${doc.data()}');
        return Alum.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print("Error fetching alum by ID: $e");
      rethrow;
    }
  }

  Future<void> createUserProfile(User user, String fullName) async {
    try {
      await _firestore.collection('alumniProfiles').doc(user.uid).set({
        'fullName': fullName,
        'email': user.email,
        'batch': 'Not Set',
        'profession': 'Not Set',
        'company': 'Not Set',
        'location': 'Not Set',
        'profilePictureUrl': '',
        'primaryPhone': '',
        'dateOfBirth': '',
        'petName': '',
        'secondaryPhone': '',
        'secondaryEmail': '',
      });
    } catch (e) {
      print("Error creating user profile: $e");
      rethrow;
    }
  }

  Future<List<Alum>> getAlumni() async {
    try {
      final snapshot = await _firestore.collection('alumniProfiles').get();
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return snapshot.docs.map((doc) => Alum.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching alumni: $e");
      rethrow;
    }
  }
}