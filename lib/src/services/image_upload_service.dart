import 'dart:io';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final DirectoryService _directoryService = DirectoryService();

  static const String _cloudName = "drmoabnvv";
  static const String _uploadPreset = "alumbus_uploads";
  final CloudinaryPublic _cloudinary =
  CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  Future<File?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// For Profile Pictures ONLY. It updates the user's profile.
  Future<String> uploadProfilePicture(File image, String userId) async {
    try {
      CloudinaryResponse response = await _cloudinary
          .uploadFile(CloudinaryFile.fromFile(image.path, folder: 'profile_pictures'));

      if (response.secureUrl.isNotEmpty) {
        final downloadUrl = response.secureUrl;
        await _directoryService
            .updateAlumProfile(userId, {'profilePictureUrl': downloadUrl});
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadUrl);
        return downloadUrl;
      } else {
        throw Exception('Cloudinary upload failed: No URL was returned.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// For Event Banners ONLY. It just returns the URL.
  Future<String> uploadEventBanner(File image) async {
    try {
      CloudinaryResponse response = await _cloudinary
          .uploadFile(CloudinaryFile.fromFile(image.path, folder: 'event_banners'));

      if (response.secureUrl.isNotEmpty) {
        return response.secureUrl; // Just return the URL
      } else {
        throw Exception('Cloudinary upload failed: No URL was returned.');
      }
    } catch (e) {
      rethrow;
    }
  }
}