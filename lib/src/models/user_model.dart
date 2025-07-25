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
  final String bloodGroup; // REPLACED petName
  final String secondaryPhone;
  final String secondaryEmail;
  final String aboutMe;

  // --- 1. ADD NEW SOCIAL MEDIA FIELDS ---
  final String linkedinUrl;
  final String facebookUrl;
  final String instagramUrl;
  final String githubUrl;
  final String youtubeUrl;
  final String websiteUrl;

  final bool isAdmin;


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
    required this.bloodGroup,
    required this.secondaryPhone,
    required this.secondaryEmail,
    required this.aboutMe,

    // --- 2. ADD TO CONSTRUCTOR ---
    required this.linkedinUrl,
    required this.facebookUrl,
    required this.instagramUrl,
    required this.githubUrl,
    required this.youtubeUrl,
    required this.websiteUrl,
    required this.isAdmin,
  });

  factory Alum.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Alum(
      id: doc.id,
      fullName: data['fullName'] ?? 'N/A',
      batch: data['batch'] ?? 'N/A',
      profession: data['profession'] ?? 'N/A',
      company: data['company'] ?? 'N/A',
      location: data['location'] ?? 'N/A',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      primaryPhone: data['primaryPhone'] ?? '',
      primaryEmail: data['primaryEmail'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      bloodGroup: data['bloodGroup'] ?? '', // REPLACED petName
      secondaryPhone: data['secondaryPhone'] ?? '',
      secondaryEmail: data['secondaryEmail'] ?? '',
      aboutMe: data['aboutMe'] ?? '',


      // --- 3. ASSIGN FROM FIRESTORE ---
      linkedinUrl: data['linkedinUrl'] ?? '',
      facebookUrl: data['facebookUrl'] ?? '',
      instagramUrl: data['instagramUrl'] ?? '',
      githubUrl: data['githubUrl'] ?? '',
      youtubeUrl: data['youtubeUrl'] ?? '',
      websiteUrl: data['websiteUrl'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }
}
