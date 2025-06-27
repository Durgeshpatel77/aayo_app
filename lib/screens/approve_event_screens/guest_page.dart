import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_registration_model.dart';
import '../../providers/approve_events_provider/event_registration_provider.dart';
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
        ],
    );
  }

  Widget _buildMinimalGuestCard(EventRegistration guest) {
    final provider = Provider.of<EventRegistrationProvider>(context, listen: false);

    Future<void> _updateStatus(String newStatus, String label, Color color) async {
      final success = await provider.updateStatus(
        eventId: guest.eventId,
        joinedBy: guest.id,
        registrationId: guest.registrationId,
        newStatus: newStatus,
      );

      if (success) {
        setState(() {
          guest.status = newStatus; // ✅ update the UI instantly
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '$label ${guest.name}'
              : 'Failed to $label ${guest.name}'),
          backgroundColor: success ? color : Colors.red,
        ),
      );
    }

    Widget _buildStatusChip(String label, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      );
    }

    Widget _buildTrailing() {
      switch (guest.status) {
        case 'approved':
          return _buildStatusChip('Approved', Colors.green);
        case 'declined':
          return _buildStatusChip('Rejected', Colors.red);
        case 'waiting':
          return _buildStatusChip('Waitlisted', Colors.blue);
        case 'pending':
        default:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _updateStatus('approved', 'Approved', Colors.green),
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                tooltip: 'Approve Guest',
              ),
              IconButton(
                onPressed: () => _updateStatus('declined', 'Rejected', Colors.red),
                icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                tooltip: 'Reject Guest',
              ),
            ],
          );
      }
    }

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
        trailing: _buildTrailing(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
