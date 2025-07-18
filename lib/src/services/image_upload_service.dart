import 'dart:io';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final DirectoryService _directoryService = DirectoryService();

  static const String _cloudName = "drmoabnvv";
  static const String _uploadPreset = "alumbus_uploads";
  final CloudinaryPublic _cloudinary =
  CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  /// Takes a large image file and compresses it aggressively.
  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 25,
      minWidth: 640,
      minHeight: 640,
    );

    if (result == null) return null;

    final compressedFile = File(result.path);

    print('Original image size: ${file.lengthSync()} bytes');
    print('Compressed image size: ${compressedFile.lengthSync()} bytes');

    return compressedFile;
  }

  /// For picking IMAGES from the gallery and compressing them.
  Future<File?> pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    return await _compressImage(File(pickedFile.path));
  }

  /// For picking generic FILES. If the file is an image, it gets compressed.
  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    final fileExtension = p.extension(file.path).toLowerCase();

    if (['.png', '.jpg', '.jpeg'].contains(fileExtension)) {
      return await _compressImage(file);
    } else {
      return file;
    }
  }

  /// For Profile Pictures.
  Future<String> uploadProfilePicture(File image, String userId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: 'profile_pictures'));

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

  /// For Event Banners.
  Future<String> uploadEventBanner(File image) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: 'event_banners'));

      if (response.secureUrl.isNotEmpty) {
        return response.secureUrl;
      } else {
        throw Exception('Cloudinary upload failed: No URL was returned.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// For Notice Files.
  Future<Map<String, String>> uploadNoticeFile(File file) async {
    try {
      final fileName = p.basename(file.path);
      CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(file.path,
              folder: 'notices', resourceType: CloudinaryResourceType.Auto));

      if (response.secureUrl.isNotEmpty) {
        return {
          'fileName': fileName,
          'downloadUrl': response.secureUrl,
        };
      } else {
        throw Exception('Cloudinary upload failed: No URL was returned.');
      }
    } catch (e) {
      rethrow;
    }
  }
}