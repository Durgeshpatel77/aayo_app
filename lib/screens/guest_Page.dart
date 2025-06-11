import 'dart:math';

import 'package:flutter/material.dart';

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  // List of recent guests
  final List<Map<String, String>> recentGuests = const [
    {'name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'name': 'Catherine Lee', 'email': 'catherine@example.com'},
  ];

  // List of hosts
  final List<Map<String, String>> hosts = const [
    {'name': 'Daniel Roy', 'email': 'daniel@eventhost.com'},
    {'name': 'Emily Rose', 'email': 'emily@eventhost.com'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body content
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // --- Recent Registrations Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Registrations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add Guest logic
                  },
                  icon: const Icon(Icons.person_add,color: Colors.white,),
                  label: const Text("Add Guest",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),

                ),
              ],
            ),
            const SizedBox(height: 10),
            // Show guest cards
            for (var guest in recentGuests) _buildGuestCard(guest),

            const SizedBox(height: 30),

            // --- Hosts Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Hosts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add Host logic
                  },
                  icon: const Icon(Icons.add,color: Colors.white,),
                  label: const Text("Add Host",style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),

                ),
              ],
            ),
            const SizedBox(height: 10),
            // Show host cards
            for (var host in hosts) _buildHostCard(host),
          ],
        ),
      ),
    );
  }

  // Widget for guest cards
  Widget _buildGuestCard(Map<String, String> guest) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person,color: Colors.pink,),
        title: Text(guest['name'] ?? ''),
        subtitle: Text(guest['email'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                // Approve guest
              },
              icon: const Icon(Icons.check, color: Colors.green),
            ),
            IconButton(
              onPressed: () {
                // Deny guest
              },
              icon: const Icon(Icons.close, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for host cards
  Widget _buildHostCard(Map<String, String> host) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.star,color: Colors.blue,),
        title: Text(host['name'] ?? ''),
        subtitle: Text(host['email'] ?? ''),
      ),
    );
  }
}
