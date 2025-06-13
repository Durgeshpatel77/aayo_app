import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Core Firebase authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore database
import 'package:provider/provider.dart'; // State management for UserProvider

import 'package:aayo/screens/login_and_onbording_screens/edit_profile_screen.dart'; // Path to your Edit Profile Screen
import 'package:aayo/screens/setting_screens/setting_screen.dart'; // Path to your Settings Screen
import '../../providers/user_profile_provider.dart'; // Path to your UserProvider

// Dummy StatWidget: This widget is used to display numerical statistics with small avatars.
// Replace this with your actual StatWidget implementation if it's different.
class StatWidget extends StatelessWidget {
  final List<String> avatarUrls; // List of URLs for small avatar images
  final String count; // The numerical value for the statistic
  final String label; // The label for the statistic (e.g., "My Connections")

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
                radius: 12, // Smaller avatars for display
                backgroundImage: NetworkImage(url), // Load avatar image from network
              ),
            ),
          )
              .toList(), // Convert the iterable to a list of widgets
        ),
        const SizedBox(height: 4), // Small vertical space
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
// End of Dummy StatWidget

// UserProfileList: The main screen for displaying a user's profile.
class UserProfileList extends StatefulWidget {
  const UserProfileList({super.key});

  @override
  State<UserProfileList> createState() => _UserProfileListState();
}

