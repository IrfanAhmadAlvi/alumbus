// lib/src/services/directory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alumbus/src/models/user_model.dart';

import '../models/user_model.dart'; // Our Alum model

class DirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all alumni profiles
  Future<List<Alum>> getAlumni() async {
    try {
      final snapshot = await _firestore.collection('alumniProfiles').get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      // Map each document to an Alum object
      return snapshot.docs.map((doc) => Alum.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching alumni: $e");
      rethrow;
    }
  }
}