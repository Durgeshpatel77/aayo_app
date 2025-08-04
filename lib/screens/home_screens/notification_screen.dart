import 'dart:convert';
import 'package:aayo/screens/home_screens/post_detail_screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/event_model.dart';
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

        final userNotifications = allNotifications.where((notif) {
          if (notif.receiverId != currentUserId) return false;

          // Skip self-like or self-join
          final isSelfLike = notif.senderId == currentUserId && notif.type == "post_like";
          final isSelfJoin = notif.senderId == currentUserId && notif.type == "event_join";

          return !(isSelfLike || isSelfJoin);
        }).toList();

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

  String formatNotificationText(NotificationModel notif) {
    String name = notif.senderName.isNotEmpty ? notif.senderName : "Someone";

    // Handle likes
    if (notif.type == "post_like" || notif.type == "event_like") {
      String itemType = notif.type == "post_like" ? "post" : "event";
      return "❤️ $name liked your $itemType: ${notif.dataTitle ?? ''}";
    }

    // Backend sends "Some one liked you"
    if ((notif.type?.toLowerCase().contains("like") ?? false) &&
        (notif.type != "post_like" && notif.type != "event_like")) {
      // Guess based on title or data
      bool isEvent = notif.dataTitle?.toLowerCase().contains("event") ?? false;
      String itemType = isEvent ? "event" : "post";
      return "❤️ $name liked your $itemType: ${notif.dataTitle ?? ''}";
    }

    // Comments
    if (notif.type == "post_comment") {
      return "💬 $name commented on your post: ${notif.dataTitle ?? ''}";
    }

    // Post creation
    if (notif.type == "post_creation") {
      return "📝 $name created a new post: ${notif.dataTitle ?? ''}";
    }

    // Event creation
    if (notif.type == "event_creation") {
      return "📅 $name created a new event: ${notif.dataTitle ?? ''}";
    }

    // Broadcast
    if (notif.type == "broadcast") {
      return "📢 ${notif.message}";
    }

    // Default (with name replacement)
    String bodyText = notif.message;
    if (bodyText.toLowerCase().contains("some one")) {
      bodyText = bodyText.replaceAll("Some one", name);
      bodyText = bodyText.replaceAll("some one", name);
    }

    return bodyText;
  }
  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d";
    } else {
      // Show date if older than 7 days
      return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }
  }


  @override
  Widget build(BuildContext context) {
    final sortedKeys = groupedNotifications.keys.toList()
      ..sort((a, b) => b.compareTo(a));

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
                  return InkWell(
                    onTap: () async {
                      debugPrint("📩 Notification tapped: ${notif.type}, postId: ${notif.postId}");

                      if (notif.type == "post_like" || notif.type == "event_like" ||
                          notif.type == "post_creation" || notif.type == "event_creation") {
                        if (notif.postId != null && notif.postId!.isNotEmpty) {
                          try {
                            final response = await http.get(
                              Uri.parse("http://82.29.167.118:8000/api/events/${notif.postId}"),
                            );

                            debugPrint("📡 Fetching detail... Status: ${response.statusCode}");

                            if (response.statusCode == 200) {
                              final data = jsonDecode(response.body)['data'];
                              final event = Event.fromJson(data); // your model
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(post: event),
                                ),
                              );
                            } else {
                              debugPrint("❌ Failed to fetch details: ${response.statusCode}");
                            }
                          } catch (e) {
                            debugPrint("❌ Error opening detail: $e");
                          }
                        } else {
                          debugPrint("⚠ No postId found in notification.");
                        }
                      }
                    },
                    child:
                    NotificationItem(
                      profileImageUrl: notif.profileImage,
                      title: formatNotificationText(notif),
                      subtitle: formatTimeAgo(notif.createdAt),
                      trailingImageUrl: notif.dataImage, // ✅ show post/event image

                    ),
                  );
                }).toList()
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}