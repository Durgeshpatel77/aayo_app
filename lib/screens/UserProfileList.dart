import 'package:aayo/models/profile_stats.dart';
import 'package:aayo/screens/Edit_profilescreen.dart';
import 'package:aayo/screens/setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class UserProfileList extends StatefulWidget {
  const UserProfileList({super.key});

  @override
  State<UserProfileList> createState() => _UserProfileListState();
}

class _UserProfileListState extends State<UserProfileList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch Firebase user
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // Example data for photos (replace with actual user photos)
  final List<String> _userPhotos = [
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1661494266874-a18be6bda750?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D''https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0, // This will fix the problem
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
        elevation: 0, // <-- Add this line
        backgroundColor: Colors.white, // Transparent to show background
        // You might want a custom top bar here if needed
      ),
backgroundColor: Colors.white,
body: SafeArea(
  child: SingleChildScrollView(
          child: Column(
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
                          height: 40, // Adjust height as needed
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
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfileScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink, // Button color
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      "We have a team but still missing a couple of people. Let's play together! We have a team but still missing a couple of people. We have a team but still missing a couple of people",
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
                indicatorColor: Colors.pink, // Indicator color
                labelColor: Colors.pink, // Selected tab text color
                unselectedLabelColor: Colors.grey, // Unselected tab text color
                labelStyle: const TextStyle(fontWeight: FontWeight.bold,fontSize: 10.9),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 10.9, // set unselected tab text size
                   ),
                tabs: const [
                  Tab(text: "Photos"),
                  Tab(text: "Schedule Activities"),
                  Tab(text: "Past Activities"),
                ],
              ),

              // Tab Bar View (Photos Grid)
              // Use a fixed height for TabBarView inside SingleChildScrollView

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        // <-- add this
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
