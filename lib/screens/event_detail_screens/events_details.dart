// Make sure this file is named event_detail_screen.dart and the class is EventDetailScreen
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../res/app_colors.dart';
import '../approve_event_screens/approve_screen.dart';
import 'chat_page.dart';
import 'ordersummart_screen.dart';

// Make sure this import path is correct for your Event model
import '../../models/event_model.dart'; // Ensure this points to the file with the 'Event' class
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart'; // For timeAgo function

class EventDetailScreen extends StatelessWidget {
  final Event event;

  EventDetailScreen({required this.event, super.key});

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
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final String imageUrl = event.media.isNotEmpty
        ? getFullImageUrl(event.media.first)
        : (event.image.isNotEmpty
        ? getFullImageUrl(event.image)
        : 'https://via.placeholder.com/400x200?text=No+Image');

    final String eventTitle = event.title;
    final String eventLocation = event.location;
    final DateTime startTime = event.startTime;
    final DateTime endTime = event.endTime;
    final double price = event.price;
    final bool isFree = event.isFree;
    final String organizerName = event.organizer;
    final String organizerProfileUrl = event.organizerProfile.isNotEmpty
        ? getFullImageUrl(event.organizerProfile)
        : 'https://randomuser.me/api/portraits/men/75.jpg';
    final String eventContent = event.content;
    final int totalLikes = event.likes.length;

    String formattedDateTime = '';
    if (startTime.day == endTime.day &&
        startTime.month == endTime.month &&
        startTime.year == endTime.year) {
      formattedDateTime = '${DateFormat('EEE dMMM').format(startTime)} • '
          '${DateFormat('hh:mma').format(startTime)}  ';
    } else {
      formattedDateTime =
      '${DateFormat('EEEE,dMMM,hh:mma').format(startTime)}';
    }

    String priceDisplay = isFree ? "Free" : '₹${price.toStringAsFixed(0)}';

    final int totalAttendees = 45;
    final List<String> visibleAttendeeAvatars = [
      'https://randomuser.me/api/portraits/women/68.jpg',
      'https://randomuser.me/api/portraits/women/65.jpg',
      'https://randomuser.me/api/portraits/women/66.jpg',
      'https://randomuser.me/api/portraits/women/67.jpg',
      'https://randomuser.me/api/portraits/men/45.jpg',
    ];
    final int otherAttendees = totalAttendees - visibleAttendeeAvatars.length;

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
                    left: 22,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top + 10,
                    right: 22,
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Spacer(),
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
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
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
                              SizedBox(
                                width: (visibleAttendeeAvatars.length * 23 +
                                    (otherAttendees > 0 ? 30 : 0))
                                    .toDouble(),
                                height: 36,
                                child: Stack(
                                  children: [
                                    ...List.generate(
                                      visibleAttendeeAvatars.length,
                                          (index) {
                                        return Positioned(
                                          left: (index * 20).toDouble(),
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundImage: NetworkImage(
                                                visibleAttendeeAvatars[index]),
                                          ),
                                        );
                                      },
                                    ),
                                    if (otherAttendees > 0)
                                      Positioned(
                                        left: (visibleAttendeeAvatars.length * 20)
                                            .toDouble(),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.pinkAccent,
                                          radius: 18,
                                          child: Text(
                                            "+$otherAttendees",
                                            style: const TextStyle(
                                                color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                  ],
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
                  if (event.type == 'event')
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
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'You have manage access for this event',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.pink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ApproveScreen(eventId: event.id),
                                ),
                              );
                            },
                            child: Container(
                              width: screenWidth * 0.2,
                              height: screenHeight * 0.04,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.pink,
                              ),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: "Manage ",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      WidgetSpan(
                                        child: Icon(
                                          Icons.north_east,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  const Text('About',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ExpandableText(
                    content: eventContent,
                    textColor: Colors.grey[700]!,
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade300,),
                  const Text('Organizers and Attendees',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 85,
                        height: 50,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(organizerProfileUrl),
                              ),
                            ),
                            Positioned(
                              left: 35,
                              child: CircleAvatar(
                                backgroundColor: Colors.pinkAccent,
                                radius: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "$totalLikes",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Organizers',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                )),
                            Text(organizerName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                currentUserId: 'your_user_id',
                                peerUserId: 'organizer_id_fallback',
                                peerName: organizerName,
                                chatId: generateChatId(
                                    'your_user_id', 'organizer_id_fallback'),
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.forum_outlined,
                          size: 36,
                          color: Colors.pink.shade400,
                        ),
                      )
                    ],
                  ),
                   Divider(color: Colors.grey.shade300,height: 30,),
                  const Text('Location',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 180,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://media.istockphoto.com/id/1306807452/vector/map-city-vector-illustration.jpg?s=612x612&w=0&k=20&c=8efOIy-Ft3trEzeDk3PY2WRjWws8mvKXgkLqCZ2cP5A=',
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
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('See Location Tapped')),
                              );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderSummaryScreen(
                            eventName: eventTitle,
                            eventDate: DateFormat('EEE d MMM').format(startTime),
                            eventTime: DateFormat('hh:mm a').format(startTime),
                            eventLocation: eventLocation,
                            eventImageUrl: imageUrl,
                            ticketPrice: price,
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