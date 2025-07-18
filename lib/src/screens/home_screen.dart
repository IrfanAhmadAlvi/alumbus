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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Night';
  }

  Future<void> _logout(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      // Use the provider to sign out to ensure state is managed correctly
      await Provider.of<AuthProvider>(context, listen: false).signOut();
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.currentUser?.displayName ?? 'User';
    final photoURL = authProvider.currentUser?.photoURL;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade400, Colors.indigo.shade800],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                  ? NetworkImage(photoURL)
                  : null,
              child: (photoURL == null || photoURL.isEmpty)
                  ? const Icon(Icons.person, color: Colors.indigo)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi $userName!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Let's connect with your community.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.groups,
                    color: Colors.indigo.withOpacity(0.6),
                    size: 60,
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Explore Alumbus",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade900,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                HomeMenuCard(
                  title: "Find Alumni",
                  subtitle: "Directory",
                  icon: Icons.search,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DirectoryScreen(),
                    ));
                  },
                ),
                HomeMenuCard(
                  title: "Events",
                  subtitle: "Upcoming",
                  icon: Icons.event,
                  // --- THIS IS THE FIX ---
                  // This onTap function now fetches the user's admin status first
                  onTap: () async {
                    // Show a loading dialog for a better user experience
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()));

                    try {
                      final currentUserId = AuthService().currentUser?.uid;
                      if (currentUserId == null) {
                        Navigator.of(context).pop(); // Close loading dialog
                        return;
                      }

                      final Alum? profile = await DirectoryService().getAlumById(currentUserId);
                      final bool userIsAdmin = profile?.isAdmin ?? false;

                      Navigator.of(context).pop(); // Close loading dialog

                      // Now navigate to EventScreen with the correct admin status
                      if(mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EventScreen(isAdmin: userIsAdmin),
                        ));
                      }
                    } catch (e) {
                      Navigator.of(context).pop(); // Close loading dialog on error
                      if(mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error fetching user data: $e"))
                        );
                      }
                    }
                  },
                ),
                HomeMenuCard(
                  title: "My Profile",
                  subtitle: "View & Edit",
                  icon: Icons.person,
                  onTap: () async {
                    final currentUserId = AuthService().currentUser?.uid;
                    if (currentUserId == null) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      final Alum? profile =
                      await DirectoryService().getAlumById(currentUserId);
                      Navigator.of(context).pop();
                      if (profile != null && mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(initialAlum: profile),
                        ));
                      }
                    } catch (e) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                HomeMenuCard(
                  title: "News",
                  subtitle: "Updates",
                  icon: Icons.article,
                  onTap: () {
                    // TODO: Implement News Screen navigation
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}