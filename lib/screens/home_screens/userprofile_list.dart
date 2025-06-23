import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/home_screens_providers/add_post_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../login_and_onbording_screens/edit_profile_screen.dart';
import '../setting_screens/setting_screen.dart';
import 'create_post_screen.dart';

class UserProfileList extends StatefulWidget {
  const UserProfileList({super.key});

  @override
  State<UserProfileList> createState() => _UserProfileListState();
}

class _UserProfileListState extends State<UserProfileList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  List<Event> _userPostPhotos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchProfile();
    await _fetchPostImages();
  }

  Future<void> _fetchProfile() async {
    if (_currentUser == null) return;
    final provider = Provider.of<FetchEditUserProvider>(context, listen: false);
    await provider.loadUserId();
    await provider.fetchUser(_currentUser!.uid);
  }

  Future<void> _fetchPostImages() async {
    try {
      final postProvider = Provider.of<AddPostProvider>(context, listen: false);
      final posts = await postProvider.fetchMyPosts();
      setState(() => _userPostPhotos = posts);
    } catch (e) {
      debugPrint('Failed to fetch posts: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer<FetchEditUserProvider>(
        builder: (_, provider, __) {
          final data = provider.userData;
          final name = data['name'] ?? (_currentUser?.displayName ?? 'Guest');
          final about = data['about'] ?? 'No bio available.';
          final profilePath = data['profile'] ?? '';

          final followersCount = (data['followers'] as List?)?.length ?? 0;
          final followingCount = (data['following'] as List?)?.length ?? 0;

          ImageProvider profileImg;
          if (profilePath.isNotEmpty) {
            final fullUrl = provider.profileImageUrl;
            profileImg = (fullUrl != null && Uri.parse(fullUrl).isAbsolute)
                ? NetworkImage(fullUrl)
                : const AssetImage('images/default_avatar.png');
          } else if (_currentUser?.photoURL != null) {
            profileImg = NetworkImage(_currentUser!.photoURL!);
          } else {
            profileImg = const AssetImage('images/default_avatar.png');
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Profile'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
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
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.pink,
                      child: CircleAvatar(
                        radius: 57,
                        backgroundImage: profileImg,
                        child: profileImg is AssetImage
                            ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(followersCount, 'Followers'),
                        Container(height: 40, width: 1, color: Colors.grey[300]),
                        _buildStat(followingCount, 'Following'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                            _fetchProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left, // Optional: ensures explicit alignment
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              about,
                              style: const TextStyle(color: Colors.black54),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTabs(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(int count, String label) => Column(
    children: [
      Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.pink)),
    ],
  );

  Widget _buildTabs(BuildContext context) => Column(
    children: [
      TabBar(
        controller: _tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(width: 4.0, color: Colors.pinkAccent),
          insets: EdgeInsets.symmetric(horizontal: 50),
        ),
        indicatorColor: Colors.pinkAccent,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on)),
          Tab(icon: Icon(Icons.calendar_today)),
          Tab(icon: Icon(Icons.history)),
        ],
      ),
      const Divider(height: 1),
      const SizedBox(height: 10),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: TabBarView(
          controller: _tabController,
          children: [
            _userPostPhotos.isEmpty
                ? Center(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPostScreen()),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_box_outlined, size: 80, color: Colors.pink),
                    SizedBox(height: 16),
                    Text('Add your first post', style: TextStyle(color: Colors.pink)),
                  ],
                ),
              ),
            )
                : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _userPostPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (_, i) {
                final post = _userPostPhotos[i];
                final imageUrl = post.image.isNotEmpty
                    ? post.image
                    : (post.media.isNotEmpty ? post.media.first : '');
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                );
              },
            ),
            const Center(child: Text('Scheduled Activities')),
            const Center(child: Text('Past Activities')),
          ],
        ),
      ),
    ],
  );
}