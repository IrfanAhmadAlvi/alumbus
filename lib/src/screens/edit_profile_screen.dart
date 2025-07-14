import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/services/directory_service.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Alum alum;

  const EditProfileScreen({super.key, required this.alum});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _fullNameController;
  late TextEditingController _batchController;
  late TextEditingController _professionController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _secondaryEmailController;


  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.alum.fullName);
    _batchController = TextEditingController(text: widget.alum.batch);
    _professionController = TextEditingController(text: widget.alum.profession);
    _companyController = TextEditingController(text: widget.alum.company);
    _locationController = TextEditingController(text: widget.alum.location);
    _primaryPhoneController = TextEditingController(text: widget.alum.primaryPhone);
    _dateOfBirthController = TextEditingController(text: widget.alum.dateOfBirth);
    _bloodGroupController = TextEditingController(text: widget.alum.bloodGroup);
    _secondaryPhoneController = TextEditingController(text: widget.alum.secondaryPhone);
    _secondaryEmailController = TextEditingController(text: widget.alum.secondaryEmail);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _batchController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _primaryPhoneController.dispose();
    _dateOfBirthController.dispose();
    _bloodGroupController.dispose();
    _secondaryPhoneController.dispose();
    _secondaryEmailController.dispose();
    super.dispose();
  }

  void _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isSaving = true; });

      final Map<String, dynamic> updatedData = {
        'fullName': _fullNameController.text,
        'batch': _batchController.text,
        'profession': _professionController.text,
        'company': _companyController.text,
        'location': _locationController.text,
        'primaryPhone': _primaryPhoneController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'bloodGroup': _bloodGroupController.text,
        'secondaryPhone': _secondaryPhoneController.text,
        'secondaryEmail': _secondaryEmailController.text,
      };

      try {
        await DirectoryService().updateAlumProfile(widget.alum.id, updatedData);
        setState(() { _isSaving = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() { _isSaving = false; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update profile: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _handleSaveChanges,
              tooltip: "Save Changes",
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(controller: _fullNameController, label: "Full Name", icon: Icons.person_outline),
                _buildTextField(controller: _batchController, label: "Batch", icon: Icons.school_outlined),
                _buildTextField(controller: _professionController, label: "Profession", icon: Icons.work_outline),
                _buildTextField(controller: _companyController, label: "Company", icon: Icons.business_center_outlined),
                _buildTextField(controller: _locationController, label: "Location", icon: Icons.location_on_outlined),
                // --- THIS FIELD IS NOW OPTIONAL ---
                _buildTextField(controller: _primaryPhoneController, label: "Primary Phone Optional", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, isRequired: false),
                _buildTextField(controller: _dateOfBirthController, label: "Date of Birth", icon: Icons.calendar_today_outlined),
                _buildTextField(controller: _bloodGroupController, label: "Blood Group", icon: Icons.bloodtype_outlined),

                _buildTextField(controller: _secondaryEmailController, label: "Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, isRequired: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true, // Add a parameter to handle optional fields
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          // Only validate if the field is required
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
