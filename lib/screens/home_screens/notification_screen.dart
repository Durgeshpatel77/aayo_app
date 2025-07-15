import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification_model.dart';
import 'notification_item.dart';

class Notificationscreen extends StatefulWidget {
  const Notificationscreen({super.key});

  @override
  State<Notificationscreen> createState() => _NotificationscreenState();
}

class _NotificationscreenState extends State<Notificationscreen> {
  Map<String, List<NotificationModel>> groupedNotifications = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('backendUserId');

      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint("❌ No logged-in user ID found.");
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://82.29.167.118:8000/api/notification'),
      );

      debugPrint("🔎 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> notificationsJson = decoded['data'] ?? [];

        final List<NotificationModel> allNotifications = notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // ✅ Filter only notifications for this user
        final userNotifications = allNotifications
            .where((notif) => notif.receiverId == currentUserId)
            .toList();

        debugPrint("✅ Filtered for user $currentUserId: ${userNotifications.length} notifications");

        // Group by date
        final Map<String, List<NotificationModel>> grouped = {};
        for (var notif in userNotifications) {
          final dateKey = "${notif.createdAt.year}-${notif.createdAt.month.toString().padLeft(2, '0')}-${notif.createdAt.day.toString().padLeft(2, '0')}";
          grouped.putIfAbsent(dateKey, () => []).add(notif);
        }

        setState(() {
          groupedNotifications = grouped;
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed: ${response.statusCode}");
        debugPrint("❌ Body: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  String formatDate(String dateKey) {
    final parts = dateKey.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = groupedNotifications.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedNotifications.isEmpty
          ? const Center(child: Text("No notifications found."))
          : SingleChildScrollView(
        child: Column(
          children: sortedKeys.map((dateKey) {
            final formattedDate = formatDate(dateKey);
            final items = groupedNotifications[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, top: 16.0, bottom: 8.0),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                ...items.map((notif) {
                  return NotificationItem(
                    profileImageUrl: notif.profileImage, // Pass only the image path
                    title: notif.message,
                    subtitle:
                    "${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}",
                  );
                })
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
