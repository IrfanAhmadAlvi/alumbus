import 'dart:io';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. IMPORT FIREBASE AUTH
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final DirectoryService _directoryService = DirectoryService();

  static const String _cloudName = "drmoabnvv";
  static const String _uploadPreset = "alumbus_uploads";
  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  Future<String> uploadProfilePicture(File image, String userId) async {
    try {
      CloudinaryFile file = await CloudinaryFile.fromFile(image.path,
          resourceType: CloudinaryResourceType.Image);

      CloudinaryResponse response = await _cloudinary.uploadFile(file);

      if (response.secureUrl.isNotEmpty) {
        final downloadUrl = response.secureUrl;

        // Update the URL in the user's Firestore document
        await _directoryService.updateAlumProfile(userId, {'profilePictureUrl': downloadUrl});

        // 2. --- THIS IS THE FIX ---
        // Also update the photoURL on the core Firebase Auth user record.
        // This makes it available immediately throughout the app.
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);

        return downloadUrl;
      } else {
        throw Exception('Cloudinary upload failed: No URL was returned.');
      }

    } catch (e) {
      print("Error uploading profile picture to Cloudinary: $e");
      rethrow;
    }
  }
}