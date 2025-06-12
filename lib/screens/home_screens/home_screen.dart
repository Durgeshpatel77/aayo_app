  import 'dart:io';
  import 'package:aayo/screens/home_screens/add_events_screen.dart';
  import 'package:aayo/screens/user_profile_list.dart';
  import 'package:flutter/material.dart';
  import 'package:aayo/models/event_model.dart';
  import 'package:aayo/screens/home_screens/notification_screen.dart';
  import 'package:aayo/screens/home_screens/userprofile_list.dart'; // Assuming UserProfile is here
  import 'package:aayo/screens/home_screens/events_screen.dart';
  import 'package:aayo/screens/event_detail_screens/events_details.dart';
  import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/home_screens_providers/home_provider.dart';

  // Import your AddEventsImages

  // EventCard widget streamlined to show only the image and event name
  class EventCard extends StatelessWidget {
    final Event event;


    const EventCard({required this.event, super.key});

    @override
    Widget build(BuildContext context) {
      ImageProvider _imageProvider;
      if (event.image != null) {
        _imageProvider = FileImage(event.image!);
      } else if (event.imageUrl.isNotEmpty && event.imageUrl.startsWith('http')) {
        // If a network image URL is provided
        _imageProvider = NetworkImage(event.imageUrl);
      } else {
        // Fallback: A placeholder image or asset if neither is available
        _imageProvider = const AssetImage(
            'assets/placeholder.png'); // Ensure you have this asset
      }

      return Container(
        height: 250, // Height adjusted for a clean look
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: _imageProvider, // Use the determined imageProvider
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
          ),
        ),
        child: Stack(
          children: [
            // Optional: A subtle gradient overlay if you need more contrast
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black
                        .withOpacity(0.7), // Stronger opacity at the bottom
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4], // Control gradient spread
                ),
              ),
            ),

            // Event Name (Main title text, positioned at the bottom)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20, // Positioned near the bottom of the card
              child: Text(
                event.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22, // Prominent font size
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2, // Allow event name to wrap if long
                overflow: TextOverflow.ellipsis, // Add ellipsis if it's too long
              ),
            ),
          ],
        ),
      );
    }
  }

  // HomeTabContent: NO LONGER takes userPostedEvents as a separate list for UserProfiles
  class HomeTabContent extends StatefulWidget {
    final List<Event> allEvents; // Combined list of random and user-posted events
    final Function(String) onEventTapped;

    const HomeTabContent({
      required this.allEvents,
      required this.onEventTapped,
      super.key,
    });

    @override
    State<HomeTabContent> createState() => _HomeTabContentState();
  }

  class _HomeTabContentState extends State<HomeTabContent> {
    @override
    Widget build(BuildContext context) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.pink),
                const SizedBox(width: 8),
                const Text(
                  "Ahmedabad, Gujarat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => const Notificationscreen()),
                    );
                  },
                  icon: const Icon(Icons.notifications_none),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Search Field
            TextField(
              decoration: InputDecoration(
                hintText: "Search Events",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            const SizedBox(height: 24),

            // User Profiles (Original static profiles - ONLY these will show)
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                "People You Might Know", // Or adjust title
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [],
            ),

            const SizedBox(height: 20),

            // Event Cards (This is where YOUR added events will appear at the top, along with random ones)
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                "All Events", // Or "Upcoming Events"
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: widget.allEvents.map((event) {
                return GestureDetector(
                  onTap: () => widget
                      .onEventTapped(event.name), // Navigate to event details
                  child: EventCard(event: event),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
          ],
        ),
      );
    }
  }

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    DateTime? _lastBackPressTime;

    void _onEventTapped(BuildContext context, String eventName) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(eventName: eventName),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Consumer<homeProvider>(
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
