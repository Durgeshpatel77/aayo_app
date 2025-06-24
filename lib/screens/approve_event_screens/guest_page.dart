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
      _initializeGuestAndHostData();
    });
  }

  Future<void> _initializeGuestAndHostData() async {
    final provider = Provider.of<GuestProvider>(context, listen: false);
    await provider.addCurrentUserAsHost(existingEventId: widget.eventId);
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
        onRefresh: () async {
          await _initializeGuestAndHostData();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildSectionHeader("Recent Registrations", () async {
                      await provider.fetchEventRegistrations(widget.eventId);
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
                    _buildSectionHeader("Hosts", () async {
                      await provider.addCurrentUserAsHost(existingEventId: widget.eventId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Host added successfully')),
                      );
                      await provider.fetchHostNames(eventId: widget.eventId);
                    }, buttonText: "Add Host", showAddButton: true, isLoading: provider.isLoading),
                    const SizedBox(height: 10),
                    hosts.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "❗ No hosts found. Please add a host.",
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

  Widget _buildSectionHeader(String title, VoidCallback onPressed,
      {String? buttonText, bool showAddButton = false, bool isLoading = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (showAddButton)
          ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.person_add, color: Colors.white),
            label: Text(buttonText ?? "", style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        else
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
                // Implement approve logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Approved ${guest.name}')),
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              tooltip: 'Approve Guest',
            ),
            IconButton(
              onPressed: () {
                // Implement reject logic
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: host['profile'] != null && host['profile']!.isNotEmpty
            ? CircleAvatar(
          backgroundImage: NetworkImage(
              'http://srv861272.hstgr.cloud:8000/${host['profile']}'),
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image loading errors
            debugPrint('Error loading host profile image: $exception');
          },
        )
            : CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.star, color: Colors.blue),
        ),
        title: Text(
          host['name'] ?? 'Unknown Host',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          host['email'] ?? 'No email',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}