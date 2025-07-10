import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../providers/home_screens_providers/add_post_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../../providers/setting_screens_providers/event_provider.dart';
import '../event_detail_screens/events_details.dart';
import '../login_and_onbording_screens/edit_profile_screen.dart';
import '../setting_screens/setting_screen.dart';
import 'create_post_screen.dart';
import 'follow_list_screen.dart';

class UserProfileList extends StatefulWidget {
  const UserProfileList({super.key});

  @override
  State<UserProfileList> createState() => _UserProfileListState();
}

class _UserProfileListState extends State<UserProfileList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;
  List<Event> _userPostPhotos = [];
  List<EventModel> _userEvents = [];
  List<EventModel> _pastEvents = [];

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
      final eventsProvider =
          Provider.of<EventCreationProvider>(context, listen: false);

      final posts = await postProvider.fetchMyPosts();
      await eventsProvider.fetchUserPostsFromPrefs(type: 'event');
      await eventsProvider.fetchPastEventsFromPrefs(); // 🆕 fetch past events

      setState(() {
        _userPostPhotos = posts;
        _userEvents = eventsProvider.createdEvents;
        _pastEvents = eventsProvider.pastEvents; // 🆕 store in state
      });
    } catch (e) {
      debugPrint('Failed to fetch posts or events: $e');
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
      color: Colors.pink,
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
              scrolledUnderElevation: 0,
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
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 100,
                                  backgroundImage: profileImg,
                                  backgroundColor: Colors.pink.shade200,
                                  child: profileImg is AssetImage
                                      ? Text(
                                          name[0].toUpperCase(),
                                          style: const TextStyle(
                                              fontSize: 50,
                                              color: Colors.white),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.pink,
                        child: CircleAvatar(
                          radius: 57,
                          backgroundImage: profileImg,
                          backgroundColor: Colors.pink.shade200,
                          child: profileImg is AssetImage
                              ? Text(
                                  name[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 40, color: Colors.white),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(followersCount, 'Followers'),
                        Container(
                            height: 40, width: 1, color: Colors.grey[300]),
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
                              MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen()),
                            );
                            _fetchProfile(); // Re-fetch profile data when returning from EditProfileScreen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Edit Profile',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign
                                .left, // Optional: ensures explicit alignment
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

  Widget _buildStat(int count, String label) {
    return InkWell(
      onTap: () async {
        final provider =
            Provider.of<FetchEditUserProvider>(context, listen: false);
        final data = provider.userData;

        final users = label == 'Followers'
            ? (data['followers'] ?? [])
            : (data['following'] ?? []);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FollowListScreen(title: label, users: users),
          ),
        );

        _fetchProfile();
      },
      child: Column(
        children: [
          Text('$count',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.pink)),
        ],
      ),
    );
  }

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
                            MaterialPageRoute(
                                builder: (_) => const AddPostScreen()),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_box_outlined,
                                  size: 80, color: Colors.pink),
                              SizedBox(height: 16),
                              Text('Add your first post',
                                  style: TextStyle(color: Colors.pink)),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _userPostPhotos.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
                _userEvents.isEmpty
                    ? const Center(child: Text('No events found'))
                    : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _userEvents.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemBuilder: (_, i) {
                          final event = _userEvents[i];
                          final hasMedia = event.media.isNotEmpty;
                          final firstImageUrl = hasMedia
                              ? 'http://82.29.167.118:8000/${event.media.first}'
                              : 'https://via.placeholder.com/300x200.png?text=No+Image';

                          return GestureDetector(
                            onTap: () {
                              final convertedEvent = Event(
                                id: event.id,
                                title: event.title,
                                content: event.content,
                                location: event.eventDetails?.location ?? '',
                                startTime: event.eventDetails?.startTime ??
                                    DateTime.now(),
                                endTime: event.eventDetails?.endTime ??
                                    DateTime.now(),
                                isFree: event.eventDetails?.isFree ?? true,
                                price: event.eventDetails?.price ?? 0,
                                organizerId: event.user.id,
                                likes: event.likes
                                    .map((e) => e.toString())
                                    .toList(),
                                comments: [], // You can map this if needed
                                image: firstImageUrl,
                                media: event.media
                                    .map((url) =>
                                        'http://82.29.167.118:8000/$url')
                                    .toList(),
                                organizer: event.user.name,
                                organizerProfile: event.user.profile ?? '',
                                createdAt: event.createdAt,
                                type: event.type,
                                latitude: event.eventDetails?.latitude ?? 0.0,
                                longitude: event.eventDetails?.longitude ?? 0.0,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailScreen(event: convertedEvent),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                firstImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          );
                        },
                      ),
                _pastEvents.isEmpty
                    ? const Center(child: Text("No past events"))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pastEvents.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemBuilder: (_, i) {
                          final event = _pastEvents[i];
                          final imageUrl = event.media.isNotEmpty
                              ? 'http://82.29.167.118:8000/${event.media.first}'
                              : 'https://via.placeholder.com/300x200.png?text=No+Image';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EventDetailScreen(
                                    event: Event(
                                      id: event.id,
                                      title: event.title,
                                      content: event.content,
                                      location:
                                          event.eventDetails?.location ?? '',
                                      startTime:
                                          event.eventDetails?.startTime ??
                                              DateTime.now(),
                                      endTime: event.eventDetails?.endTime ??
                                          DateTime.now(),
                                      isFree:
                                          event.eventDetails?.isFree ?? true,
                                      price: event.eventDetails?.price ?? 0,
                                      organizerId: event.user.id,
                                      likes: [],
                                      comments: [],
                                      image: imageUrl,
                                      media: event.media
                                          .map((m) =>
                                              'http://82.29.167.118:8000/$m')
                                          .toList(),
                                      organizer: event.user.name,
                                      organizerProfile:
                                          event.user.profile ?? '',
                                      createdAt: event.createdAt,
                                      type: event.type,
                                      latitude:
                                          event.eventDetails?.latitude ?? 0.0,
                                      longitude:
                                          event.eventDetails?.longitude ?? 0.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      );
}
