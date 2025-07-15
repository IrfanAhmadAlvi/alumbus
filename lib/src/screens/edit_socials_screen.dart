import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:flutter/material.dart';

class EditSocialsScreen extends StatefulWidget {
  final Alum alum;
  const EditSocialsScreen({super.key, required this.alum});

  @override
  State<EditSocialsScreen> createState() => _EditSocialsScreenState();
}

class _EditSocialsScreenState extends State<EditSocialsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _linkedinController;
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _githubController;
  late TextEditingController _youtubeController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _linkedinController = TextEditingController(text: widget.alum.linkedinUrl);
    _websiteController = TextEditingController(text: widget.alum.websiteUrl);
    _facebookController = TextEditingController(text: widget.alum.facebookUrl);
    _instagramController = TextEditingController(text: widget.alum.instagramUrl);
    _githubController = TextEditingController(text: widget.alum.githubUrl);
    _youtubeController = TextEditingController(text: widget.alum.youtubeUrl);
  }

  @override
  void dispose() {
    _linkedinController.dispose();
    _websiteController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _githubController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });

    final Map<String, dynamic> updatedData = {
      'linkedinUrl': _linkedinController.text.trim(),
      'websiteUrl': _websiteController.text.trim(),
      'facebookUrl': _facebookController.text.trim(),
      'instagramUrl': _instagramController.text.trim(),
      'githubUrl': _githubController.text.trim(),
      'youtubeUrl': _youtubeController.text.trim(),
    };

    try {
      await DirectoryService().updateAlumProfile(widget.alum.id, updatedData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Social links updated!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update links: $e")),
        );
      }
    } finally {
      if(mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Social Links"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSaveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _linkedinController, label: "LinkedIn URL", icon: Icons.link),
              _buildTextField(controller: _websiteController, label: "Website URL", icon: Icons.language),
              _buildTextField(controller: _facebookController, label: "Facebook URL", icon: Icons.link),
              _buildTextField(controller: _instagramController, label: "Instagram URL", icon: Icons.link),
              _buildTextField(controller: _githubController, label: "GitHub URL", icon: Icons.link),
              _buildTextField(controller: _youtubeController, label: "YouTube URL", icon: Icons.link),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        keyboardType: TextInputType.url,
      ),
    );
  }
}