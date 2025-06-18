import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/home_screens_providers/add_post_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../setting_screens/create_event_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  static const double _imageDisplayHeight = 200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        Provider.of<FetchEditUserProvider>(context, listen: false).fetchUser(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AddPostProvider>(
      builder: (context, addPostProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('Create Post'),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),

          body: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UserInfoHeader(),
                const SizedBox(height: 20),

                _buildCardContainer(
                  child: Column(
                    children: [
                      TextField(
                        controller: addPostProvider.titleController,
                        maxLength: 30,
                        decoration: const InputDecoration(
                          hintText: "Post Title",
                          counterText: "",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        onChanged: (_) => addPostProvider.notifyListeners(),
                      ),
                      const Divider(),
                      TextField(
                        controller: addPostProvider.postController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: "What's on your mind?",
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => addPostProvider.notifyListeners(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (addPostProvider.selectedImage != null)
                  _buildCardContainer(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            addPostProvider.selectedImage!,
                            width: double.infinity,
                            height: _imageDisplayHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 16,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, color: Colors.white, size: 16),
                              onPressed: () => addPostProvider.clearImage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                Text(
                  "Add Media or Event",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _buildMediaButton(
                        Icons.photo, "Gallery",
                            () => addPostProvider.pickImage(ImageSource.gallery),
                        screenWidth, screenHeight),
                    _buildMediaButton(
                        Icons.camera_alt, "Camera",
                            () => addPostProvider.pickImage(ImageSource.camera),
                        screenWidth, screenHeight),
                    _buildMediaButton(
                        Icons.event, "Event",
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateEventScreen())),
                        screenWidth, screenHeight),
                  ],
                ),

                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: addPostProvider.isPostEnabled
                        ? () async {
                      final message = await addPostProvider.createPost();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message ?? 'Post Shared Successfully!'),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: addPostProvider.isPostEnabled ? Colors.pink : Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: addPostProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Post',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildMediaButton(IconData icon, String label, VoidCallback onTap, double screenWidth, double screenHeight) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: screenWidth * 0.045),
      label: Text(label, style: TextStyle(fontSize: screenWidth * 0.03)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.035,
          vertical: screenHeight * 0.015,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ----------------- UserInfoHeader ------------------
class UserInfoHeader extends StatelessWidget {
  const UserInfoHeader({super.key});

  static const String _apiBaseUrl = 'http://srv861272.hstgr.cloud:8000';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final userProvider = Provider.of<FetchEditUserProvider>(context);
    final userData = userProvider.userData;

    final String userName = userData['name'] ?? 'Guest User';
    String userProfileImageUrl = userData['profile'] ?? '';

    ImageProvider profileImageProvider;

    if (userProfileImageUrl.isNotEmpty) {
      Uri? uri = Uri.tryParse(userProfileImageUrl);
      if (uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
        profileImageProvider = NetworkImage(userProfileImageUrl);
      } else {
        profileImageProvider = NetworkImage('$_apiBaseUrl/$userProfileImageUrl');
      }
    } else {
      profileImageProvider = const NetworkImage('https://randomuser.me/api/portraits/men/75.jpg');
    }

    return Row(
      children: [
        CircleAvatar(
          backgroundImage: profileImageProvider,
          radius: 24,
        ),
        SizedBox(width: screenWidth * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
            ),
            Text(
              userData['role'] ?? "Event Organizer",
              style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.035),
            ),
          ],
        ),
      ],
    );
  }
}
