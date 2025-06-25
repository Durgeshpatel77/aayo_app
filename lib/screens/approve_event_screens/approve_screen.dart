import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../event_detail_screens/registration_page.dart';
import 'guest_page.dart';
import 'overview_page.dart';
import '../../providers/home_screens_providers/home_provider.dart';

class ApproveScreen extends StatefulWidget {
  final String eventId;

  ApproveScreen({super.key, required this.eventId}) {
    debugPrint("✅ ApproveScreen opened with eventId: '$eventId'");
  }

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen> with SingleTickerProviderStateMixin {
  Event? selectedEvent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEventDetails(); // ✅ Safe now
    });
  }

  Future<void> _loadEventDetails() async {
    final id = widget.eventId.trim();

    if (id.isEmpty) {
      debugPrint("❌ ApproveScreen received an EMPTY eventId. Aborting.");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid event ID ❗")),
      );
      return;
    }

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);

    debugPrint("🔍 Fetching all events...");
    await homeProvider.fetchAll();

    debugPrint("🔍 Searching for event ID: '$id'");
    for (final e in homeProvider.allEvents) {
      debugPrint("➡️ Event in list: ${e.id} - ${e.title}");
    }

    Event? event = homeProvider.allEvents.firstWhere(
          (e) => e.id == id,
      orElse: () => Event(
        id: '',
        title: '',
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

    // ✅ Fallback: fetch from API directly if not found
    if (event.id.isEmpty) {
      debugPrint("🔁 Trying fallback fetch by ID...");
      event = await homeProvider.fetchEventById(id);
    }

    if (event != null && event.id.isNotEmpty && event.type == 'event') {
      setState(() {
        selectedEvent = event;
        isLoading = false;
      });
    } else {
      debugPrint("❌ Still no matching event found by ID: $id");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event not found ❗")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pink,)),
      );
    }

    if (selectedEvent == null || selectedEvent!.id.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("❌ Event not found", style: TextStyle(fontSize: 16, color: Colors.red)),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
        body: TabBarView(
          children: [
            OverviewTab(event: selectedEvent!),
            GuestPage(eventId: selectedEvent!.id),
            const RegistrationPage(),
          ],
        ),
      ),
    );
  }
}
