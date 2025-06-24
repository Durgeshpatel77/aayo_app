import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../event_detail_screens/registration_page.dart';
import 'guest_page.dart';
import 'overview_page.dart';
import '../../providers/home_screens_providers/home_provider.dart';

class ApproveScreen extends StatefulWidget {
  final String eventId;

  const ApproveScreen({super.key, required this.eventId});

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> with SingleTickerProviderStateMixin {
  late final String eventId;
  Event? selectedEvent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    eventId = widget.eventId;
    _loadEventDetails();
  }

  Future<void> _loadEventDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    if (homeProvider.allEvents.isEmpty) {
      await homeProvider.fetchAll();
    }

    final event = homeProvider.allEvents.firstWhere(
          (e) => e.id == eventId && e.isEvent,
      orElse: () => Event(
        id: '',
        title: 'N/A',
        content: '',
        location: '',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        isFree: true,
        organizerId: '',
        price: 0.0,
        likes: [],
        image: '',
        media: [],
        organizer: '',
        organizerProfile: '',
        createdAt: DateTime.now(),
        type: 'event',
        comments: [],
      ),
    );

    if (event.id.isNotEmpty) {
      setState(() {
        selectedEvent = event;
        isLoading = false;
      });
    } else {
      debugPrint('❌ Event not found for ID: $eventId');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approve Event'),
          bottom: const TabBar(
            labelStyle: TextStyle(color: Colors.pink),
            unselectedLabelStyle: TextStyle(color: Colors.black),
            indicatorColor: Colors.pink,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Guest'),
              Tab(text: 'Registration'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : selectedEvent == null
            ? const Center(
          child: Text(
            "❌ Event not found",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        )
            : TabBarView(
          children: [
            OverviewTab(event: selectedEvent!), // ✅ pass loaded Event
            GuestPage(eventId: selectedEvent!.id), // still pass ID
            const RegistrationPage(),
          ],
        ),
      ),
    );
  }
}
