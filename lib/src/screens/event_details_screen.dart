import 'package:alumbus/src/screens/edit_event_screen.dart';
import 'package:alumbus/src/screens/event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for delete
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;
  final bool isAdmin;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.isAdmin,
  });

  // --- METHOD TO HANDLE DELETING AN EVENT ---
  Future<void> _deleteEvent(BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this event?'),
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
        await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
        // Pop back to the event list screen after successful deletion
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event deleted successfully."), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete event: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: "Edit Event",
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditEventScreen(event: event),
                ));
              },
            ),
          // --- DELETE BUTTON ADDED FOR ADMINS ---
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Delete Event",
              onPressed: () => _deleteEvent(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              Image.network(
                event.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                      height: 250,
                      child: Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: Colors.grey)));
                },
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DateFormat.yMMMMEEEEd().format(event.eventDate),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time_outlined,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        event.startTime,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  const Text(
                    "About this event",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}