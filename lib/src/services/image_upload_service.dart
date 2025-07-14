import 'dart:io';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final DirectoryService _directoryService = DirectoryService();

  // --- YOUR CLOUD NAME IS NOW ADDED ---
  static const String _cloudName = "drmoabnvv";

  // You need to create an 'unsigned' upload preset in your Cloudinary settings
  // and name it 'alumbus_uploads'.
  static const String _uploadPreset = "alumbus_uploads";

  // Initialize Cloudinary with your credentials
  final CloudinaryPublic _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  // Method to pick an image from the user's gallery
  Future<File?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress image
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

  // Method to upload the picked image to Cloudinary
  Future<String> uploadProfilePicture(File image, String userId) async {
    try {
      // Create a Cloudinary resource object from the file
      CloudinaryFile file = await CloudinaryFile.fromFile(image.path,
          resourceType: CloudinaryResourceType.Image);

      // Perform the unsigned upload
      CloudinaryResponse response = await _cloudinary.uploadFile(file);

      // --- THIS IS THE FIX ---
      // The properties on the response object were changed in this package version.
      // We now check if the secureUrl is not empty.
      // The uploadFile method will throw an exception on failure, which is caught below.
      if (response.secureUrl.isNotEmpty) {
        final downloadUrl = response.secureUrl;

        // Update the URL in the user's Firestore document
        await _directoryService.updateAlumProfile(userId, {'profilePictureUrl': downloadUrl});

        return downloadUrl;
      } else {
        // This case is unlikely if no exception was thrown, but it's good to handle.
        throw Exception('Cloudinary upload failed: No URL was returned.');
      }

    } catch (e) {
      print("Error uploading profile picture to Cloudinary: $e");
      rethrow;
    }
  }
}
