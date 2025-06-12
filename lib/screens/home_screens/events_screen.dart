import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/events_list_item.dart';
import '../../providers/setting_screens_providers/event_provider.dart';
import 'chat_list_page.dart';
import '../event_detail_screens/events_details.dart';

class Eventsscreen extends StatelessWidget {
  const Eventsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get MediaQueryData
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final createdEvents =
        Provider.of<EventCreationProvider>(context).createdEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Events'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: screenWidth * 0.025), // Responsive right padding
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ChatListPage()));
              },
              child: const Icon(Icons.message_outlined),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        // Use a Column to stack the FAB-like message and the event list
        children: [
          // The rest of your events list
          Expanded(
            // Make sure the ListView takes the remaining space
            child:
            createdEvents.isEmpty
                ? const Center(child: Text("No events found."))
                : ListView.builder(
                    itemCount: createdEvents.length,
                    itemBuilder: (context, index) {
                      final event = createdEvents[index];
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // Responsive horizontal margin for cards
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.01),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailScreen(eventName: event.name),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(
                                screenWidth * 0.03), // Responsive padding
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (event.image != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      event.image!,
                                      width:
                                          screenWidth * 0.2, // Responsive width
                                      height: screenWidth *
                                          0.2, // Responsive height
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(
                                    width:
                                        screenWidth * 0.2, // Responsive width
                                    height:
                                        screenWidth * 0.2, // Responsive height
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.event,
                                        size: screenWidth *
                                            0.1), // Responsive icon size
                                  ),
                                SizedBox(
                                    width:
                                        screenWidth * 0.03), // Responsive space
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name ?? "Untitled Event",
                                        style: TextStyle(
                                          fontSize: 18, // Scale font size
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenHeight *
                                              0.005), // Responsive space
                                      Text(
                                        "${event.ticketType} - ${event.ticketPrice ?? 'Free'}",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14, // Scale font size
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenHeight *
                                              0.01), // Responsive space
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 16,
                                              color: Colors
                                                  .redAccent), // Scale icon size
                                          SizedBox(
                                              width: screenWidth *
                                                  0.01), // Responsive space
                                          Expanded(
                                            child: Text(
                                              event.location ??
                                                  "No location found",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13, // Scale font size
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: screenHeight *
                                              0.005), // Responsive space
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              size: 16,
                                              color: Colors
                                                  .blueAccent), // Scale icon size
                                          Text(
                                            " Start Date:",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13, // Scale font size
                                            ),
                                          ),
                                          SizedBox(
                                              width: screenWidth *
                                                  0.01), // Responsive space
                                          Text(
                                            event.startDate != null
                                                ? DateFormat('MM/d/y')
                                                    .format(event.startDate!)
                                                : 'No start date',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13, // Scale font size
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
