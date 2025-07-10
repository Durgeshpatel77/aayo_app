import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/comment_model.dart';
import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../providers/setting_screens_providers/event_provider.dart';
import 'chat_list_page.dart';
import '../event_detail_screens/events_details.dart';

class Eventsscreen extends StatefulWidget {
  const Eventsscreen({super.key});

  @override
  State<Eventsscreen> createState() => _EventsscreenState();
}

class _EventsscreenState extends State<Eventsscreen> {
  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventCreationProvider>(context, listen: false);
      provider.fetchUserPostsFromPrefs(type: 'event');
      provider.fetchJoinedEventsFromPrefs();
    });
  }

  String _buildFullImageUrl(String relativePath) {
    return 'http://82.29.167.118:8000/$relativePath';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Events'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:
            IconButton(
              icon: Image.asset(
                'images/message_send.png',
                width: 25, // adjust size as needed
                height: 25,
               // color: Colors.white, // optional: if you want to tint the image
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatListPage()),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<EventCreationProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isFetchingEvents) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          }

          if (eventProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${eventProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final now = DateTime.now();

          final createdEvents = eventProvider.createdEvents.where((event) {
            final endTime = event.eventDetails?.endTime;
            return endTime == null || endTime.isAfter(now); // show only active
          }).toList();

          final joinedEvents = eventProvider.joinedEvents;

// ✅ Show message if both lists are empty
          if (createdEvents.isEmpty && joinedEvents.isEmpty) {
            return const Center(child: Text('No events found'));
          }

// ✅ Combine both lists
          final allEvents = [...createdEvents, ...joinedEvents];

// 🔹 Separate previous and upcoming events
          final previousEvents = <EventModel>[];
          final upcomingEvents = <EventModel>[];

          for (final event in allEvents) {
            final startTime = event.eventDetails?.startTime;
            if (startTime != null &&
                startTime.isBefore(DateTime(now.year, now.month, now.day))) {
              previousEvents.add(event);
            } else {
              upcomingEvents.add(event);
            }
          }

          return RefreshIndicator(
            color: Colors.pink,
              onRefresh: () async {
                final provider = Provider.of<EventCreationProvider>(context, listen: false);
                await provider.fetchUserPostsFromPrefs(type: 'event');
                await provider.fetchJoinedEventsFromPrefs();
              },
              child:
            ListView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              children: [

                /// 🎟️ Booked Events (Joined)
                Text("Booked Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                joinedEvents.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("You haven’t booked any events."),
                )
                    : Column(
                  children: joinedEvents.map((event) {
                    return _buildEventCard(event, screenWidth, screenHeight, isBooked: true);
                  }).toList(),
                ),

                const SizedBox(height: 30),

                /// ✍️ Created Events
                Text("My Created Events",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                createdEvents.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("You haven’t created any events."),
                )
                    : Column(
                  children: createdEvents.map((event) {
                    return _buildEventCard(event, screenWidth, screenHeight, isBooked: false);
                  }).toList(),
                ),
              ],
            )
          );
        },
      ),
    );
  }

  // 🔧 Reusable event card widget
  Widget _buildEventCard(EventModel event, double screenWidth, double screenHeight, {bool isBooked = false})
  {
    final details = event.eventDetails;
    final title = details?.title ?? event.title;
    final city = details?.city ?? "Unknown";
    final price = details?.isFree == true ? "Free" : "₹${details?.price.toStringAsFixed(0)}";
    final start = details?.startTime != null
        ? DateFormat('EEE, MMM d • hh:mm a').format(details!.startTime!)
        : "";

    return GestureDetector(
      onTap: () {
        try {
          final user = event.user;
          final convertedEvent = Event(
            title: event.title,
            id: event.id,
            content: event.content,
            createdAt: event.createdAt,
            endTime: event.eventDetails?.endTime ?? DateTime.now(),
            startTime: event.eventDetails?.startTime ?? DateTime.now(),
            image: event.media.isNotEmpty ? event.media.first : '',
            isFree: event.eventDetails?.isFree ?? true,
            likes: event.likes.map((e) => e.toString()).toList(),
            location: event.eventDetails?.city ?? "Unknown",
            price: event.eventDetails?.price ?? 0.0,
            type: event.type ?? "event",
            organizerId: user.id,
            organizer: user.name,              // ✅ organizer name
            organizerProfile: user.profile ?? '', // ✅ profile image URL
            comments: event.comments.map((e) => CommentModel.fromJson(e)).toList(),
            latitude: event.eventDetails?.latitude ?? 0.0,
            longitude: event.eventDetails?.longitude ?? 0.0,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: convertedEvent),
            ),
          );
        } catch (e, stackTrace) {
          debugPrint('❌ Error converting event: $e');
          debugPrint('📍 Stack trace: $stackTrace');
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.025),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey, width: 0.5),
          color: Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: event.media.isNotEmpty
                  ? Image.network(
                _buildFullImageUrl(event.media.first),
                width: screenWidth * 0.33,
                height: screenWidth * 0.38,
                fit: BoxFit.cover,
              )
                  : Container(
                width: screenWidth * 0.33,
                height: screenWidth * 0.38,
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenHeight * 0.007),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.pink),
                      SizedBox(width: screenWidth * 0.015),
                      Flexible(
                        child: Text(
                          start,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.006),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.orange),
                      SizedBox(width: screenWidth * 0.015),
                      Flexible(
                        child: Text(
                          city,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.008),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.006,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          price,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.pink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Spacer(),
                      if (isBooked)
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.03,
                              vertical: screenHeight * 0.006,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              'Booked',
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
