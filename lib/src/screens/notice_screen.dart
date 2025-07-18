import 'package:alumbus/src/screens/upload_notice_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

// Notice data model (no changes here)
class Notice {
  final String id;
  final String title;
  final String downloadUrl;
  final String fileName;
  final Timestamp uploadedAt;
  Notice({required this.id, required this.title, required this.downloadUrl, required this.fileName, required this.uploadedAt});

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      fileName: data['fileName'] ?? '',
      uploadedAt: data['uploadedAt'] as Timestamp,
    );
  }
}


class NoticeScreen extends StatelessWidget {
  final bool isAdmin;
  const NoticeScreen({super.key, required this.isAdmin});

  // --- 2. THIS METHOD IS NOW UPDATED TO "DOWNLOAD AND OPEN" ---
  Future<void> _downloadAndOpenFile(BuildContext context, String url, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $fileName...')),
      );

      // First, download the file using dio
      await Dio().download(url, savePath);

      // After downloading, open the file using open_filex
      final result = await OpenFilex.open(savePath);

      // Show a message based on whether the file could be opened
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download or open file: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _deleteNotice(BuildContext context, String noticeId) async {
    // ... (delete logic is unchanged)
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
              final notice = Notice.fromFirestore(doc);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.indigo),
                  title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(notice.fileName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- 3. ICON AND FUNCTIONALITY UPDATED ---
                      IconButton(
                        icon: const Icon(Icons.open_in_new), // Changed icon
                        tooltip: "Download & Open",
                        onPressed: () => _downloadAndOpenFile(context, notice.downloadUrl, notice.fileName),
                      ),
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