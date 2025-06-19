import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/create_event_model.dart';
import '../../models/event_model.dart';
import '../../providers/setting_screens_providers/event_provider.dart';
import 'chat_list_page.dart';
import '../event_detail_screens/events_details.dart';

class Eventsscreen extends StatefulWidget {
  // Remove the 'event' parameter from here
  // final EventModel event; // or your model class

  const Eventsscreen({super.key}); // Changed to a const constructor

  @override
  State<Eventsscreen> createState() => _EventsscreenState();
}

class _EventsscreenState extends State<Eventsscreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventCreationProvider>(context, listen: false)
          .fetchUserPostsFromPrefs(type: 'event');
    });
  }

  String _buildFullImageUrl(String relativePath) {
    return 'http://srv861272.hstgr.cloud:8000/$relativePath';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Events'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.message_outlined, color: Colors.grey[800]),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ChatListPage()));
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<EventCreationProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isFetchingEvents) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          } else if (eventProvider.errorMessage != null) {
            return Center(
              child: Text(
                'Error: ${eventProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final events = eventProvider.allEvents;
            if (events.isEmpty) {
              return const Center(
                child: Text("No events found.",
                    style: TextStyle(fontSize: 16)),
              );
            }

            return RefreshIndicator(
              color: Colors.pink,
              onRefresh: () async {
                await Provider.of<EventCreationProvider>(context, listen: false)
                    .fetchUserPostsFromPrefs(type: 'event');
              },
              child: ListView.builder(
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final details = event.eventDetails;
                  final title = details?.title ?? event.title;
                  final city = details?.city ?? "Unknown";
                  final price = details?.isFree == true
                      ? "Free"
                      : "₹${details?.price.toStringAsFixed(0)}";
                  final start = details?.startTime != null
                      ? DateFormat('EEE, MMM d • hh:mm a')
                      .format(details!.startTime!)
                      : "";

                  return GestureDetector(
                    onTap: () {
                      final convertedEvent = Event(
                        title: event.title,
                        id: event.id,
                        content: event.content,
                        createdAt: event.createdAt,
                        endTime: event.eventDetails?.endTime ?? DateTime.now(),
                        startTime: event.eventDetails?.startTime ?? DateTime.now(),
                        image: event.media.isNotEmpty ? event.media.first : '',
                        isFree: event.eventDetails?.isFree ?? true,
                        likes: event.likes.map((e) => e is String ? e : e['_id'].toString()).toList(),
                        location: event.eventDetails?.city ?? "Unknown",
                        price: event.eventDetails?.price ?? 0.0,
                        type: event.type ?? "event",
                        organizerId: (event.user as UserInfo).id, // Accessing from the nested UserInfo object
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: convertedEvent),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.025),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey,width: 0.5),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16)),
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
                              child: const Icon(Icons.broken_image,
                                  size: 80, color: Colors.grey),
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
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Colors.pink),
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
                                    const Icon(Icons.location_on,
                                        size: 18, color: Colors.orange),
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
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}