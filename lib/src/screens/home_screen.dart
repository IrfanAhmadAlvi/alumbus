import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/providers/auth_provider.dart';
import 'package:alumbus/src/providers/directory_provider.dart';
import 'package:alumbus/src/screens/directory_screen.dart';
import 'package:alumbus/src/screens/event_screen.dart';
import 'package:alumbus/src/screens/profile_screen.dart';
import 'package:alumbus/src/widgets/home_menu_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch alumni data when the home screen is first loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DirectoryProvider>(context, listen: false).fetchAlumni();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alumbus Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          HomeMenuCard(
            title: "Find Alumni",
            icon: Icons.search,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DirectoryScreen(),
              ));
            },
          ),
          HomeMenuCard(
            title: "Events",
            icon: Icons.event,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EventScreen(),
              ));
            },
          ),
          HomeMenuCard(
            title: "My Profile",
            icon: Icons.person,
            onTap: () {
              // Get the DirectoryProvider to access the list of all users.
              final directoryProvider = Provider.of<DirectoryProvider>(context, listen: false);

              // Get the current user's unique ID from Firebase Auth.
              final currentUserId = AuthService().currentUser?.uid;

              if (currentUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not identify current user.")),
                );
                return;
              }

              // First, check if the data is still loading.
              if (directoryProvider.isLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile data is loading, please wait...")),
                );
                return;
              }

              try {
                // Find the profile that matches the current user's ID.
                final Alum currentUserProfile = directoryProvider.alumni.firstWhere(
                      (alum) => alum.id == currentUserId,
                );

                // Navigate to the ProfileScreen, correctly passing the profile data.
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfileScreen(alum: currentUserProfile),
                ));
              } catch (e) {
                // --- THIS IS THE SELF-HEALING FIX ---
                // If the user's profile isn't found, it's likely a data sync issue.
                // Inform the user and trigger a refresh.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Refreshing directory. Please try again in a moment.")),
                );
                // Trigger a new fetch to get the latest data.
                directoryProvider.fetchAlumni();
              }
            },
          ),
          HomeMenuCard(
            title: "News & Updates",
            icon: Icons.article,
            onTap: () {
              // TODO: Navigate to News Screen
            },
          ),
        ],
      ),
    );
  }
}
