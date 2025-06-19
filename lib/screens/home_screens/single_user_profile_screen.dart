// lib/screens/user_screens/single_user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../providers/onording_login_screens_providers/user_profile_provider.dart'; // Adjust path
// The following imports are commented out as they might not be directly relevant
// for a *single user profile* view and are primarily from the current user's profile.
// Consider if 'EditProfileScreen' or 'SettingsScreen' should really be accessible
// from *another* user's profile. For now, I'll keep the imports but make
// the buttons for them conditionally visible or remove their actions.
// import '../login_and_onbording_screens/edit_profile_screen.dart';
import '../setting_screens/setting_screen.dart'; // Re-use for structure, if needed
import '../other_for_use/utils.dart'; // For getFullImageUrl if not already global
import '../home_screens/userprofile_list.dart'; // Re-using StatWidget definition

// Ensure StatWidget is defined or imported from a common location.
// If it's already in userprofile_list.dart and that's correctly imported,
// you can remove the commented-out definition below.
/*
class StatWidget extends StatelessWidget {
  final List<String> avatarUrls;
  final String count;
  final String label;

  const StatWidget({
    super.key,
    required this.avatarUrls,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: avatarUrls
              .map(
                (url) => Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(url),
              ),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
*/

class SingleUserProfileScreen extends StatefulWidget {
  final String userId; // The ID of the user whose profile we want to display

  const SingleUserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SingleUserProfileScreen> createState() => _SingleUserProfileScreenState();
}

class _SingleUserProfileScreenState extends State<SingleUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _userProfileData = {}; // Data for the *displayed* user
  bool _isLoading = true;
  String _errorMessage = '';

  // Example list of photo URLs for the "Photos" tab.
  final List<String> _userPhotos = [
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  final List<String> _connectionAvatars = [
    'https://randomuser.me/api/portraits/men/32.jpg',
    'https://randomuser.me/api/portraits/women/44.jpg',
    'https://randomuser.me/api/portraits/men/50.jpg',
    'https://randomuser.me/api/portraits/women/60.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUserProfileData();
  }

  // Utility function for image URL (assuming it's available globally or defined here)
  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  Future<void> _fetchUserProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final userProvider = Provider.of<FetchEditUserProvider>(context, listen: false);
      final fetchedData = await userProvider.fetchUserById(widget.userId);
      setState(() {
        _userProfileData = fetchedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching user profile: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- New method to show full-screen image ---
  void _showFullScreenImage(ImageProvider imageProvider, String tag) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85), // Dimmed background
      barrierDismissible: true, // Tapping outside will close the image
      builder: (BuildContext context) {
        return Center(
          child: Hero(
            tag: tag,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => Navigator.of(context).pop(),
                child: ClipOval(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // --- End of new method ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading Profile"), // Add const
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Error"),
          centerTitle: true,
        ),
        body: Center(child: Text(_errorMessage)),
      );
    }

    final userName = _userProfileData['name'] ?? 'Unknown User';
    final userAbout = _userProfileData['about'] ?? 'No bio available.';
    final profileImagePath = _userProfileData['profile'];

    ImageProvider profileImage;
    String heroTag; // Tag for Hero animation
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      Uri? uri = Uri.tryParse(profileImagePath);
      if (uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
        profileImage = NetworkImage(profileImagePath);
        heroTag = profileImagePath; // Use URL as tag if unique
      } else {
        profileImage = NetworkImage(getFullImageUrl(profileImagePath));
        heroTag = getFullImageUrl(profileImagePath); // Use full URL as tag
      }
    } else {
      profileImage = const AssetImage('images/default_avatar.png'); // Use your default image
      heroTag = 'default_avatar_hero_tag'; // Unique tag for default
    }


    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          userName,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Profile Picture, Name, Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  children: [
                    // Profile Picture with InkWell for full-screen view
                    InkWell(
                      onTap: () {
                        _showFullScreenImage(profileImage, heroTag);
                      },
                      child: Hero(
                        tag: heroTag, // Hero tag for animation
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.pink,
                          child: CircleAvatar(
                            radius: 57,
                            backgroundImage: profileImage,
                            child: profileImage == const AssetImage('images/default_avatar.png') || profileImage == null
                                ? Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 40, color: Colors.white),
                              ),
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Connections and Activities Stats section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatWidget(
                          avatarUrls: _connectionAvatars,
                          count: "136",
                          label: "Connections",
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        StatWidget(
                          avatarUrls: [
                            'https://randomuser.me/api/portraits/men/1.jpg',
                            'https://randomuser.me/api/portraits/women/2.jpg',
                          ],
                          count: "20",
                          label: "Activities Attended",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- New: Follow and Message Buttons ---
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Follow button pressed!")),
                              );
                              // Implement follow/unfollow logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink, // Pink background for Follow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              "Follow",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Space between buttons
                        Expanded(
                          child: OutlinedButton( // Changed to OutlinedButton for distinction
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Message button pressed!")),
                              );
                              // Implement message/chat logic here
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.pink, // Text color
                              side: const BorderSide(color: Colors.pink, width: 1.5), // Pink border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              "Message",
                              style: TextStyle(fontSize: 16), // No explicit color needed if foregroundColor is set
                            ),
                          ),
                        ),
                      ],
                    ),
                    // --- End New Buttons ---

                  ],
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userAbout,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.pink,
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.9),
                unselectedLabelStyle: const TextStyle(fontSize: 10.9),
                tabs: const [
                  Tab(text: "Photos"),
                  Tab(text: "Schedule Activities"),
                  Tab(text: "Past Activities"),
                ],
              ),

              // Tab Bar View
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Content for the "Photos" tab
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: StaggeredGrid.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: List.generate(_userPhotos.length, (index) {
                            // You can also make these grid photos viewable in full screen
                            // by wrapping them in InkWell and calling _showFullScreenImage.
                            return StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: index.isEven ? 1.2 : 1.5,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _userPhotos[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const Center(child: Text("Scheduled Activities Content (Dynamic for this user)")),
                    const Center(child: Text("Past Activities Content (Dynamic for this user)")),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}