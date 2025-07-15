import 'package:aayo/screens/approve_event_screens/status_user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/event_registration_model.dart';
import '../../providers/approve_events_provider/event_registration_provider.dart';
import '../../providers/notifications/notification_provider.dart';

class RegistrationPage extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String? eventImageUrl;

  const RegistrationPage({
    super.key,
    required this.eventId,
    required this.eventTitle,
    this.eventImageUrl,
  });

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

  void _showNotificationDialog(List<EventRegistration> users) {
    final TextEditingController _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Send Notification"),
        content: TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Enter your message",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = _messageController.text.trim();
              if (message.isNotEmpty) {
                Navigator.pop(context);

                await Provider.of<NotificationProvider>(context, listen: false)
                    .sendEventNotification(
                  context: context,
                  message: message,
                  users: users,
                  eventTitle: widget.eventTitle,
                  eventImageUrl: widget.eventImageUrl,
                );
              }
            },
            child: const Text("Send"),
          ),
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

  Widget _buildStatusCard(String title, IconData icon, Color color, List<EventRegistration> list) {
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
                Text('${list.length}', style: const TextStyle(fontSize: 13)),
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
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard("Approved", Icons.check, Colors.green, approved),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusCard("Pending", Icons.hourglass_bottom, Colors.orange, pending),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard("Declined", Icons.cancel, Colors.red, declined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusCard("Waiting", Icons.access_time, Colors.deepPurple, waiting),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Send Notification"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showNotificationDialog(approved),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
