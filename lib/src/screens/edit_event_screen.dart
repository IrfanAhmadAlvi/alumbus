import 'dart:io';
import 'package:alumbus/src/screens/event_screen.dart';
import 'package:alumbus/src/services/image_upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;
  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  File? _selectedImage;
  String? _existingImageUrl;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _selectedDate = widget.event.eventDate;
    _existingImageUrl = widget.event.imageUrl;

    if (widget.event.startTime.isNotEmpty) {
      // --- THIS IS THE FIX ---
      // Use the exact same format "h:mm a" for parsing the time string
      // that we used for saving it.
      final format = DateFormat("h:mm a");
      _selectedTime =
          TimeOfDay.fromDateTime(format.parse(widget.event.startTime));
    }
  }

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
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_selectedImage != null) {
        final imageService = ImageUploadService();
        imageUrl = await imageService.uploadEventBanner(_selectedImage!);
      }

      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, _selectedTime!.hour,
          _selectedTime!.minute);
      final formattedTime = DateFormat("h:mm a").format(dt);

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'eventDate': Timestamp.fromDate(_selectedDate!),
        'startTime': formattedTime,
        'imageUrl': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Event updated successfully!"),
            backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Failed to update event: $e"),
            backgroundColor: Colors.redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Event"),
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
                        : (_existingImageUrl != null &&
                        _existingImageUrl!.isNotEmpty)
                        ? DecorationImage(
                        image: NetworkImage(_existingImageUrl!),
                        fit: BoxFit.cover)
                        : null,
                  ),
                  child: (_selectedImage == null &&
                      (_existingImageUrl == null ||
                          _existingImageUrl!.isEmpty))
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tap to change banner image"),
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
                onPressed: _updateEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("UPDATE EVENT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}