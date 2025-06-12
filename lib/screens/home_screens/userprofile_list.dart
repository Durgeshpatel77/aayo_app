import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import 'package:aayo/screens/setting_screens/edit_profile_screen.dart'; // Your Edit Profile Screen
import 'package:aayo/screens/setting_screens/setting_screen.dart'; // Your Settings Screen

// Assuming you have this model for profile stats if needed, or you can simplify
// import 'package:aayo/models/profile_stats.dart';

// Dummy StatWidget definition for demonstration if you don't have it
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
                radius: 12, // Smaller avatars
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
// End of Dummy StatWidget

class UserProfileList extends StatefulWidget {
  const UserProfileList({super.key});

  @override
  State<UserProfileList> createState() => _UserProfileListState();
}

class _UserProfileListState extends State<UserProfileList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  String? _userAbout; // To store the 'about' fetched from Firestore
  String? _userPhoneNumber; // To store the phone number
  String? _userGender; // To store the gender
  String? _userCountry; // To store the country

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUser = FirebaseAuth.instance.currentUser;

    // Fetch user profile data from Firestore
    _fetchUserProfileData();
  }

  Future<void> _fetchUserProfileData() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userAbout = data['about'] ?? 'No bio available.';
          _userPhoneNumber = data['phoneNumber'] ?? 'N/A';
          _userGender = data['gender'] ?? 'N/A';
          _userCountry = data['country'] ?? 'N/A';
        });
      } else {
        setState(() {
          _userAbout = 'No bio available.';
          _userPhoneNumber = 'N/A';
          _userGender = 'N/A';
          _userCountry = 'N/A';
        });
      }
    } catch (e) {
      print("Error fetching user profile data for display: $e");
    }
  }

  // Example data for photos (replace with actual user photos)
  final List<String> _userPhotos = [
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  // Example avatar URLs for connections (replace with actual user avatars)
  final List<String> _connectionAvatars = [
    'https://randomuser.me/api/portraits/men/32.jpg',
    'https://randomuser.me/api/portraits/women/44.jpg',
    'https://randomuser.me/api/portraits/men/50.jpg',
    'https://randomuser.me/api/portraits/women/60.jpg',
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        automaticallyImplyLeading: false,
        title: Text(
          "My Profile",
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.settings),
                  color: Colors.pink,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsScreen()));
                  },
                ),
              ],
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // <--- ADD THIS LINE HERE

            children: [
              // Top Section: Profile Picture, Name, Stats, Edit Button
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.pink,
                      child: CircleAvatar(
                        radius: 57,
                        backgroundImage: _currentUser?.photoURL != null
                            ? NetworkImage(_currentUser!.photoURL!)
                            : const AssetImage('images/default_avatar.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentUser?.displayName ?? 'Guest User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Display Email (optional)
                    const SizedBox(height: 20),
                    // Connections and Activities Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatWidget(
                          avatarUrls: _connectionAvatars,
                          count: "136",
                          label: "My Connections",
                        ),

                        // Vertical Divider
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
                          label: "Activities Attend",
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to EditProfileScreen and wait for result
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                // Pass current fetched data as initial values
                                initialName: _currentUser?.displayName ?? '',
                                initialEmail: _currentUser?.email ?? '',
                                initialAbout: _userAbout ?? '',
                                initialmobile: _userPhoneNumber ?? '',
                                // If you want to pre-select gender/country, you'd pass those too
                              ),
                            ),
                          );
                          // After returning from EditProfileScreen, refresh data
                          _currentUser = FirebaseAuth.instance.currentUser; // Get updated Auth data
                          _fetchUserProfileData(); // Fetch updated Firestore data
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // This aligns children to the left (start of the cross axis)
                  mainAxisAlignment: MainAxisAlignment.start,   // This aligns children to the top (start of the main axis)
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
                      _userAbout ?? "Loading about...", // Display fetched 'about' or "Loading about..."
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),              ),
              const SizedBox(height: 24),

              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.pink,
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold,fontSize: 10.9),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 10.9,
                ),
                tabs: const [
                  Tab(text: "Photos"),
                  Tab(text: "Schedule Activities"),
                  Tab(text: "Past Activities"),
                ],
              ),

              // Tab Bar View (Photos Grid)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: StaggeredGrid.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: List.generate(_userPhotos.length, (index) {
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
                    const Center(child: Text("Scheduled Activities Content")),
                    const Center(child: Text("Past Activities Content")),
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