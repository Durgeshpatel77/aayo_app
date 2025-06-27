import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../providers/home_screens_providers/add_post_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../event_detail_screens/events_details.dart';
import 'follow_list_screen.dart';

class SingleUserProfileScreen extends StatefulWidget {
  final String userId;

  const SingleUserProfileScreen({super.key, required this.userId});

  @override
  State<SingleUserProfileScreen> createState() => _SingleUserProfileScreenState();
}

class _SingleUserProfileScreenState extends State<SingleUserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _userProfileData = {};
    bool _isLoading = true;
    bool isFollowing = false;
    String? backendUserId;
  List<EventModel> _userEventModels = []; // For Tab 1: Events (Calendar View)
  List<Event> _userPostHistory = [];      // For Tab 2: Posts (Normal posts)


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
    await _fetchUserPosts(); // ✅ rename this
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
        isFollowing = backendUserId != null &&
            followers.any((user) => user['_id'] == backendUserId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile')));
    }
  }

  Future<void> _fetchUserPosts() async {
    try {
      final postProvider = Provider.of<AddPostProvider>(context, listen: false);
      final allPosts = await postProvider.fetchUserPostsById(widget.userId); // get all
      final onlyEvents = await postProvider.fetchUserPostsById(widget.userId, type: 'event'); // get events

      debugPrint("👤 Fetching posts for userId: ${widget.userId}");

      final events = await postProvider.fetchUserPostsById(widget.userId); // This should return List<Event>

      debugPrint("📦 Total events fetched: ${events.length}");

      if (events.isEmpty) {
        debugPrint("🚫 No events returned from fetchUserPostsById");
      }

      for (var e in events) {
        debugPrint("🔎 Raw event type: ${e.type}, title: ${e.title}, media: ${e.media}");
      }

      final eventModels = events
          .where((e) => e.type?.toLowerCase() == 'event')
          .map((e) => EventModel(
        id: e.id,
        title: e.title,
        content: e.content,
        media: e.media,
        likes: e.likes,
        comments: e.comments,
        type: e.type,
        createdAt: e.createdAt,
        updatedAt: e.createdAt,
        user: UserInfo(
          id: e.organizerId,
          name: e.organizer,
          profile: e.organizerProfile,
        ),
        eventDetails: EventDetails(
          title: e.title,
          location: e.location,
          city: '',
          latitude: 0.0,
          longitude: 0.0,
          description: e.content,
          startTime: e.startTime,
          endTime: e.endTime,
          isFree: e.isFree,
          price: e.price,
        ),
      ))
          .toList();

      debugPrint("🎯 EventModels created: ${eventModels.length}");
      for (var e in eventModels) {
        debugPrint("✅ EventModel: ${e.title}, media count: ${e.media.length}, media: ${e.media}");
      }

      setState(() {
        _userPostHistory = events;
        _userEventModels = eventModels;
      });
    } catch (e) {
      debugPrint("❌ Failed to fetch posts: $e");
    }
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
      setState(() {
        List<dynamic> followers = _userProfileData['followers'] ?? [];

        final currentUserId = backendUserId;
        final isAlreadyFollowing = followers.any((user) => user['_id'] == currentUserId);

        if (isAlreadyFollowing) {
          // ✅ UNFOLLOW
          followers.removeWhere((user) => user['_id'] == currentUserId);
          isFollowing = false;
        } else {
          // ✅ FOLLOW
          followers.add({
            '_id': currentUserId,
            'name': 'You',
            'profile': '',
          });
          isFollowing = true;
        }

        _userProfileData['followers'] = followers;
      });
    }

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
    final eventsWithMedia = _userEventModels.where((e) => e.media.isNotEmpty).toList();

    final profileImage = profilePath.isNotEmpty
        ? NetworkImage(_fullImageUrl(profilePath))
        : const AssetImage('images/default_avatar.png') as ImageProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 100,
                              backgroundImage: profileImage,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.pink,
                  child: CircleAvatar(
                    radius: 57,
                    backgroundImage: profileImage,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Followers / Following
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(followers.length, 'Followers', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FollowListScreen(
                          title: 'Followers',
                          users: followers,
                        ),
                      ),
                    );
                  }),
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  _buildStat(following.length, 'Following', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FollowListScreen(
                          title: 'Following',
                          users: following,
                        ),
                      ),
                    );
                  }),
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
                        child: Text(isFollowing ? 'Unfollow' : 'Follow',
                            style: const TextStyle(color: Colors.white)),
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
                        style: const TextStyle(color: Colors.black),
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
                child:
                TabBarView(
                  controller: _tabController,
                  children: [


                    // Inside TabBarView (Tab 1)
                    Builder(
                      builder: (_) {
                        final postOnly = _userPostHistory
                            .where((e) => e.type?.toLowerCase() == 'post')
                            .toList();

                        return postOnly.isEmpty
                            ? const Center(child: Text('No posts available'))
                            : GridView.builder(
                          itemCount: postOnly.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemBuilder: (_, i) {
                            final post = postOnly[i];
                            final imageUrl = post.media.isNotEmpty ? post.media.first : post.image;

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                              ),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    _userEventModels.isEmpty
                        ? const Center(child: Text('No event media found'))
                        : GridView.builder(
                      itemCount: eventsWithMedia.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (_, i) {
                        final event = eventsWithMedia[i];
                        return GestureDetector(
                          onTap: () {
                            final convertedEvent = Event(
                              id: event.id,
                              title: event.title,
                              content: event.content,
                              location: event.eventDetails?.location ?? '',
                              startTime: event.eventDetails?.startTime ?? DateTime.now(),
                              endTime: event.eventDetails?.endTime ?? DateTime.now(),
                              isFree: event.eventDetails?.isFree ?? true,
                              price: event.eventDetails?.price ?? 0,
                              organizerId: event.user.id,
                              likes: event.likes.map((e) => e.toString()).toList(),
                              comments: [],
                              image: event.media.first,
                              media: event.media,
                              organizer: event.user.name,
                              organizerProfile: event.user.profile ?? '',
                              createdAt: event.createdAt,
                              type: event.type,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: convertedEvent),
                              ),
                            );
                          },
                          child: Image.network(
                            event.media.first, // ✅ use as-is
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        );
                      },
                    ),

                    const Center(child: Text('Past Activities')),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(int count, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.pink)),
      ],
    ),
  );
}