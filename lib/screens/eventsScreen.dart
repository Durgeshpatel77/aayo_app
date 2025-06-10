import 'package:aayo/models/events_list_item.dart';
import 'package:flutter/material.dart';

import 'ChatListPage.dart';

class Eventsscreen extends StatelessWidget {
  const Eventsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Events"), // A more descriptive title
        centerTitle: true, // Title is left-aligned in screenshot
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChatListPage();
                },));
                },
              child: Icon(Icons.sms),
            ),
          ),
        ],
      ),
      body: ListView(
        children: const [
          EventListItem(
            text: "See Your Events that registered With QR Code Ticket",
          ),
          EventListItem(
            text: "See Your Events that registered With QR Code Ticket",
          ),
          EventListItem(
            text: "See Your Events that registered With QR Code Ticket",
          ),
          EventListItem(
            text: "See Your Events that registered With QR Code Ticket",
          ),
          EventListItem(
            text: "See your Events that registered",
          ),
          // Add more EventListItem widgets as needed
        ],
      ),
    );
  }
}
