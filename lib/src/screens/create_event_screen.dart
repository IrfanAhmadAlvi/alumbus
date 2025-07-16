import 'dart:io';
import 'package:alumbus/src/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageService = ImageUploadService();
    final imageFile = await imageService.pickImage();
    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select an image, date, and time."),
          backgroundColor: Colors.redAccent));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageService = ImageUploadService();
      final imageUrl = await imageService.uploadEventBanner(_selectedImage!);

      // Correctly format the TimeOfDay into a 12-hour string with AM/PM
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
      final formattedTime = DateFormat("h:mm a").format(dt);

      await FirebaseFirestore.instance.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'eventDate': Timestamp.fromDate(_selectedDate!),
        'startTime': formattedTime, // Save the correctly formatted time
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Event created successfully!"),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to create event: $e"),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Event"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                    image: _selectedImage != null
                        ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover)
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tap to upload a banner image"),
                      ],
                    ),
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Event Title"),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _descriptionController,
                  decoration:
                  const InputDecoration(labelText: "Event Description"),
                  maxLines: 4,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a description' : null),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date chosen'
                          : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Choose Date'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'No time chosen'
                          : 'Time: ${_selectedTime!.format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Choose Time'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("SAVE EVENT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}