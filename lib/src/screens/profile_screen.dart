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
    final isCurrentUser = AuthService().currentUser?.uid == alum.id;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        floatingActionButton: isCurrentUser
            ? FloatingActionButton(
          onPressed: () {
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
                        // ONLY PROFESSION IS SHOWN HERE NOW
                        Text(alum.profession,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                      ],
                    ),
                  ),
                  expandedHeight: 280, // Adjusted height
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
                // "Contact" Tab Content
                ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: [
                    // BATCH IS NOW HERE
                    if (alum.batch.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.school_outlined,
                        label: "Batch",
                        value: alum.batch,
                      ),
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
                    if (alum.location.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.location_on_outlined,
                        label: "Location",
                        value: alum.location,
                      ),
                    if (alum.dateOfBirth.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.people_alt_outlined,
                        label: "Date Of Birth",
                        value: alum.dateOfBirth,
                      ),
                    if (alum.bloodGroup.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.bloodtype_outlined,
                        label: "Blood Group",
                        value: alum.bloodGroup,
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
                // Placeholder content for other tabs
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
