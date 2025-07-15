import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:flutter/material.dart';

class EditAboutMeScreen extends StatefulWidget {
  final Alum alum;

  const EditAboutMeScreen({super.key, required this.alum});

  @override
  State<EditAboutMeScreen> createState() => _EditAboutMeScreenState();
}

class _EditAboutMeScreenState extends State<EditAboutMeScreen> {
  late TextEditingController _aboutMeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _aboutMeController = TextEditingController(text: widget.alum.aboutMe);
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await DirectoryService().updateAlumProfile(
        widget.alum.id,
        {'aboutMe': _aboutMeController.text},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bio updated successfully!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update bio: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit About Me"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSaveChanges,
              tooltip: "Save Changes",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: _aboutMeController,
          decoration: const InputDecoration(
            labelText: "About Me (Bio)",
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            hintText: "Tell everyone a little bit about yourself...",
          ),
          keyboardType: TextInputType.multiline,
          maxLines: 10,
          minLines: 5,
        ),
      ),
    );
  }
}