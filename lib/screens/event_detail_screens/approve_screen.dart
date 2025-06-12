// lib/screens/ApproveScreen.dart

import 'dart:math';

import 'package:aayo/screens/event_detail_screens/registration_page.dart';
import 'package:flutter/material.dart';
// No need to import Create_Event_model.dart if you're not using a model
import 'guest_page.dart';
import 'overview_page.dart'; // This is where OverviewTab will be defined

class ApproveScreen extends StatefulWidget {
  const ApproveScreen({super.key}); // Remove 'event' if not passing a model

  @override
  State<ApproveScreen> createState() => _ApproveScreenState();
}

class _ApproveScreenState extends State<ApproveScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
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
        body: const TabBarView(
          // Make this const if children are const
          children: [
            // Directly use OverviewTab without passing event data
            OverviewTab(),
            GuestPage(),
            RegistrationPage(),
          ],
        ),
      ),
    );
  }
}
