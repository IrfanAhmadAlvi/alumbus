import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class FileStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Allows the user to pick a file (e.g., PDF, DOCX).
  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
    );
    if (result == null || result.files.single.path == null) {
      return null;
    }
    return File(result.files.single.path!);
  }

  /// Uploads the selected file to Firebase Storage and returns the download URL.
  Future<String> uploadNoticeFile(File file, String fileName) async {
    try {
      final ref = _storage.ref('notices/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading notice file: $e");
      rethrow;
    }
  }
}