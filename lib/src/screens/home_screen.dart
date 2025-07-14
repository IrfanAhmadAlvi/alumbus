import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/providers/auth_provider.dart';
import 'package:alumbus/src/providers/directory_provider.dart';
import 'package:alumbus/src/screens/directory_screen.dart';
import 'package:alumbus/src/screens/event_screen.dart';
import 'package:alumbus/src/screens/profile_screen.dart';
import 'package:alumbus/src/services/directory_service.dart';
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
            onTap: () async {
              final currentUserId = AuthService().currentUser?.uid;
              if (currentUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Could not identify current user.")),
                );
                return;
              }

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final Alum? currentUserProfile = await DirectoryService().getAlumById(currentUserId);

                Navigator.of(context).pop(); // Hide loading indicator

                if (currentUserProfile != null) {
                  // THIS IS THE FIX: Changed 'alum' to 'initialAlum'
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(initialAlum: currentUserProfile),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Your profile could not be found.")),
                  );
                }
              } catch (e) {
                Navigator.of(context).pop(); // Hide loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("An error occurred. Please try again.")),
                );
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
