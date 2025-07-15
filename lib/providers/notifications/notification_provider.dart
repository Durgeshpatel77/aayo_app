import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/event_registration_model.dart';
import '../approve_events_provider/event_registration_provider.dart';

class NotificationProvider with ChangeNotifier {
  bool isSending = false;

  Future<void> sendEventNotification({
    required BuildContext context,
    required String message,
    required List<EventRegistration> users,
    required String eventTitle,
    required String? eventImageUrl, // This can be null
  }) async {
    isSending = true;
    notifyListeners();

    const url = 'http://82.29.167.118:8000/api/notification';
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getString('backendUserId');

    if (senderId == null || senderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Sender ID not found")),
      );
      isSending = false;
      notifyListeners();
      return;
    }

    final approvedUsers = users.where((u) => u.status == 'approved').toList();
    if (approvedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No approved users to notify.")),
      );
      isSending = false;
      notifyListeners();
      return;
    }

    for (final user in approvedUsers) {
      final payload = {
        "sender": senderId,
        "receiver": user.id,
        "title": eventTitle,
        "body": message,
        "data": {
          "eventTitle": eventTitle,
          "image": eventImageUrl ?? "", // Empty string if null
        }
      };

      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );
        debugPrint("📨 Sent to ${user.name}: ${res.statusCode}");
      } catch (e) {
        debugPrint("❌ Error sending to ${user.name}: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to send to ${user.name}")),
        );
      }
    }

    isSending = false;
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Notifications sent to approved users")),
    );
  }

}
