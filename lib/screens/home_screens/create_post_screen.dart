import 'dart:async';
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
  final List<Map<String, String>> categories = const [
    {'icon': '💼', 'title': 'Business'},
    {'icon': '🙌', 'title': 'Community'},
    {'icon': '🎵', 'title': 'Music & Entertainment'},
    {'icon': '🩹', 'title': 'Health'},
    {'icon': '🍟', 'title': 'Food & drink'},
    {'icon': '👨‍👩‍👧‍👦', 'title': 'Family & Education'},
    {'icon': '⚽', 'title': 'Sport'},
    {'icon': '👠', 'title': 'Fashion'},
    {'icon': '🎬', 'title': 'Film & Media'},
    {'icon': '🏠', 'title': 'Home & Lifestyle'},
    {'icon': '🎨', 'title': 'Design'},
    {'icon': '🎮', 'title': 'Gaming'},
    {'icon': '🧪', 'title': 'Science & Tech'},
    {'icon': '🏫', 'title': 'School & Education'},
    {'icon': '🏖️', 'title': 'Holiday'},
    {'icon': '✈️', 'title': 'Travel'},
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid.isNotEmpty) {
        Provider.of<FetchEditUserProvider>(context, listen: false)
            .fetchUser(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AddPostProvider>(
      builder: (context, addPostProvider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Create Post'),
            centerTitle: true,
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UserInfoHeader(),
                const SizedBox(height: 20),
                _buildCardContainer(
                  child: TextField(
                    controller: addPostProvider.postController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(height: 16),
                if (addPostProvider.selectedImage != null)
                  _buildCardContainer(
                    child: Stack(
                      children: [
                        FutureBuilder<Size>(
                          future: _getImageSize(addPostProvider.selectedImage!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              final aspectRatio =
                                  snapshot.data!.width / snapshot.data!.height;
                              return AspectRatio(
                                aspectRatio: aspectRatio,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    addPostProvider.selectedImage!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 16,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                              onPressed: addPostProvider.clearImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Text(
                  "Select Tags",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final title = category['title']!;
                    final isSelected = addPostProvider.selectedCategories.contains(title);

                    return GestureDetector(
                      onTap: () {
                        final alreadySelected = addPostProvider.selectedCategories.contains(title);
                        final canSelectMore = addPostProvider.selectedCategories.length < 3;

                        if (alreadySelected || canSelectMore) {
                          addPostProvider.selectCategory(title);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You can select up to 3 categories only.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.pink : Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category['icon'] ?? '',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

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
                      Icons.photo,
                      "Gallery",
                      () => addPostProvider.pickImage(ImageSource.gallery),
                      screenWidth,
                      screenHeight,
                    ),
                    _buildMediaButton(
                      Icons.camera_alt,
                      "Camera",
                      () => addPostProvider.pickImage(ImageSource.camera),
                      screenWidth,
                      screenHeight,
                    ),
                    _buildMediaButton(
                      Icons.event,
                      "Event",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateEventScreen(),
                        ),
                      ),
                      screenWidth,
                      screenHeight,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: addPostProvider.isPostEnabled
                        ? () async {
                      final message = await addPostProvider.createPost(context);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        message ?? 'Post creation finished.')),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: addPostProvider.isPostEnabled
                          ? Colors.pink
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
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

  Widget _buildCardContainer({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 0.6),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      );

  Widget _buildMediaButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    double screenWidth,
    double screenHeight,
  ) =>
      ElevatedButton.icon(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}

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
        profileImageProvider =
            NetworkImage('$_apiBaseUrl/$userProfileImageUrl');
      }
    } else {
      profileImageProvider =
          const NetworkImage('https://randomuser.me/api/portraits/men/75.jpg');
    }

    return Container(
      child: Row(
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
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
              ),
              Text(
                userData['role'] ?? "Event Organizer",
                style: TextStyle(
                    color: Colors.grey[600], fontSize: screenWidth * 0.035),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Size> _getImageSize(File file) async {
  final image = FileImage(file);
  final completer = Completer<Size>();
  image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    }),
  );
  return completer.future;
}
