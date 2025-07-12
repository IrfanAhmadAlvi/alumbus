// lib/src/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Alum {
  final String id;
  final String fullName;
  final String batch;
  final String profession;
  final String company;
  final String profilePictureUrl;

  Alum({
    required this.id,
    required this.fullName,
    required this.batch,
    required this.profession,
    required this.company,
    required this.profilePictureUrl,
  });

  // A factory constructor to create an Alum from a Firestore document
  factory Alum.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Alum(
      id: doc.id,
      fullName: data['fullName'] ?? 'N/A',
      batch: data['batch'] ?? 'N/A',
      profession: data['profession'] ?? 'N/A',
      company: data['company'] ?? 'N/A',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
    );
  }
}