import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/home_screens_providers/add_post_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';

class SingleUserProfileScreen extends StatefulWidget {
  final String userId;

  const SingleUserProfileScreen({super.key, required this.userId});

  @override
  State<SingleUserProfileScreen> createState() => _SingleUserProfileScreenState();
}

class _SingleUserProfileScreenState extends State<SingleUserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _userProfileData = {};
  List<String> _userPostPhotos = [];
  bool _isLoading = true;
  bool isFollowing = false;
  String? backendUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    backendUserId = prefs.getString('backendUserId');
    await _fetchUserProfileData();
    _fetchUserPostImages();
  }

  Future<void> _fetchUserProfileData() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<FetchEditUserProvider>(context, listen: false);
      final data = await provider.fetchUserById(widget.userId);

      final followers = data['followers'] as List<dynamic>? ?? [];
      final following = data['following'] as List<dynamic>? ?? [];

      setState(() {
        _userProfileData = data;

        // ✅ No swapping — use directly
        _userProfileData['followers'] = followers;
        _userProfileData['following'] = following;

        // ✅ You are following this profile if YOUR ID is in THEIR followers list
        isFollowing = backendUserId != null && followers.contains(backendUserId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile')));
    }
  }

  Future<void> _fetchUserPostImages() async {
    try {
      final provider = Provider.of<AddPostProvider>(context, listen: false);
      final images = await provider.fetchUserPostImages(widget.userId);
      setState(() => _userPostPhotos = images);
    } catch (_) {}
  }

  String _fullImageUrl(String path) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (path.startsWith('http')) return path;
    return '$baseUrl/${path.startsWith('/') ? path.substring(1) : path}';
  }

  Future<void> _toggleFollow() async {
    final provider = Provider.of<FetchEditUserProvider>(context, listen: false);
    final result = await provider.toggleFollow(widget.userId);

    if (!mounted) return;

    if (result['success']) {
      final newFollowers = result['targetFollowers'] as List<dynamic>;

      setState(() {
        // ✅ Update the current profile's followers
        _userProfileData['followers'] = newFollowers;

        // ✅ Set whether current user is following this profile
        isFollowing = backendUserId != null && newFollowers.contains(backendUserId);
      });
    }

    // ✅ Show follow/unfollow status message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Action completed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.pink,)));
    }

    final name = _userProfileData['name'] ?? 'Unknown';
    final about = _userProfileData['about'] ?? 'No bio available.';
    final profilePath = _userProfileData['profile'] ?? '';
    final followers = _userProfileData['followers'] as List? ?? [];
    final following = _userProfileData['following'] as List? ?? [];

    final profileImage = profilePath.isNotEmpty
        ? NetworkImage(_fullImageUrl(profilePath))
        : const AssetImage('images/default_avatar.png') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.pink,
                child: CircleAvatar(
                  radius: 57,
                  backgroundImage: profileImage,
                ),
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Followers / Following
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(followers.length, 'Followers'),
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  _buildStat(following.length, 'Following'),
                ],
              ),
              const SizedBox(height: 20),

              // Follow / Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing ? Colors.grey : Colors.pink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isFollowing ? 'Unfollow' : 'Follow', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.pink),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Message', style: TextStyle(color: Colors.pink)),
                      ),
                    ),
                  ],
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

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.pink,
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.calendar_today)),
                  Tab(icon: Icon(Icons.history)),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _userPostPhotos.isEmpty
                        ? const Center(child: Text("No posts available."))
                        : GridView.builder(
                      itemCount: _userPostPhotos.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        return Image.network(
                          _userPostPhotos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                        );
                      },
                    ),
                    const Center(child: Text("Scheduled Activities")),
                    const Center(child: Text("Past Activities")),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(int count, String label) => Column(
    children: [
      Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.pink)),
    ],
  );
}