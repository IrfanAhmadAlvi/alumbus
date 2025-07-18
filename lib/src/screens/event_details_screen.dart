import 'package:alumbus/src/screens/edit_event_screen.dart';
import 'package:alumbus/src/screens/event_screen.dart';
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
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: "Delete Event",
              onPressed: () {
                // You would need to pass or create the delete logic here
                // For simplicity, this is kept in the EventScreen for now
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
      ),
    );
  }
}