// lib/src/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Alum {
  // --- Basic Info ---
  final String id;
  final String fullName;
  final String batch;
  final String profession;
  final String company;
  final String location;
  final String profilePictureUrl;

  // --- Contact Info from Profile Screen ---
  final String primaryPhone;
  final String primaryEmail;
  final String dateOfBirth;
  final String petName;
  final String secondaryPhone;
  final String secondaryEmail;

  Alum({
    required this.id,
    required this.fullName,
    required this.batch,
    required this.profession,
    required this.company,
    required this.location,
    required this.profilePictureUrl,
    required this.primaryPhone,
    required this.primaryEmail,
    required this.dateOfBirth,
    required this.petName,
    required this.secondaryPhone,
    required this.secondaryEmail,
  });

  // This factory constructor creates an Alum object from a Firestore document.
  // It now includes all the fields your profile screen needs.
  factory Alum.fromFirestore(DocumentSnapshot doc) {
    // Reads the data from the Firestore document
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Alum(
      id: doc.id,
      // The '??' provides a default value if the field doesn't exist in the database,
      // which prevents the app from crashing.
      fullName: data['fullName'] ?? 'N/A',
      batch: data['batch'] ?? 'N/A',
      profession: data['profession'] ?? 'N/A',
      company: data['company'] ?? 'N/A',
      location: data['location'] ?? 'N/A',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      primaryPhone: data['primaryPhone'] ?? '',
      primaryEmail: data['primaryEmail'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      petName: data['petName'] ?? '',
      secondaryPhone: data['secondaryPhone'] ?? '',
      secondaryEmail: data['secondaryEmail'] ?? '',
    );
  }
}
