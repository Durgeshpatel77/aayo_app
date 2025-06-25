// lib/screens/home_screens/home_tab_content.dart (home_screen.dart)

// ... (existing imports - ensure correct path for UserProfileProvider)
import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:aayo/screens/home_screens/single_user_profile_screen.dart';
import 'package:aayo/screens/home_screens/userprofile_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/comment_model.dart';
import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../other_for_use/event_card_shimmer.dart';
import '../event_detail_screens/events_details.dart';
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart';
import 'comment_sheet.dart';
import 'create_post_screen.dart';
import 'events_screen.dart';
import 'notification_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ---- EventCard ----
// lib/screens/home_screens/home_tab_content.dart (home_screen.dart)

// ... (existing imports)

// ---- EventCard ----
class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({required this.event, super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLiked = false;
  int likeCount = 0;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.event.comments.length;
    _updateLikeState(); // Initial setup
  }

  // ✅ ADD OR ENSURE THIS METHOD IS CORRECT
  @override
  void didUpdateWidget(covariant EventCard oldWidget) {
    if (widget.event.likes.length != oldWidget.event.likes.length) {
      _updateLikeState();
    }
  }

  // Helper to set isLiked and likeCount based on current widget.event and userId
  void _updateLikeState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<FetchEditUserProvider>(context, listen: false).userId;
      setState(() {
        isLiked = userId != null && widget.event.likes.contains(userId);
        likeCount = widget.event.likes.length;
      });
    });
  }


  void _toggleLike() async {
    final userProfileProvider =
    Provider.of<FetchEditUserProvider>(context, listen: false);
    final currentUserId = userProfileProvider.userId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to like this.")),
      );
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    // Optimistic update
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    try {
      final response = await userProfileProvider.toggleLike(
        postId: widget.event.id,
        userId: currentUserId,
      );

      debugPrint('✅ Like API response: $response');

      if (response['success']) {
        final updatedLikes = (response['likes'] as List)
            .map((like) {
          if (like is String) return like;
          if (like is Map && like['_id'] is String) return like['_id'] as String;
          return null;
        })
            .whereType<String>()
            .toList();
        debugPrint('✅ Updated Likes: $updatedLikes');

        homeProvider.updateEventLikes(widget.event.id, updatedLikes);
      } else {
        // Revert optimistic update on failure
        setState(() {
          isLiked = !isLiked;
          likeCount += isLiked ? 1 : -1;
        });
        final msg = response['message'] ?? 'Failed to update like.';
        debugPrint('❌ Like failed: $msg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e, stackTrace) {
      // Revert optimistic update on error
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });

      debugPrint('❌ Like error: $e');
      debugPrint('📍 StackTrace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showCommentDialog() async {
    final updatedComments = await showModalBottomSheet<List<CommentModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CommentSheet(
        initialComments: widget.event.comments,
        postId: widget.event.id,
        postOwnerId: widget.event.organizerId,
        onCommentCountChange: (newCount) {
          setState(() => _commentCount = newCount);
        },
      ),
    );

    if (updatedComments != null) {
      Provider.of<HomeProvider>(context, listen: false)
          .updateEventComments(widget.event.id, updatedComments);
    }
  }

  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<FetchEditUserProvider>(context);
    final currentUserId = userProfileProvider.userId;

    final String imageUrl = widget.event.media.isNotEmpty
        ? getFullImageUrl(widget.event.media.first)
        : (widget.event.image.isNotEmpty
        ? getFullImageUrl(widget.event.image)
        : '');

    final String profileUrl = widget.event.organizerProfile.isNotEmpty
        ? getFullImageUrl(widget.event.organizerProfile)
        : 'https://randomuser.me/api/portraits/men/75.jpg';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 0.2, color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (User Info)
          InkWell(
            onTap: () {
              if (widget.event.organizerId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleUserProfileScreen(
                      userId: widget.event.organizerId,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("User profile ID not available.")),
                );
              }
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profileUrl.isNotEmpty
                    ? NetworkImage(profileUrl)
                    : const AssetImage('images/onbording/unkown.jpg')
                as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint(
                      'Error loading profile image for ${widget.event.organizer}: $exception');
                },
                child: profileUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              trailing: widget.event.type == 'event'
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.pink, width: 1),
                ),
                child: Text(
                  'EVENT',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.pink.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : null,
              title: Text(
                widget.event.organizer,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(timeAgo(widget.event.createdAt)),
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                ExpandableText(content: widget.event.content),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Image
          if (imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 40),
                  fadeInDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),

          // Like, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 24,
                            color: isLiked ? Colors.redAccent : Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(likeCount.toString(),
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showCommentDialog,
                      child: Row(
                        children: [
                          Image.asset(
                            'images/chat_icon.png',
                            width: 22,
                            height: 22,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(width: 7),
                          Text(
                            _commentCount.toString(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
                const Spacer(), // pushes register button to the right
                if (widget.event.type == 'event')
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: widget.event),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconText(IconData icon, String text,
      {VoidCallback? onTap, Color color = Colors.grey}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(text, style: const TextStyle(fontSize: 16)),
          ]
        ],
      ),
    );
  }
}


// ---- CommentSheet (No changes needed, including for your reference) ----
// ---- HomeTabContent (No changes needed, including for your reference) ----

class HomeTabContent extends StatefulWidget {
  final List<Event> allEvents;
  final bool isLoading;
  final void Function(Event) onItemTapped;

  const HomeTabContent({
    required this.allEvents,
    required this.isLoading,
    required this.onItemTapped,
    super.key,
  });

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  String? _currentCity;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        if (!mounted) return;
        setState(() {
          _currentCity = '${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.pink,
      onRefresh: () async {
        await Provider.of<HomeProvider>(context, listen: false).fetchAll();
        await _fetchCurrentLocation(); // Refresh location too
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location + Notification
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.pink),
                const SizedBox(width: 8),
                Text(
                  _currentCity ?? 'Fetching location...',
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // TODO: Navigate to notification screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search Events and Posts",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                "All Posts and Events",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Column(
              children: widget.isLoading
                  ? List.generate(5, (_) => const EventCardShimmer())
                  : widget.allEvents.isEmpty
                      ? [
                          const SizedBox(height: 250),
                          const Center(
                            child: Text(
                              "No events or posts available.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ]
                      : widget.allEvents.map((event) {
                          return GestureDetector(
                            onTap: () => widget.onItemTapped(event),
                            child: EventCard(event: event),
                          );
                        }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---- HomeScreen ----

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;
  bool _initialized = false;
  late FetchEditUserProvider _userProfileProvider;
  bool isLiked = false;
  int likeCount = 0;

  @override
  @override
  void initState() {
    super.initState();
    _userProfileProvider =
        Provider.of<FetchEditUserProvider>(context, listen: false);
    _userProfileProvider.addListener(_onUserProviderChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _userProfileProvider.loadUserId(); // <-- Wait for this
        if (_userProfileProvider.userId != null) {
          await Provider.of<HomeProvider>(context, listen: false).fetchAll();
        }});
    }
  }

  void _onUserProviderChange() {
    // This method is called whenever notifyListeners() is called in UserProfileProvider
    // If the userId has just become available (i.e., user logged in or ID loaded from storage), refresh events
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    debugPrint(
        'HomeScreen: _onUserProviderChange - User ID changed to: ${_userProfileProvider.userId}');
    if (_userProfileProvider.userId != null) {
      // Fetch all events again to get updated like status for the loaded user
      homeProvider.fetchAll();
    }
  }

  @override
  void dispose() {
    _userProfileProvider.removeListener(_onUserProviderChange);
    super.dispose();
  }

  void _onItemTapped(BuildContext context, Event item) {
    if (item.isEvent) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: item)),
      );
    } else if (item.isPost) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PostDetailScreen(post: item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final allScreens = [
          HomeTabContent(
            allEvents: homeProvider.allEvents,
            isLoading: homeProvider.isLoading,
            onItemTapped: (item) => _onItemTapped(context, item),
          ),
          const Eventsscreen(),
          AddPostScreen(),
          const Notificationscreen(),
          const UserProfileList(),
        ];
        return WillPopScope(
          onWillPop: () async {
            if (homeProvider.selectedIndex != 0) {
              homeProvider.setSelectedIndex(0);
              return false;
            }
            DateTime now = DateTime.now();
            if (_lastBackPressTime == null ||
                now.difference(_lastBackPressTime!) >
                    const Duration(seconds: 2)) {
              _lastBackPressTime = now;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tap again to exit')),
              );
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Container(
                color: Colors.grey.shade100, // optional background color
                child: Column(
                  children: [
                    Expanded(
                      child: allScreens[homeProvider.selectedIndex],
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: homeProvider.selectedIndex,
              onTap: homeProvider.setSelectedIndex,
              selectedItemColor: Colors.pink,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.event), label: "Events"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline), label: "Add"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.notifications), label: "Notification"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
              ],
            ),
          ),
        );
      },
    );
  }
}
