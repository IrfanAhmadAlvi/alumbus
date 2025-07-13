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
  bool _isSaving = false; // Add a state variable for loading

  // Create controllers for each text field
  late TextEditingController _fullNameController;
  late TextEditingController _batchController;
  late TextEditingController _professionController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _petNameController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing user data
    _fullNameController = TextEditingController(text: widget.alum.fullName);
    _batchController = TextEditingController(text: widget.alum.batch);
    _professionController = TextEditingController(text: widget.alum.profession);
    _companyController = TextEditingController(text: widget.alum.company);
    _locationController = TextEditingController(text: widget.alum.location);
    _primaryPhoneController = TextEditingController(text: widget.alum.primaryPhone);
    _dateOfBirthController = TextEditingController(text: widget.alum.dateOfBirth);
    _petNameController = TextEditingController(text: widget.alum.petName);
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _fullNameController.dispose();
    _batchController.dispose();
    _professionController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _primaryPhoneController.dispose();
    _dateOfBirthController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  // This method now handles saving the data to Firestore
  void _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true; // Start loading
      });

      // Create a map of the updated data from the controllers
      final Map<String, dynamic> updatedData = {
        'fullName': _fullNameController.text,
        'batch': _batchController.text,
        'profession': _professionController.text,
        'company': _companyController.text,
        'location': _locationController.text,
        'primaryPhone': _primaryPhoneController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'petName': _petNameController.text,
      };

      try {
        // Call the service method to update the data in Firestore
        await DirectoryService().updateAlumProfile(widget.alum.id, updatedData);

        setState(() {
          _isSaving = false; // Stop loading
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.of(context).pop(); // Go back to the profile screen
        }
      } catch (e) {
        setState(() {
          _isSaving = false; // Stop loading
        });
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
          // Show a progress indicator while saving
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
                _buildTextField(
                  controller: _fullNameController,
                  label: "Full Name",
                  icon: Icons.person_outline,
                ),
                _buildTextField(
                  controller: _batchController,
                  label: "Batch (e.g., 1995)",
                  icon: Icons.school_outlined,
                ),
                _buildTextField(
                  controller: _professionController,
                  label: "Profession",
                  icon: Icons.work_outline,
                ),
                _buildTextField(
                  controller: _companyController,
                  label: "Company",
                  icon: Icons.business_center_outlined,
                ),
                _buildTextField(
                  controller: _locationController,
                  label: "Location",
                  icon: Icons.location_on_outlined,
                ),
                _buildTextField(
                  controller: _primaryPhoneController,
                  label: "Primary Phone",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  controller: _dateOfBirthController,
                  label: "Date of Birth",
                  icon: Icons.calendar_today_outlined,
                ),
                _buildTextField(
                  controller: _petNameController,
                  label: "Pet Name",
                  icon: Icons.pets_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to avoid repetitive code for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          if (value == null || value.isEmpty) {
            // This validation can be customized for optional fields
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
