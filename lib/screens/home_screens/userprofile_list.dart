import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/home_screens_providers/add_post_provider.dart';
import '../../screens/login_and_onbording_screens/edit_profile_screen.dart';
import '../../screens/setting_screens/setting_screen.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import 'create_post_screen.dart';

class UserProfileList extends StatefulWidget {
  const UserProfileList({super.key});

  @override
  State<UserProfileList> createState() => _UserProfileListState();
}

class _UserProfileListState extends State<UserProfileList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  List<String> _userPostPhotos = [];

  String _userAbout = 'No bio available.';
  String _userPhoneNumber = 'N/A';
  String _userGender = 'N/A';
  String _userCountry = 'N/A';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserProfileData();
    _fetchPostImages(); // 👈 fetch images
  }

  Future<void> _fetchUserProfileData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) return;

    final userProvider =
        Provider.of<FetchEditUserProvider>(context, listen: false);
    await userProvider.fetchUser(_currentUser!.uid);
    final userData = userProvider.userData;
    setState(() {
      _userAbout = userData['about'] ?? 'No bio available.';
      _userPhoneNumber = userData['mobile'] ?? 'N/A';
      _userGender = userData['gender'] ?? 'N/A';
      _userCountry = userData['country'] ?? 'N/A';
    });
  }

  Future<void> _fetchPostImages() async {
    try {
      final postProvider = Provider.of<AddPostProvider>(context, listen: false);
      final images = await postProvider.fetchMyPostImages();
      setState(() {
        _userPostPhotos = images;
      });
    } catch (e) {
      debugPrint("Error fetching post images: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _connectionAvatars = [
    'https://randomuser.me/api/portraits/men/32.jpg',
    'https://randomuser.me/api/portraits/women/44.jpg',
    'https://randomuser.me/api/portraits/men/50.jpg',
    'https://randomuser.me/api/portraits/women/60.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<FetchEditUserProvider>(
      builder: (context, userProvider, child) {
        final userData = userProvider.userData;
        final firestoreImageUrl = userData['profile'];
        final userName =
            userData['name'] ?? (_currentUser?.displayName ?? 'Guest User');

        ImageProvider? profileImage;
        if (firestoreImageUrl != null && firestoreImageUrl.isNotEmpty) {
          final uri = Uri.tryParse(firestoreImageUrl);
          if (uri != null && uri.hasAbsolutePath) {
            profileImage = NetworkImage(firestoreImageUrl);
          } else {
            final fullUrl =
                'http://srv861272.hstgr.cloud:8000/$firestoreImageUrl';
            profileImage = NetworkImage(fullUrl);
          }
        } else if (_currentUser?.photoURL != null) {
          profileImage = NetworkImage(_currentUser!.photoURL!);
        } else {
          profileImage = const AssetImage('images/default_avatar.png');
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Profile"),
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.pink),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.pink,
                          child: CircleAvatar(
                            radius: 57,
                            backgroundImage: profileImage,
                            child: profileImage is AssetImage
                                ? Text(userName.isNotEmpty ? userName[0] : 'U',
                                    style: const TextStyle(
                                        fontSize: 40, color: Colors.white))
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(userName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatWidget(
                                avatarUrls: _connectionAvatars,
                                count: "136",
                                label: "My Connections"),
                            Container(
                                height: 40, width: 1, color: Colors.grey[300]),
                            _StatWidget(
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
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen()),
                              );
                              _fetchUserProfileData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Edit Profile",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // About
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("About",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_userAbout,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Column(
                    children: [
                      // Instagram-style Icon TabBar
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.pinkAccent,
                        indicatorWeight: 3.0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.pinkAccent,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(icon: Icon(Icons.grid_on)), // Posts (grid)
                          Tab(
                              icon: Icon(Icons
                                  .calendar_today)), // Scheduled Activities
                          Tab(icon: Icon(Icons.history)), // Past Activities
                        ],
                      ),
                      const Divider(height: 1, thickness: 1),

                      // Divider for clean separation

                      // Tab content
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // 👇 Updated GridView for user post photos (Instagram-like)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 5, left: 5, right: 5),
                              child: _userPostPhotos.isEmpty
                                    ? Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPostScreen(),)); // Or use `MaterialPageRoute(...)`
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_box_outlined, size: 80, color: Colors.pink),
                                      SizedBox(height: 16),
                                      Text(
                                        'Add your first post',
                                        style: TextStyle(fontSize: 16, color: Colors.pink),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : GridView.builder(
                                      itemCount: _userPostPhotos.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 2,
                                        mainAxisSpacing: 2,
                                      ),
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            // Optional: Show full-screen image viewer
                                          },
                                          child: InkWell(
                                            child: Image.network(
                                              _userPostPhotos[index],
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.broken_image),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const Center(
                                child: Text("Scheduled Activities Content")),
                            const Center(
                                child: Text("Past Activities Content")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatWidget extends StatelessWidget {
  final List<String> avatarUrls;
  final String count;
  final String label;

  const _StatWidget({
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
              .map((url) => Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                        radius: 12, backgroundImage: NetworkImage(url)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 4),
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
