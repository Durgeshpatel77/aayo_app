import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_registration_model.dart';
import '../../providers/approve_events_provider/guest_page_provider.dart';

class GuestPage extends StatefulWidget {
  final String eventId;
  const GuestPage({super.key, required this.eventId});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<GuestProvider>(context, listen: false);
    await provider.fetchHostNames(eventId: widget.eventId);
    await provider.fetchEventRegistrations(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GuestProvider>(context);
    final hosts = provider.hosts;
    final registrations = provider.registrations;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildSectionHeader("Recent Registrations", () {
                      provider.fetchEventRegistrations(widget.eventId);
                    }),
                    const SizedBox(height: 10),
                    registrations.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No recent guests.",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ),
                    )
                        : Column(children: registrations.map(_buildMinimalGuestCard).toList()),
                    const SizedBox(height: 30),
                    _buildSectionHeader("Hosts", () {
                      provider.fetchHostNames(eventId: widget.eventId);
                    }),
                    const SizedBox(height: 10),
                    hosts.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "❗ No hosts found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ),
                    )
                        : Column(children: hosts.map(_buildHostCard).toList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onPressed) {
    final bool showRefresh = title != "Hosts"; // 👈 Disable refresh button for "Hosts"

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (showRefresh)
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Refresh", style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.pink,
              side: const BorderSide(color: Colors.pink),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
      ],
    );
  }

  Widget _buildMinimalGuestCard(EventRegistration guest) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: const Icon(Icons.person, color: Colors.pink),
        ),
        title: Text(
          guest.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Approved ${guest.name}')),
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              tooltip: 'Approve Guest',
            ),
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rejected ${guest.name}')),
                );
              },
              icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
              tooltip: 'Reject Guest',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostCard(Map<String, String> host) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          host['profile'] != null && host['profile']!.isNotEmpty
              ? CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
                'http://srv861272.hstgr.cloud:8000/${host['profile']}'),
          )
              : CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(Icons.star, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host['name'] ?? 'Unknown Host',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  host['email'] ?? 'No email',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