class _UserProfileListState extends State<UserProfileList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller for managing TabBar and TabBarView
  User? _currentUser; // Firebase authenticated user object
  // Local state variables to display user details, populated from UserProvider
  String _userAbout = 'No bio available.';
  String _userPhoneNumber = 'N/A';
  String _userGender = 'N/A';
  String _userCountry = 'N/A';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Initialize TabController with 3 tabs
    _currentUser = FirebaseAuth.instance.currentUser; // Get the currently logged-in Firebase user
    _fetchUserProfileData(); // Fetch user data from the backend when the screen initializes
  }

  // _fetchUserProfileData: Asynchronously fetches the detailed user profile from your backend
  // via the UserProvider and updates the local state variables.
  Future<void> _fetchUserProfileData() async {
    // Ensure _currentUser is the most current Firebase user data
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser == null) {
      debugPrint('No current Firebase user found.');
      // Handle cases where no Firebase user is logged in (e.g., redirect to login)
      return;
    }

    // Access the UserProvider without listening to avoid unnecessary rebuilds here
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Call the provider to fetch user data from your backend using the Firebase UID
    await userProvider.fetchUser(_currentUser!.uid);

    // Populate local state variables from the provider's userData after fetching
    final userData = userProvider.userData;
    setState(() {
      _userAbout = userData['about'] ?? 'No bio available.';
      _userPhoneNumber = userData['mobile'] ?? 'N/A'; // Assumes 'mobile' field from Firestore
      _userGender = userData['gender'] ?? 'N/A';
      _userCountry = userData['country'] ?? 'N/A';
    });
  }

  // _userPhotos: Example list of photo URLs for the "Photos" tab.
  // In a real application, these would likely come from your backend or a storage service.
  final List<String> _userPhotos = [
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit:crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  // _connectionAvatars: Example list of avatar URLs for demonstrating connections.
  final List<String> _connectionAvatars = [
    'https://randomuser.me/api/portraits/men/32.jpg',
    'https://randomuser.me/api/portraits/women/44.jpg',
    'https://randomuser.me/api/portraits/men/50.jpg',
    'https://randomuser.me/api/portraits/women/60.jpg',
  ];

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget rebuilds its child whenever UserProvider's data changes.
    // This ensures the UI is always up-to-date with the latest profile information.
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userData = userProvider.userData; // Get the latest user data from the provider
        // Determine the profile image URL. We expect it to be in the 'profile' field
        // from your backend response, as discussed previously.
        final firestoreImageUrl = userData['profile'];
        // Determine the user's name, prioritizing data from Firestore, then Firebase Auth, then a default.
        final userName = userData['name'] ?? (_currentUser?.displayName ?? 'Guest User');

        // Logic to determine which image to display as the profile picture.
        ImageProvider? profileImage;
        if (firestoreImageUrl != null && firestoreImageUrl.isNotEmpty) {
          // Attempt to parse the URL to check if it's a full URL or a relative path.
          Uri? uri = Uri.tryParse(firestoreImageUrl);
          if (uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
            // It's a full, absolute URL (e.g., from Google or an image hosting service).
            profileImage = NetworkImage(firestoreImageUrl);
          } else {
            // It's likely a relative path on your server. Construct the full URL.
            final fullServerImageUrl = 'http://srv861272.hstgr.cloud:8000/$firestoreImageUrl';
            profileImage = NetworkImage(fullServerImageUrl);
          }
        } else if (_currentUser?.photoURL != null) {
          // As a fallback, use the photo URL provided directly by Firebase Authentication (e.g., Google profile pic).
          profileImage = NetworkImage(_currentUser!.photoURL!);
        } else {
          // If no image is available from any source, use a default local asset.
          profileImage = const AssetImage('images/default_avatar.png');
        }

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0.0, // Removes shadow when scrolled
            automaticallyImplyLeading: false, // Prevents Flutter from adding a back button by default
            title: const Text(
              "My Profile",
            ),
            centerTitle: true, // Centers the title in the AppBar
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Settings button
                    IconButton(
                      icon: const Icon(Icons.settings), // Settings icon
                      color: Colors.pink, // Pink color for the icon
                      onPressed: () {
                        // Navigate to the SettingsScreen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ],
            elevation: 0, // No shadow for the AppBar
            backgroundColor: Colors.white, // White background for the AppBar
          ),
          backgroundColor: Colors.white, // White background for the entire screen
          body: SafeArea(
            child: SingleChildScrollView( // Allows the content to scroll if it overflows
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section: Contains profile picture, name, stats, and edit button
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      children: [
                        // Profile Picture display area
                        CircleAvatar(
                          radius: 60, // Outer circle radius
                          backgroundColor: Colors.pink, // Pink border for the avatar
                          child: CircleAvatar(
                            radius: 57, // Inner circle radius
                            backgroundImage: profileImage, // Dynamically determined profile image
                            child: profileImage == const AssetImage('images/default_avatar.png') || profileImage == null
                                ? Center( // Fallback if no image is available (show initial of name)
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'U', // First letter of user name
                                style: const TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                            )
                                : null, // No child if an image is loaded
                          ),
                        ),
                        const SizedBox(height: 12), // Vertical space
                        Text(
                          userName, // Display user's name
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20), // Vertical space
                        // Connections and Activities Stats section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute space evenly
                          children: [
                            StatWidget(
                              avatarUrls: _connectionAvatars, // Example connection avatars
                              count: "136", // Example connection count
                              label: "My Connections",
                            ),

                            // Vertical Divider between stats
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
                              ], // Example activity avatars
                              count: "20", // Example activity count
                              label: "Activities Attend",
                            ),
                          ],
                        ),
                        const SizedBox(height: 24), // Vertical space
                        // Edit Profile Button
                        SizedBox(
                          width: double.infinity, // Button takes full available width
                          height: 50, // Fixed height for the button
                          child: ElevatedButton(
                            onPressed: () async {
                              // Navigate to EditProfileScreen.
                              // `await` ensures that code here pauses until EditProfileScreen is closed.
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                              // After returning from EditProfileScreen, refresh user data.
                              // This ensures the profile page displays the latest information saved.
                              _fetchUserProfileData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink, // Pink background for the button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                              ),
                            ),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Vertical space

                  // About Section: Displays user's bio and other details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
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
                        const SizedBox(height: 8), // Small vertical space
                        Text(
                          _userAbout, // Display the fetched 'about' text
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Vertical space

                  // Tab Bar: For navigating between "Photos", "Schedule Activities", and "Past Activities"
                  TabBar(
                    controller: _tabController, // Link TabBar to its controller
                    indicatorColor: Colors.pink, // Color of the active tab indicator
                    labelColor: Colors.pink, // Color of the active tab label
                    unselectedLabelColor: Colors.grey, // Color of inactive tab labels
                    labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.9), // Style for active tab label
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 10.9,
                    ), // Style for inactive tab labels
                    tabs: const [
                      Tab(text: "Photos"), // First tab
                      Tab(text: "Schedule Activities"), // Second tab
                      Tab(text: "Past Activities"), // Third tab
                    ],
                  ),

                  // Tab Bar View: Displays content corresponding to the selected tab
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5, // Occupies half of the screen height
                    child: TabBarView(
                      controller: _tabController, // Link TabBarView to its controller
                      children: [
                        // Content for the "Photos" tab: A staggered grid of images
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: StaggeredGrid.count(
                              crossAxisCount: 3, // 3 columns in the grid
                              mainAxisSpacing: 10, // Vertical spacing between items
                              crossAxisSpacing: 10, // Horizontal spacing between items
                              children: List.generate(_userPhotos.length, (index) {
                                return StaggeredGridTile.count(
                                  crossAxisCellCount: 1, // Each item spans 1 column
                                  mainAxisCellCount: index.isEven ? 1.2 : 1.5, // Alternating heights for staggered effect
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12), // Rounded corners for images
                                    child: Image.network(
                                      _userPhotos[index], // Display image from URL
                                      fit: BoxFit.cover, // Cover the entire space for the image
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        // Content for "Schedule Activities" tab
                        const Center(child: Text("Scheduled Activities Content")),
                        // Content for "Past Activities" tab
                        const Center(child: Text("Past Activities Content")),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}