import 'package:alumbus/src/screens/upload_notice_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// Notice data model
class Notice {
  final String id; // Added ID to make deletion easier
  final String title;
  final String downloadUrl;
  final String fileName;
  final Timestamp uploadedAt;
  Notice({required this.id, required this.title, required this.downloadUrl, required this.fileName, required this.uploadedAt});
}

class NoticeScreen extends StatelessWidget {
  final bool isAdmin;
  const NoticeScreen({super.key, required this.isAdmin});

  Future<void> _downloadFile(BuildContext context, String url, String fileName) async {
    // ... (this method is unchanged)
  }

  // --- NEW METHOD TO DELETE A NOTICE ---
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
        // This securely deletes the Firestore document.
        // A Cloud Function (see below) would be needed to delete the file from Cloudinary.
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
                id: doc.id, // Pass the document ID to the model
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
                      IconButton(
                        icon: const Icon(Icons.download_outlined),
                        tooltip: "Download",
                        onPressed: () => _downloadFile(context, notice.downloadUrl, notice.fileName),
                      ),
                      // --- DELETE BUTTON VISIBLE ONLY TO ADMINS ---
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