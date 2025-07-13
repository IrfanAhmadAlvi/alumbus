import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/screens/edit_profile_screen.dart';
import 'package:alumbus/src/widgets/profile_info_card.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Alum alum;
  const ProfileScreen({super.key, required this.alum});

  @override
  Widget build(BuildContext context) {
    // Check if the profile being viewed belongs to the currently logged-in user
    final isCurrentUser = AuthService().currentUser?.uid == alum.id;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        // Only show the edit button if it's the current user's profile
        floatingActionButton: isCurrentUser
            ? FloatingActionButton(
          onPressed: () {
            // Navigate to the EditProfileScreen when the button is tapped
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditProfileScreen(alum: alum),
            ));
          },
          child: const Icon(Icons.edit),
        )
            : null,
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  leading: const BackButton(color: Colors.black),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.shade300,
                          // This safely handles cases where the profile picture URL is empty
                          backgroundImage: alum.profilePictureUrl.isNotEmpty
                              ? NetworkImage(alum.profilePictureUrl)
                              : null,
                          child: alum.profilePictureUrl.isEmpty
                              ? Icon(Icons.person,
                              size: 45, color: Colors.grey.shade600)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          alum.fullName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(alum.batch, style: const TextStyle(fontSize: 16)),
                        Text(alum.profession,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                        Text(alum.location,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  ),
                  expandedHeight: 320,
                  pinned: true,
                  bottom: TabBar(
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: "Contact"),
                      Tab(text: "About Me"),
                      Tab(text: "Media"),
                      Tab(text: "Social"),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: [
                    if (alum.primaryPhone.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.phone_outlined,
                        label: "Primary Phone No.",
                        value: alum.primaryPhone,
                      ),
                    if (alum.primaryEmail.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.email_outlined,
                        label: "Primary Email",
                        value: alum.primaryEmail,
                      ),
                    if (alum.dateOfBirth.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.people_alt_outlined,
                        label: "Date Of Birth",
                        value: alum.dateOfBirth,
                      ),
                    if (alum.petName.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.pets_outlined,
                        label: "Pet Name",
                        value: alum.petName,
                      ),
                    if (alum.secondaryPhone.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.phone_outlined,
                        label: "Secondary Phone No.",
                        value: alum.secondaryPhone,
                      ),
                    if (alum.secondaryEmail.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.email_outlined,
                        label: "Secondary Email",
                        value: alum.secondaryEmail,
                      ),
                  ],
                ),
                const Center(child: Text("About Me details here")),
                const Center(child: Text("Media content here")),
                const Center(child: Text("Social links here")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
