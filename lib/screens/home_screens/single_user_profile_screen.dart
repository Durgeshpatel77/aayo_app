import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../models/profile_stats.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../../providers/home_screens_providers/add_post_provider.dart';
import '../other_for_use/utils.dart';
import '../home_screens/userprofile_list.dart';

class SingleUserProfileScreen extends StatefulWidget {
  final String userId;

  const SingleUserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SingleUserProfileScreen> createState() => _SingleUserProfileScreenState();
}

class _SingleUserProfileScreenState extends State<SingleUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _userProfileData = {};
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _userPostPhotos = [];

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
    _fetchUserPostImages();
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
    }
  }

  Future<void> _fetchUserPostImages() async {
    try {
      final postProvider = Provider.of<AddPostProvider>(context, listen: false);
      final images = await postProvider.fetchUserPostImages(widget.userId);
      setState(() {
        _userPostPhotos = images;
      });
    } catch (e) {
      debugPrint("Error fetching user post images: $e");
    }
  }

  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  void _showFullScreenImage(ImageProvider imageProvider, String tag) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) {
        return Center(
          child: Hero(
            tag: tag,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(_errorMessage)),
      );
    }

    final userName = _userProfileData['name'] ?? 'Unknown User';
    final userAbout = _userProfileData['about'] ?? 'No bio available.';
    final profileImagePath = _userProfileData['profile'];

    ImageProvider profileImage;
    String heroTag;

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      final uri = Uri.tryParse(profileImagePath);
      if (uri != null && uri.hasAbsolutePath) {
        profileImage = NetworkImage(profileImagePath);
        heroTag = profileImagePath;
      } else {
        profileImage = NetworkImage(getFullImageUrl(profileImagePath));
        heroTag = getFullImageUrl(profileImagePath);
      }
    } else {
      profileImage = const AssetImage('images/default_avatar.png');
      heroTag = 'default_avatar_tag';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(userName, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _showFullScreenImage(profileImage, heroTag),
                child: Hero(
                  tag: heroTag,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.pink,
                    child: CircleAvatar(
                      radius: 57,
                      backgroundImage: profileImage,
                      child: profileImage is AssetImage
                          ? Text(userName[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: Colors.white))
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatWidget(avatarUrls: _connectionAvatars, count: "136", label: "Connections"),
                  Container(height: 40, width: 1, color: Colors.grey.shade300),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Follow", style: TextStyle(color: Colors.white)),
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
                        child: const Text("Message", style: TextStyle(color: Colors.pink)),
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
                    const Text("About", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(userAbout, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.pink,
                labelColor: Colors.pink,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Photos"),
                  Tab(text: "Schedule Activities"),
                  Tab(text: "Past Activities"),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _userPostPhotos.isEmpty
                          ? const Center(child: Text("No posts available."))
                          : StaggeredGrid.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: List.generate(_userPostPhotos.length, (index) {
                          return StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: index.isEven ? 1.2 : 1.5,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _userPostPhotos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Center(child: Text("Scheduled Activities")),
                    const Center(child: Text("Past Activities")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
