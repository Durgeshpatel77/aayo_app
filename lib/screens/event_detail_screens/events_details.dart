// Make sure this file is named event_detail_screen.dart and the class is EventDetailScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // ✅ Required for jsonEncode

import '../approve_event_screens/approve_screen.dart';
import 'chat_page.dart';
import 'ordersummart_screen.dart';

import '../../models/event_model.dart';
import '../other_for_use/expandable_text.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  EventDetailScreen({required this.event, super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isSaved = false;

  String generateChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  @override
  void initState() {
    super.initState();
    _loadLoggedInUserId();
    _checkIfEventIsSaved();
  }
  Future<void> _checkIfEventIsSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEvents = prefs.getStringList('savedEvents') ?? [];
    final eventJsonString = jsonEncode(widget.event.toJson());
    setState(() {
      isSaved = savedEvents.contains(eventJsonString);
    });
  }

  String? loggedInUserId;

  Future<void> _loadLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('backendUserId'); // ✅ This is the MongoDB ID
    debugPrint('🔐 Loaded logged-in MongoDB userId: $userId');
    setState(() {
      loggedInUserId = userId;
    });
  }

  Future<void> _toggleSaveEvent(Event event) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEvents = prefs.getStringList('savedEvents') ?? [];
    final eventJsonString = jsonEncode(event.toJson());

    if (savedEvents.contains(eventJsonString)) {
      savedEvents.remove(eventJsonString);
      await prefs.setStringList('savedEvents', savedEvents);
      setState(() => isSaved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } else {
      savedEvents.add(eventJsonString);
      await prefs.setStringList('savedEvents', savedEvents);
      setState(() => isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved to favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final double fontSize = (screenWidth * 0.03).clamp(10.0, 14.0);

    debugPrint('🔍 Organizer ID: ${widget.event.organizerId}');
    debugPrint('🔐 Logged-in User ID: $loggedInUserId');
    debugPrint("👤 Event Organizer ID: ${widget.event.organizerId}");

    final String imageUrl = widget.event.media.isNotEmpty
        ? getFullImageUrl(widget.event.media.first)
        : (widget.event.image.isNotEmpty
            ? getFullImageUrl(widget.event.image)
            : 'https://via.placeholder.com/400x200?text=No+Image');

    final String eventTitle = widget.event.title;
    final String eventLocation = widget.event.location;
    final DateTime startTime = widget.event.startTime;
    final DateTime endTime = widget.event.endTime;
    final double price = widget.event.price;
    final bool isFree = widget.event.isFree;
    final String organizerName = widget.event.organizer;
    final String organizerProfileUrl = widget.event.organizerProfile.isNotEmpty
        ? getFullImageUrl(widget.event.organizerProfile)
        : 'https://randomuser.me/api/portraits/men/75.jpg';
    final String eventContent = widget.event.content;
    // final int totalLikes = widget.event.likes.length; // This variable was declared but not used.

    String formattedDateTime = '';
    if (startTime.day == endTime.day &&
        startTime.month == endTime.month &&
        startTime.year == endTime.year) {
      formattedDateTime = '${DateFormat('EEE dMMM').format(startTime)} • '
          '${DateFormat('hh:mma').format(startTime)}  ';
    } else {
      formattedDateTime = '${DateFormat('EEEE,dMMM,hh:mma').format(startTime)}';
    }

    String priceDisplay = isFree ? "Free" : '₹${price.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.35,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.pink),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top + 10,
                    right: 22,
                    child: InkWell(
                      onTap: () => _toggleSaveEvent(widget.event),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        color: isSaved ? Colors.red : Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top + 10,
                    right: 22,
                    child: InkWell(
                      onTap: () {
                        _toggleSaveEvent(widget.event); // ✅ Save the event
                      },
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.35 - 80,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  eventTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                priceDisplay,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  eventLocation,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  formattedDateTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.event.type == 'event' &&
                      widget.event.organizerId == loggedInUserId)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          border: Border.all(color: Colors.pink, width: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'You have manage access for this event',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.pink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () {
                                  debugPrint(
                                      "👆 Tapped: ${widget.event.id} | ${widget.event.title} | type: ${widget.event.type}");
                                  debugPrint(
                                      "👤 Organizer ID: ${widget.event.organizerId}");
                                  debugPrint(
                                      "🔐 Logged-in ID: $loggedInUserId");

                                  if (widget.event.id.isNotEmpty &&
                                      widget.event.type == 'event') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ApproveScreen(
                                            eventId: widget.event.id),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "This is not a valid event.")),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.pink,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Manage ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Icon(Icons.north_east,
                                          color: Colors.white, size: 15),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 18),
                  const Text('About',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    eventContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                  const Text('Organizers and Attendees',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(organizerProfileUrl),
                    ),
                    title: const Text(
                      'Organizers',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      organizerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        final currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final peerUserId = widget.event.organizerId;
                        final peerName = widget.event.organizer;

                        final chatId =
                            generateChatId(currentUserId, peerUserId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              currentUserId: currentUserId,
                              peerUserId: peerUserId,
                              peerName: peerName,
                              chatId: chatId,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'images/message_send.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    height: 30,
                  ),
                  const Text('Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 180,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'images/location.jpeg', // ✅ your local image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const Center(
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.pinkAccent,
                            child: Icon(
                              Icons.location_searching_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () async {
                              final lat = widget.event
                                  .latitude; // This variable was declared but not used.
                              final lng = widget.event
                                  .longitude; // This variable was declared but not used.

                              final Uri googleMapsUrl = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
                              );

                              if (await canLaunchUrl(googleMapsUrl)) {
                                await launchUrl(googleMapsUrl,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Could not open Google Maps')),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'See Location',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final String currentUserId = loggedInUserId ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderSummaryScreen(
                            eventName: eventTitle,
                            eventDate:
                                DateFormat('EEE d MMM').format(startTime),
                            eventTime: DateFormat('hh:mm a').format(startTime),
                            eventLocation: eventLocation,
                            eventImageUrl: imageUrl,
                            ticketPrice: price,
                            eventId: widget.event.id, // ✅ actual event ID
                            joinedBy:
                                currentUserId, // ✅ actual user ID (e.g. from Firebase or auth state)
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text(
                      'Buy Ticket',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
