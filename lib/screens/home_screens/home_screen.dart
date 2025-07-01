// lib/screens/home_screens/home_tab_content.dart (home_screen.dart)

// ... (existing imports - ensure correct path for UserProfileProvider)
import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:aayo/screens/home_screens/single_user_profile_screen.dart';
import 'package:aayo/screens/home_screens/userprofile_list.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String highlight;
  final bool isBooked;


  const EventCard({required this.event,required this.highlight,  this.isBooked=false,super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLiked = false;
  int likeCount = 0;
  late int _commentCount;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showHeart = false;

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
      final userId =
          Provider.of<FetchEditUserProvider>(context, listen: false).userId;
      setState(() {
        isLiked = userId != null && widget.event.likes.contains(userId);
        likeCount = widget.event.likes.length;
      });
    });
  }

  Future<void> _playLikeSound() async {
    try {
      debugPrint('🔊 Playing like sound...');
      await _audioPlayer.play(AssetSource('sounds/like.mp3'));
      HapticFeedback.mediumImpact(); // Optional vibration
    } catch (e) {
      debugPrint('🔇 Sound error: $e');
    }
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

    final wasLiked = isLiked;

    // ✅ Optimistic UI update
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    if (isLiked && !wasLiked) {
      _playLikeSound();
    }

    try {
      final response = await userProfileProvider.toggleLike(
        postId: widget.event.id,
        userId: currentUserId,
      );

      if (response['success'] == true) {
        final updatedLikes = List<String>.from(response['likes'] ?? []);
        Provider.of<HomeProvider>(context, listen: false)
            .updateEventLikes(widget.event.id, updatedLikes);

        if (isLiked && widget.event.organizerId != currentUserId) {
          final recipientFcmToken = widget.event.organizerFcmToken;
          debugPrint("📦 Organizer FCM token in EventCard: $recipientFcmToken");

          if (recipientFcmToken != null && recipientFcmToken.isNotEmpty) {
            // ✅ Use post or event image for notification
            final contentImage = widget.event.image;
            debugPrint("🖼️ Post/Event image sent: $contentImage");

            final isEvent = widget.event.type == "event";
            final likeTypeText = isEvent ? "event" : "post";
            final bodyText =
                "${userProfileProvider.name ?? "Someone"} liked your $likeTypeText";

            final fcmResponse = await http.post(
              Uri.parse('http://srv861272.hstgr.cloud:8000/api/send-notification'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "fcmToken": recipientFcmToken,
                "title": "❤️ New Like",
                "body": bodyText,
                "image": contentImage, // ✅ Shows post/event image in notification
                "data": {
                  "userId": currentUserId,
                  "userName": userProfileProvider.name ?? "",
                  "userAvatar": contentImage, // ✅ Also update avatar to match
                  "vendorId": widget.event.id,
                  "vendorName": widget.event.organizer,
                }
              }),
            );

            debugPrint('📨 Notification Response: ${fcmResponse.statusCode}');
            debugPrint('📨 Notification Body: ${fcmResponse.body}');

            // ✅ Log notification
            await http.post(
              Uri.parse('http://srv861272.hstgr.cloud:8000/api/notification'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "user": widget.event.organizerId,
                "message": bodyText,
              }),
            );
          } else {
            debugPrint("🚫 Organizer FCM token is missing or empty");
          }
        }
      } else {
        setState(() {
          isLiked = wasLiked;
          likeCount += isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      setState(() {
        isLiked = wasLiked;
        likeCount += isLiked ? 1 : -1;
      });
      debugPrint('❌ Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update like: $e")),
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
        event: widget.event, // ✅ ADD THIS
        recipientFcmToken: widget.event.organizerFcmToken ??'', // ✅ pass this dynamically

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

  TextSpan _buildHighlightedText(String text, String highlight) {
    if (highlight.isEmpty) {
      return TextSpan(text: text, style: const TextStyle(color: Colors.black));
    }

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int index;
    while ((index = lowerText.indexOf(lowerHighlight, start)) != -1) {
      if (index > start) {
        matches.add(TextSpan(text: text.substring(start, index)));
      }
      matches.add(TextSpan(
        text: text.substring(index, index + highlight.length),
        style: const TextStyle(
          backgroundColor: Colors.pinkAccent, // 🎨 pink highlight
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + highlight.length;
    }
    if (start < text.length) {
      matches.add(TextSpan(text: text.substring(start)));
    }

    return TextSpan(
        children: matches, style: const TextStyle(color: Colors.black));
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
                ExpandableText(
                  content: widget.event.content,
                  wordLimit: 20, // You can customize this
                  textColor: Colors.black,
                  linkColor: Colors.pink,
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Image
          if (imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: () {
                _toggleLike();
                setState(() => _showHeart = true);
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (mounted) {
                    setState(() => _showHeart = false);
                  }
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl, // your event image
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),

                  // ❤️ Big Heart animation
                  AnimatedOpacity(
                    opacity: _showHeart ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 100,
                    ),
                  ),
                ],
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
                          builder: (_) =>
                              EventDetailScreen(event: widget.event),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
  final TextEditingController _searchController = TextEditingController();
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocationOnce(); // 👈 fetch location only once
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _fetchCurrentLocationOnce() async {
    if (_locationFetched) return; // ✅ Already fetched

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
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
          _locationFetched = true; // ✅ Set flag to true
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to fetch location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.pink,
      onRefresh: () async {
        await Provider.of<HomeProvider>(context, listen: false).fetchAll();
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
              ],
            ),
            const SizedBox(height: 20),

            // Search
            TextField(
              controller: _searchController,
              onChanged: (value) {
                final query = value.trim();
                if (query.isNotEmpty) {
                  Provider.of<HomeProvider>(context, listen: false)
                      .searchPostsAndEvents(query);
                } else {
                  Provider.of<HomeProvider>(context, listen: false).fetchAll();
                }
              },
              decoration: InputDecoration(
                hintText: "Search Events and Posts",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<HomeProvider>(context, listen: false).fetchAll();
                    FocusScope.of(context).unfocus(); // optionally hide keyboard
                  },
                )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pink),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pink, width: 2),
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
              children: [
                if (widget.isLoading)
                  ...List.generate(5, (_) => const EventCardShimmer())
                else if (widget.allEvents.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No relevant search found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...widget.allEvents.map((event) {
                    return GestureDetector(
                      onTap: () => widget.onItemTapped(event),
                      child: EventCard(
                        event: event,
                        highlight: _searchController.text
                            .trim(), // 👈 add this if using highlight
                      ),
                    );
                  }).toList(),
              ],
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
  void initState() {
    super.initState();
    _userProfileProvider =
        Provider.of<FetchEditUserProvider>(context, listen: false);
    _userProfileProvider.addListener(_onUserProviderChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFCMAndLoadData(); // ✅ Safe now
    });
  }

  Future<void> _initFCMAndLoadData() async {
    await _userProfileProvider.loadUserId();

    if (_userProfileProvider.userId != null) {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        debugPrint('📡 FCM Token: $fcmToken');
        await _userProfileProvider.updateFcmToken(fcmToken); // ✅ Dynamic and cached
      }

      await Provider.of<HomeProvider>(context, listen: false).fetchAll();
    }
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
        }
      });
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
            // ✅ Close keyboard first if open
            final currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
              return false; // handled back press to close keyboard
            }

            // ✅ If not on home tab, go to home tab
            if (homeProvider.selectedIndex != 0) {
              homeProvider.setSelectedIndex(0);
              return false;
            }

            // ✅ Show exit confirmation
            DateTime now = DateTime.now();
            if (_lastBackPressTime == null ||
                now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
              _lastBackPressTime = now;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tap again to exit')),
              );
              return false;
            }

            return true; // exit app
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Container(
                color: Colors.grey.shade100, // optional background color
                child: Column(
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: homeProvider.selectedIndex,
                        children: allScreens,
                      ),
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
