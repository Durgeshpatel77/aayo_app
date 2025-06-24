import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/approve_events_provider/guest_page_provider.dart';

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  final List<Map<String, String>> recentGuests = const [
    {'name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'name': 'Catherine Lee', 'email': 'catherine@example.com'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuestProvider>(context);
    final hosts = provider.hosts;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Registrations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add guest logic
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text("Add Guest", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var guest in recentGuests) _buildGuestCard(guest),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Hosts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    await provider.createEventAndAddHost();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event created and host added')),
                    );
                  },
                  icon: const Icon(Icons.event_available, color: Colors.white),
                  label: provider.isLoading
                      ? const Text("Creating...", style: TextStyle(color: Colors.white))
                      : const Text("Create Event", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var host in hosts) _buildHostCard(host),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(Map<String, String> guest) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.pink),
        title: Text(guest['name'] ?? ''),
        subtitle: Text(guest['email'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.check, color: Colors.green),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(Map<String, String> host) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.blue),
        title: Text(host['name'] ?? ''),
        subtitle: Text(host['email'] ?? ''),
      ),
    );
  }
}
