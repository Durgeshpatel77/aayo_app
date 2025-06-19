// lib/screens/home_screens/home_tab_content.dart

// ... (existing imports)
import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:aayo/screens/home_screens/userprofile_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../other_for_use/event_card_shimmer.dart';
import '../event_detail_screens/events_details.dart';
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart';
import 'create_post_screen.dart';
import 'events_screen.dart';
import 'notification_screen.dart'; // Existing event detail screen

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
  int commentCount = 0;
  late List<String> comments;

  @override
  void initState() {
    super.initState();
    likeCount = widget.event.likes.length;
    commentCount = widget.event.comments.length;
    comments = List.from(widget.event.comments);
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void _showCommentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CommentSheet(
        initialComments: comments,
        onAddComment: (comment) {
          setState(() {
            comments.add(comment);
            commentCount += 1;
          });
        },
      ),
    );
  }

  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.event.media.isNotEmpty
        ? getFullImageUrl(widget.event.media.first)
        : (widget.event.image.isNotEmpty ? getFullImageUrl(widget.event.image) : ''); // Prioritize media, then image

    final String profileUrl = widget.event.organizerProfile.isNotEmpty
        ? getFullImageUrl(widget.event.organizerProfile)
        : 'https://randomuser.me/api/portraits/men/75.jpg'; // Fallback for profile

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
              // Navigate to UserProfileList when tapping on the user info
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileList(),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: profileUrl.isNotEmpty
                    ? NetworkImage(profileUrl)
                    : const AssetImage('images/onbording/unkown.jpg') as ImageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading profile image for ${widget.event.organizer}: $exception');
                },
                child: profileUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                widget.event.organizer,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(timeAgo(widget.event.createdAt)),
          ),
          ),
          // Event/Post Title & Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //ExpandableText(content: widget.event.title),
                const SizedBox(height: 5),
                ExpandableText(content: widget.event.content),

              ],
            ),
          ),
          const SizedBox(height: 10),

          // Event/Post Image (conditional)
          if (imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0), // Keep as 0 for full width
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
                  const Icon(Icons.broken_image),
                  fadeInDuration: const Duration(milliseconds: 300),
                ),
              ),
            ),

          // Like Row with avatars and like text
          // Like Row with avatars and like text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                      'https://cdn.pixabay.com/photo/2013/05/13/06/18/forest-110900_1280.jpg'),
                ),
                const SizedBox(width: 4),
                const CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                      'https://cdn.pixabay.com/photo/2023/09/21/14/17/italy-8266783_1280.jpg'),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: "Liked by "),
                      TextSpan(
                        text: "krilibooo",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "dianafreya",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),          // Actions: Like, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Like Button
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 24,
                            color: isLiked ? Colors.redAccent : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(likeCount.toString(), style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Comment Button
                    _iconText(Icons.comment_outlined, commentCount.toString(),
                        onTap: _showCommentDialog),
                  ],
                ),
                // Share Button
                _iconText(Icons.send_outlined, '', onTap: () {
                  // Implement share functionality
                }),
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
      onTap: onTap, // Use the provided onTap directly
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

// ---- CommentSheet (No changes needed) ----
// ... (Your existing CommentSheet code here)
class CommentSheet extends StatefulWidget {
  final List<String> initialComments;
  final void Function(String) onAddComment;

  const CommentSheet({
    required this.initialComments,
    required this.onAddComment,
    super.key,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAddComment(text);
      setState(() => _comments.add(text));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Expanded( // Use Expanded for the ListView.builder for scrollability
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(_comments[index]),
                );
              },
            ),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              suffixIcon:
              IconButton(icon: const Icon(Icons.send_outlined), onPressed: _submit),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- HomeTabContent ----
class HomeTabContent extends StatelessWidget {
  final List<Event> allEvents; // Now this list can contain both events and posts
  final bool isLoading;
  // This callback now takes an Event object instead of just a name
  final void Function(Event) onItemTapped;

  const HomeTabContent({
    required this.allEvents,
    required this.isLoading,
    required this.onItemTapped,
    super.key,
  });

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
                const Text("Ahmedabad, Gujarat",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const Notificationscreen()));
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search
            TextField(
              decoration: InputDecoration(
                hintText: "Search Events and Posts", // Updated hint text
                prefixIcon: const Icon(Icons.search),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text("People You Might Know",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Column(children: []), // Placeholder for user profiles
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text("All Posts and Events", // Updated header text
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            Column(
              children: isLoading
                  ? List.generate(5, (_) => const EventCardShimmer())
                  : allEvents.map((event) { // Iterate through all events/posts
                return GestureDetector(
                  onTap: () => onItemTapped(event), // Pass the full event object
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<HomeProvider>(context, listen: false).fetchAll();
      });
    }
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
        // You'll need a way to get an EventModel here if you choose this option.
        // For demonstration, let's assume you have a dummy or the first event from your provider.
        // This is highly dependent on your app's logic.
        final Event? firstEvent = homeProvider.allEvents.isNotEmpty
            ? homeProvider.allEvents.first // Assuming allEvents holds EventModel or can be converted
            : null; // Or create a dummy EventModel

// ... inside _HomeScreenState build method
        final allScreens = [
          HomeTabContent(
            allEvents: homeProvider.allEvents,
            isLoading: homeProvider.isLoading,
            onItemTapped: (item) => _onItemTapped(context, item),
          ),
          const Eventsscreen(), // Now it can be created without an argument
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
            body: SafeArea(child: allScreens[homeProvider.selectedIndex]),
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
