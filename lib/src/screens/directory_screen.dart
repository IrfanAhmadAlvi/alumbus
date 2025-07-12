// lib/src/screens/directory_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alumbus/src/providers/directory_provider.dart';
import 'package:alumbus/src/widgets/alum_card.dart';
import 'package:alumbus/src/auth/auth_service.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch alumni data when the screen is first loaded
    // Use a post-frame callback to ensure the provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DirectoryProvider>(context, listen: false).fetchAlumni();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alumni Directory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
      body: Consumer<DirectoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text("An error occurred: ${provider.errorMessage}"));
          }

          if (provider.alumni.isEmpty) {
            return const Center(child: Text("No alumni found in the directory."));
          }

          return ListView.builder(
            itemCount: provider.alumni.length,
            itemBuilder: (context, index) {
              final alum = provider.alumni[index];
              return AlumCard(alum: alum);
            },
          );
        },
      ),
    );
  }
}