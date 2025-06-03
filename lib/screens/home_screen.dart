  import 'dart:io';
  import 'package:aayo/screens/addEventsScreen.dart';
  import 'package:aayo/screens/user_profile_list.dart';
  import 'package:flutter/material.dart';
  import 'package:aayo/models/event_model.dart';
  import 'package:aayo/screens/NotificationScreen.dart';
  import 'package:aayo/screens/UserProfileList.dart'; // Assuming UserProfile is here
  import 'package:aayo/screens/eventsScreen.dart';
  import 'package:aayo/screens/events_details.dart';
  import 'package:image_picker/image_picker.dart';
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
    int _selectedIndex = 0;

    // List to hold events posted by the user
    final List<Event> _userPostedEvents = [];

    // Initial random events
    final List<Event> _randomEvents = [
      Event(
          id: '1',
          name: "Startup Meetup: Innovate & Connect",
          imageUrl:
              'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          caption: 'A great networking event for startups.',
          location: 'Ahmedabad',
          category: 'Tech',
          organizer: 'Innovate Hub',
          price: 25.00,
          date: DateTime(2025, 6, 15),
          time: const TimeOfDay(hour: 10, minute: 0),
          eventDateTime: DateTime(2025, 6, 15, 10, 0)),
      Event(
          id: '2',
          name: "Groovy Music Fest 2024: Summer Beats",
          imageUrl:
              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          caption: 'Experience the best summer beats!',
          location: 'Goa',
          category: 'Music',
          organizer: 'Beat Masters',
          price: 150.00,
          date: DateTime(2025, 7, 20),
          time: const TimeOfDay(hour: 18, minute: 0),
          eventDateTime: DateTime(2025, 7, 20, 18, 0)),
      Event(
          id: '3',
          name: "Future of AI: A Deep Dive Tech Talk",
          imageUrl:
              'https://images.unsplash.com/photo-1556125574-d7f27ec36a06?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          caption: 'Explore the latest in Artificial Intelligence.',
          location: 'Bangalore',
          category: 'Tech',
          organizer: 'AI Minds',
          price: 50.00,
          date: DateTime(2025, 8, 10),
          time: const TimeOfDay(hour: 14, minute: 0),
          eventDateTime: DateTime(2025, 8, 10, 14, 0)),
      Event(
          id: '4',
          name: "Abstract Art Exhibition: Colors & Forms",
          imageUrl:
              'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          caption: 'A vibrant display of contemporary art.',
          location: 'Mumbai',
          category: 'Art',
          organizer: 'Art Gallery',
          price: 10.00,
          date: DateTime(2025, 9, 1),
          time: const TimeOfDay(hour: 11, minute: 0),
          eventDateTime: DateTime(2025, 9, 1, 11, 0)),
    ];

    late List<Widget> _screens;

    @override
    void initState() {
      super.initState();
      _updateScreens(); // Initialize _screens here
    }

    // Helper method to re-initialize _screens when _userPostedEvents changes
    void _updateScreens() {
      _screens = [
        HomeTabContent(
          // Combine user-posted events (at top) with random events
          allEvents: [..._userPostedEvents, ..._randomEvents],
          onEventTapped: _onEventTapped,
        ),
        const Eventsscreen(),
        Addeventsscreen(), // Pass the callback
        const Notificationscreen(),
        const UserProfileList(),
      ];
    }

    // Callback function to receive posted event from AddEventsImages
    void _addPostedEvent(Event newEvent) {
      setState(() {
        _userPostedEvents.insert(0, newEvent); // Add to the beginning of the list
        _updateScreens(); // Re-initialize _screens to reflect the new list
        _selectedIndex = 0; // Navigate back to the home tab
      });
    }

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    void _onEventTapped(String eventName) {
      // In a real app, you'd pass the event ID or the full Event object
      // to EventDetailScreen to fetch/display correct details.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetailScreen(eventName: eventName),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline), label: "Add"),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "Notification"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
    }
  }
