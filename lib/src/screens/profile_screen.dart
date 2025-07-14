import 'dart:io';
import 'package:alumbus/src/auth/auth_service.dart';
import 'package:alumbus/src/models/user_model.dart';
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
    setState(() {
      _isUploading = true;
    });

    try {
      final ImageUploadService imageService = ImageUploadService();
      final File? imageFile = await imageService.pickImage();
      if (imageFile == null) {
        setState(() { _isUploading = false; });
        return;
      }

      final String downloadUrl = await imageService.uploadProfilePicture(imageFile, alum.id);

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
        );
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated!")),
      );

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

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
                 /* actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],*/
                  backgroundColor: Colors.grey.shade100,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Stack(
                          children: [
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
                            if (_isUploading)
                              const Positioned.fill(
                                child: CircularProgressIndicator(),
                              ),
                            if (isCurrentUser && !_isUploading)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _changeProfilePicture,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          alum.fullName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        //const SizedBox(height: 4),
                        Text(alum.profession,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 20),

                      ],
                    ),
                  ),

                  expandedHeight: 280,
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
                    // --- THESE ARE THE NEW CARDS ---


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
