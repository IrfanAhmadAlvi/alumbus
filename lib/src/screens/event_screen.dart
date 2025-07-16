import 'package:alumbus/src/screens/create_event_screen.dart';
import 'package:alumbus/src/screens/edit_event_screen.dart';
import 'package:alumbus/src/screens/event_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Event data model (no changes here)
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String imageUrl;
  final String startTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.imageUrl,
    required this.startTime,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      startTime: data['startTime'] ?? '',
    );
  }
}

class EventScreen extends StatefulWidget {
  final bool isAdmin;
  const EventScreen({super.key, required this.isAdmin});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  // --- METHOD TO HANDLE DELETING AN EVENT ---
  Future<void> _deleteEvent(String eventId) async {
    // Show a confirmation dialog before deleting
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
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

    // If the user confirmed, proceed with deletion
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Event deleted successfully."), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete event: $e"), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
        tooltip: "Create New Event",
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const CreateEventScreen(),
          ));
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('eventDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No upcoming events."));
          }

          final events = snapshot.data!.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: events.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                margin:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(
                          event: event, isAdmin: widget.isAdmin),
                    ));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (event.imageUrl.isNotEmpty)
                        Image.network(
                          event.imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                                height: 150,
                                child: Center(
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey)));
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(event.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(DateFormat('d MMM, yyyy')
                                    .format(event.eventDate)),
                                const Spacer(),
                                Icon(Icons.access_time_outlined,
                                    size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(event.startTime)
                              ],
                            )
                          ],
                        ),
                      ),
                      if (widget.isAdmin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text("Edit"),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.indigo,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      EditEventScreen(event: event),
                                ));
                              },
                            ),
                            // --- DELETE BUTTON ADDED FOR ADMINS ---
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: "Delete Event",
                              onPressed: () => _deleteEvent(event.id),
                            ),
                          ],
                        ),
                      if (!widget.isAdmin)
                        const SizedBox(height: 12),
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