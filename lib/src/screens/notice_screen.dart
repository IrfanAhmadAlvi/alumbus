import 'package:alumbus/src/screens/upload_notice_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart'; // <-- 1. IMPORT PACKAGE
import 'dart:io'; // Required for Directory

// Notice data model
class Notice {
  final String id;
  final String title;
  final String downloadUrl;
  final String fileName;
  final Timestamp uploadedAt;
  Notice({required this.id, required this.title, required this.downloadUrl, required this.fileName, required this.uploadedAt});
}

class NoticeScreen extends StatelessWidget {
  final bool isAdmin;
  const NoticeScreen({super.key, required this.isAdmin});

  // --- THIS METHOD IS NOW USED BY BOTH DOWNLOAD AND OPEN ---
  Future<String?> _downloadFile(BuildContext context, String url, String fileName) async {
    try {
      final Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw Exception("Cannot get storage directory");
      }
      final String savePath = '${dir.path}/$fileName';

      // Show a dialog or a snackbar to indicate download start
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $fileName...')),
      );

      final Dio dio = Dio();
      await dio.download(url, savePath);

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide download start message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded to $savePath'), backgroundColor: Colors.green),
      );
      return savePath; // Return the path on success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e'), backgroundColor: Colors.redAccent),
      );
      return null; // Return null on failure
    }
  }

  // --- 2. NEW METHOD TO OPEN A FILE ---
  Future<void> _openFile(BuildContext context, String url, String fileName) async {
    // First, download the file and get its local path
    final String? filePath = await _downloadFile(context, url, fileName);

    // If the file was downloaded successfully, open it
    if (filePath != null) {
      final OpenResult result = await OpenFilex.open(filePath);

      // Optionally, handle the result of the open attempt
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open file: ${result.message}'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }


  Future<void> _deleteNotice(BuildContext context, String noticeId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this notice? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('notices').doc(noticeId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice deleted successfully.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notice: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Board"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadNoticeScreen()));
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.upload_file),
      )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notices').orderBy('uploadedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notices have been posted."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final notice = Notice(
                id: doc.id,
                title: doc['title'],
                downloadUrl: doc['downloadUrl'],
                fileName: doc['fileName'],
                uploadedAt: doc['uploadedAt'],
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.indigo),
                  title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notice.fileName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- 3. ADDED OPEN BUTTON ---
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: "Open",
                        onPressed: () => _openFile(context, notice.downloadUrl, notice.fileName),
                      ),
                      /*IconButton(
                        icon: const Icon(Icons.download_outlined),
                        tooltip: "Download",
                        onPressed: () => _downloadFile(context, notice.downloadUrl, notice.fileName),
                      ),*/
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: "Delete",
                          onPressed: () => _deleteNotice(context, notice.id),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}