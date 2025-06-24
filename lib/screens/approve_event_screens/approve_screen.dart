import 'package:flutter/material.dart';

import '../event_detail_screens/registration_page.dart';
import 'guest_page.dart';
import 'overview_page.dart';

class ApproveScreen extends StatefulWidget {
  final String eventId;

  const ApproveScreen({super.key, required this.eventId});

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen>
    with SingleTickerProviderStateMixin {
  late final String eventId;

  @override
  void initState() {
    super.initState();
    eventId = widget.eventId;
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
        body: Builder(
          builder: (context) {
            if (eventId.isEmpty) {
              return const Center(
                child: Text(
                  "❌ No event ID found",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            return TabBarView(
              children: [
                const OverviewTab(),
                GuestPage(eventId: eventId), // ✅ Pass eventId dynamically
                const RegistrationPage(),
              ],
            );
          },
        ),
      ),
    );
  }
}
