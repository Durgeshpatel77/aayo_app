import 'package:aayo/screens/approve_event_screens/status_user_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _updateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventRegistrationProvider>(context, listen: false)
          .fetchRegistrations(widget.eventId);
    });
  }

  @override
  void dispose() {
    _updateController.dispose();
    super.dispose();
  }

  Widget _buildStatusCard(String title, IconData icon, Color color, List<EventRegistration> list) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatusUserListPage(title: title, users: list),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color.withOpacity(0.5), width: 0.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text('${list.length} users', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
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
          backgroundColor: Colors.white,
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.pink))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatusCard("Approved", Icons.check_circle, Colors.green, approved),
                    const SizedBox(width: 12),
                    _buildStatusCard("Pending", Icons.pending_actions, Colors.orange, pending),
                  ],
                ),
                Row(
                  children: [
                    _buildStatusCard("Declined", Icons.cancel, Colors.red, declined),
                    const SizedBox(width: 12),
                    _buildStatusCard("Waiting", Icons.access_time, Colors.deepPurple, waiting),
                  ],
                ),
                const SizedBox(height: 20),

                /// Input field and send button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.pink.withOpacity(0.5), width: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextField(
                        controller: _updateController,
                        maxLines: 3,
                        minLines: 1,
                        maxLength: 400, // Approx for 100 words
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Send update to approved users...",
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final msg = _updateController.text.trim();
                          final wordCount = msg.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

                          if (msg.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a message")),
                            );
                            return;
                          }

                          if (wordCount > 100) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("⚠️ Message should not exceed 100 words")),
                            );
                            return;
                          }

                          await Provider.of<NotificationProvider>(context, listen: false)
                              .sendEventNotification(
                            context: context,
                            message: msg,
                            users: approved,
                            eventTitle: widget.eventTitle,
                            eventImageUrl: widget.eventImageUrl,
                          );

                          _updateController.clear();
                        },
                        label: const Text("Send", style: TextStyle(color: Colors.pink)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade50,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.pink, width: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
