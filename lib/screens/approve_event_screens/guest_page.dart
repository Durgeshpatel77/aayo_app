import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/approve_events_provider/guest_page_provider.dart';

class GuestPage extends StatefulWidget {
  final String eventId;
  const GuestPage({super.key, required this.eventId});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  final List<Map<String, String>> recentGuests = const [
    {'name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'name': 'Catherine Lee', 'email': 'catherine@example.com'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHostData();
    });
  }

  Future<void> _initializeHostData() async {
    final provider = Provider.of<GuestProvider>(context, listen: false);
    await provider.addCurrentUserAsHost(existingEventId: widget.eventId);
    await provider.fetchHostNames(eventId: widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuestProvider>(context);
    final hosts = provider.hosts;

    return Scaffold(
      appBar: AppBar(title: const Text("Guests & Hosts")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeader("Recent Registrations", () {}),
            const SizedBox(height: 10),
            for (var guest in recentGuests) _buildGuestCard(guest),
            const SizedBox(height: 30),
            _buildHeader("Hosts", () async {
              await provider.addCurrentUserAsHost(existingEventId: widget.eventId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Host added to event')),
              );
              await provider.fetchHostNames(eventId: widget.eventId);
            }, isLoading: provider.isLoading),
            const SizedBox(height: 10),
            if (hosts.isEmpty)
              const Center(
                child: Text(
                  "❗ No hosts found. Please add a host.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            else
              ...hosts.map(_buildHostCard).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, VoidCallback onPressed, {bool isLoading = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: Text(
            isLoading ? "Loading..." : title == "Hosts" ? "Add Host" : "Add Guest",
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
        ),
      ],
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
            IconButton(onPressed: () {}, icon: const Icon(Icons.check, color: Colors.green)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.close, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(Map<String, String> host) {
    return Card(
      child: ListTile(
        leading: host['profile'] != null && host['profile']!.isNotEmpty
            ? CircleAvatar(
          backgroundImage: NetworkImage(
            'http://srv861272.hstgr.cloud:8000/${host['profile']}',
          ),
        )
            : const Icon(Icons.star, color: Colors.blue),
        title: Text(host['name'] ?? ''),
        subtitle: Text(host['email'] ?? ''),
      ),
    );
  }
}
