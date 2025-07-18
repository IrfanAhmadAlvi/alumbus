import 'dart:io';
import 'package:alumbus/src/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class UploadNoticeScreen extends StatefulWidget {
  const UploadNoticeScreen({super.key});

  @override
  State<UploadNoticeScreen> createState() => _UploadNoticeScreenState();
}

class _UploadNoticeScreenState extends State<UploadNoticeScreen> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _uploadService = ImageUploadService(); // Use the existing service

  File? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final file = await _uploadService.pickFile(); // Use the new pickFile method
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _uploadNotice() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a title and select a file.'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new upload method for notice files
      final uploadResult = await _uploadService.uploadNoticeFile(_selectedFile!);
      final fileName = uploadResult['fileName'];
      final downloadUrl = uploadResult['downloadUrl'];

      // Save the notice metadata to Firestore
      await FirebaseFirestore.instance.collection('notices').add({
        'title': _titleController.text.trim(),
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Notice uploaded successfully!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload notice: $e'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload New Notice"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Notice Title"),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text("Select File (PDF, DOC, JPG, etc.)"),
                onPressed: _pickFile,
              ),
              const SizedBox(height: 12),
              if (_selectedFile != null)
                Text('Selected: ${p.basename(_selectedFile!.path)}',
                    textAlign: TextAlign.center),
              const Spacer(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _uploadNotice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("UPLOAD NOTICE"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}