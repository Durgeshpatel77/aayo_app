import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/notification_model.dart';

// Notification model

// UI widget for individual item
class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackgroundColor;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = Colors.white,
    this.iconBackgroundColor = Colors.pinkAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: iconBackgroundColor,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Main screen
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
    final response = await http
        .get(Uri.parse('http://srv861272.hstgr.cloud:8000/api/notification'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> notificationsJson = data['data'];

      final List<NotificationModel> allNotifications = notificationsJson
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      final Map<String, List<NotificationModel>> grouped = {};

      for (var notif in allNotifications) {
        final dateKey =
            "${notif.createdAt.year}-${notif.createdAt.month.toString().padLeft(2, '0')}-${notif.createdAt.day.toString().padLeft(2, '0')}";
        grouped.putIfAbsent(dateKey, () => []).add(notif);
      }

      setState(() {
        groupedNotifications = grouped;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load notifications');
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
      ..sort((a, b) => b.compareTo(a)); // Descending order

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
                ...items.map((notif) => NotificationItem(
                  icon: Icons.notifications,
                  title: notif.message,
                  subtitle:
                  "${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}",
                  iconBackgroundColor: Colors.pinkAccent,
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
