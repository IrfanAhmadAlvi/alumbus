import 'dart:io';
import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/models/user_model.dart';
import 'package:alumbus/src/screens/edit_about_me_screen.dart'; // <-- 1. IMPORT NEW SCREEN
import 'package:alumbus/src/screens/edit_profile_screen.dart';
import 'package:alumbus/src/services/image_upload_service.dart';
import 'package:alumbus/src/widgets/profile_info_card.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final Alum initialAlum;
  const ProfileScreen({super.key, required this.initialAlum});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Alum alum;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    alum = widget.initialAlum;
  }

  Future<void> _changeProfilePicture() async {
    // ... (no changes in this method)
    setState(() {
      _isUploading = true;
    });

    try {
      final ImageUploadService imageService = ImageUploadService();
      final File? imageFile = await imageService.pickImage();
      if (imageFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final String downloadUrl =
      await imageService.uploadProfilePicture(imageFile, alum.id);

      setState(() {
        alum = Alum(
          id: alum.id,
          fullName: alum.fullName,
          batch: alum.batch,
          profession: alum.profession,
          company: alum.company,
          location: alum.location,
          profilePictureUrl: downloadUrl,
          primaryPhone: alum.primaryPhone,
          primaryEmail: alum.primaryEmail,
          dateOfBirth: alum.dateOfBirth,
          bloodGroup: alum.bloodGroup,
          secondaryPhone: alum.secondaryPhone,
          secondaryEmail: alum.secondaryEmail,
          aboutMe: alum.aboutMe,
        );
        _isUploading = false;
      });

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = AuthService().currentUser?.uid == alum.id;

    return DefaultTabController(
      length: 3,
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
                  leading: const BackButton(color: Colors.white),
                  backgroundColor: Colors.indigo,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade800
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 35),
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.indigo.shade200,
                                backgroundImage: alum.profilePictureUrl.isNotEmpty
                                    ? NetworkImage(alum.profilePictureUrl)
                                    : null,
                                child: alum.profilePictureUrl.isEmpty
                                    ? Icon(Icons.person,
                                    size: 55,
                                    color: Colors.indigo.shade700)
                                    : null,
                              ),
                              if (_isUploading)
                                const Positioned.fill(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              if (isCurrentUser && !_isUploading)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _changeProfilePicture,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.camera_alt,
                                          color: Colors.indigo, size: 18),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            alum.fullName,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(alum.profession,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.white70)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  expandedHeight: 280,
                  pinned: true,
                  bottom: TabBar(
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(text: "Contact"),
                      Tab(text: "About Me"),
                      Tab(text: "Social Media"),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                // Tab 1: Contact
                ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  children: [
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
                    if (alum.secondaryEmail.isNotEmpty)
                      ProfileInfoCard(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: alum.secondaryEmail,
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
                  ],
                ),
                // --- 2. UPDATE THE "ABOUT ME" TAB ---
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if(isCurrentUser)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            alum.aboutMe.isNotEmpty
                                ? alum.aboutMe
                                : "This user has not provided a bio.",
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            label: const Text("Click Here For Write Bio"),
                            style: TextButton.styleFrom(
                              // Aligning the text and icon to the left
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => EditAboutMeScreen(alum: alum),
                              ));
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),

                  ],
                ),
                // Tab 3: Social Media
                const Center(child: Text("Social links here")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}