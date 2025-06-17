  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

  import '../../models/event_model.dart';
  import '../../providers/home_screens_providers/home_provider.dart';
  import '../event_detail_screens/events_details.dart';
  import 'add_events_screen.dart';
  import 'events_screen.dart';
  import 'notification_screen.dart';
  import 'userprofile_list.dart';

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

    @override
    @override
    Widget build(BuildContext context) {
      const String baseUrl = 'http://srv861272.hstgr.cloud:8000';

      final String imageUrl = widget.event.media.isNotEmpty
          ? (widget.event.media.first.startsWith('http')
          ? widget.event.media.first
          : '$baseUrl/${widget.event.media.first}')
          : '';

      return Container(
        height: 270,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                  );
                },
              )
            else
              const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 64,
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),

            // Event title
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Text(
                widget.event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Like & Comment icons
            Positioned(
              top: 50,
              bottom: 12,
              right: 0,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 33,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text(
                    '$likeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.comment_outlined,
                      color: Colors.white,
                      size: 33,
                    ),
                    onPressed: _showCommentDialog,
                  ),
                  Text(
                    '$commentCount',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }


  // ---- CommentSheet ----
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
            const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            for (final comment in _comments)
              ListTile(leading: const Icon(Icons.person), title: Text(comment)),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _submit),
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
    final List<Event> allEvents;
    final Function(String) onEventTapped;

    const HomeTabContent({
      required this.allEvents,
      required this.onEventTapped,
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (ctx) => const Notificationscreen()));
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: "Search Events",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                child: Text("All Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              Column(
                children: allEvents.map((event) {
                  return GestureDetector(
                    onTap: () => onEventTapped(event.title),
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

    void _onEventTapped(BuildContext context, String eventName) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(eventName: eventName)),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Consumer<HomeProvider>(
        builder: (context, eventProvider, child) {
          final allScreens = [
            HomeTabContent(
              allEvents: eventProvider.allEvents,
              onEventTapped: (name) => _onEventTapped(context, name),
            ),
            Eventsscreen(),
            Addeventsscreen(),
            const Notificationscreen(),
            const UserProfileList(),
          ];

          return WillPopScope(
            onWillPop: () async {
              if (eventProvider.selectedIndex != 0) {
                eventProvider.setSelectedIndex(0);
                return false;
              }
              DateTime now = DateTime.now();
              if (_lastBackPressTime == null ||
                  now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
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
              body: SafeArea(child: allScreens[eventProvider.selectedIndex]),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: eventProvider.selectedIndex,
                onTap: eventProvider.setSelectedIndex,
                selectedItemColor: Colors.pink,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
                  BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: "Add"),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
                ],
              ),
            ),
          );
        },
      );
    }
  }
