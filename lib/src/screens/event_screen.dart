import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
      ),
      body: const Center(
        child: Text(
          "Event details will be shown here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
