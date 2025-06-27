import 'package:aayo/screens/approve_event_screens/status_user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_registration_model.dart';
import '../../providers/approve_events_provider/event_registration_provider.dart';

class RegistrationPage extends StatefulWidget {
  final String eventId;

  const RegistrationPage({super.key, required this.eventId});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventRegistrationProvider>(context, listen: false)
          .fetchRegistrations(widget.eventId);
    });
  }

  void _showStatusDialog(String title, List<EventRegistration> users) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$title Users'),
        content: SizedBox(
          width: double.maxFinite,
          child: users.isEmpty
              ? const Text('No users in this status.')
              : ListView.separated(
            shrinkWrap: true,
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, index) {
              final reg = users[index];
              return ListTile(
                title: Text(reg.name),
                subtitle: Text("Status: ${reg.status}"),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  _showDetailsSheet(reg); // Open sheet like before
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _showDetailsSheet(EventRegistration reg) {
    Color getColor(String status) {
      switch (status) {
        case 'approved':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'declined':
          return Colors.red;
        case 'waiting':
          return Colors.deepPurple;
        default:
          return Colors.grey;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 Name: ${reg.name}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("📋 Status: ", style: TextStyle(fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getColor(reg.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: getColor(reg.status)),
                  ),
                  child: Text(
                    reg.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getColor(reg.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("🆔 Reg ID: ${reg.registrationId}",
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 5),
            Text("📅 Event ID: ${reg.eventId}",
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
      String label, Color color, String status, EventRegistration reg) {
    return ElevatedButton(
      onPressed: () async {
        final success = await Provider.of<EventRegistrationProvider>(
          context,
          listen: false,
        ).updateStatus(
          eventId: reg.eventId,
          joinedBy: reg.id,
          registrationId: reg.registrationId,
          newStatus: status,
        );
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Status changed to $label")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to change status")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }

  Widget _buildStatusCard(
      String title,
      IconData icon,
      Color color,
      List<EventRegistration> list,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusUserListPage(title: title, users: list),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text('${list.length}',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventRegistrationProvider>(
      builder: (context, provider, _) {
        final list = provider.registrations;
        final approved = list.where((e) => e.status == 'approved').toList();
        final pending = list.where((e) => e.status == 'pending').toList();
        final declined = list.where((e) => e.status == 'declined').toList();
        final waiting = list.where((e) => e.status == 'waiting').toList();

        return Scaffold(
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.pink))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Registration status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_open, color: Colors.green),
                      SizedBox(width: 10),
                      Text("Registration is OPEN",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status Cards
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                              "Approved", Icons.check, Colors.green, approved),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard("Pending",
                              Icons.hourglass_bottom, Colors.orange, pending),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                              "Declined", Icons.cancel, Colors.red, declined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusCard("Waiting",
                              Icons.access_time, Colors.deepPurple, waiting),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
