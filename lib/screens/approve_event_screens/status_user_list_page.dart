import 'package:flutter/material.dart';
import '../../models/event_registration_model.dart';

class StatusUserListPage extends StatelessWidget {
  final String title;
  final List<EventRegistration> users;

  const StatusUserListPage({super.key, required this.title, required this.users});

  Color _getColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$title Users")),
      body: users.isEmpty
          ? const Center(child: Text("No users in this status."))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final reg = users[index];
          final color = _getColor(reg.status);
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.pink.shade100,
                child: const Icon(Icons.person, color: Colors.pink),
              ),
              title: Text(reg.name),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  reg.status.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
