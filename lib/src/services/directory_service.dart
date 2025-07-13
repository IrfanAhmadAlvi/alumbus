// lib/src/services/directory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class DirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This is the new method to update a user's profile data
  Future<void> updateAlumProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('alumniProfiles').doc(userId).update(data);
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
