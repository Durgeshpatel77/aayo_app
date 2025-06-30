import 'dart:convert';

import 'package:aayo/screens/home_screens/single_user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../models/comment_model.dart';
import '../../models/event_model.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../other_for_use/utils.dart';

class CommentSheet extends StatefulWidget {
  final List<CommentModel> initialComments;
  final String postId;
  final String postOwnerId;
  final void Function(int newCount) onCommentCountChange;
  final Event event; // ✅ ADD THIS
  final String? recipientFcmToken; // <-- ADD this

  const CommentSheet({
    required this.initialComments,
    required this.postId,
    required this.postOwnerId,
    required this.onCommentCountChange,
    required this.event,
    this.recipientFcmToken, // <-- ADD this

    super.key,

  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first

  }
  // Future<void> _submit() async {
  //   final text = _controller.text.trim();
  //   if (text.isEmpty) {
  //     debugPrint("⚠️ Comment text is empty");
  //     return;
  //   }
  //
  //   final userProvider = Provider.of<FetchEditUserProvider>(context, listen: false);
  //   final userId = userProvider.userId;
  //
  //   if (userId == null) {
  //     debugPrint("❌ User not logged in");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Login required to comment.")),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     debugPrint("📤 Submitting comment: $text");
  //
  //     final commentJson = await Provider.of<HomeProvider>(context, listen: false)
  //         .addCommentToPost(
  //       postId: widget.postId,
  //       userId: userId,
  //       content: text,
  //     );
  //
  //     final newComment = CommentModel.fromJson(commentJson);
  //
  //     setState(() {
  //       _comments.insert(0, newComment);
 // _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // ⬅️ newest first

  //       _controller.clear();
  //     });
  //
  //     widget.onCommentCountChange(_comments.length);
  //
  //     await Future.delayed(const Duration(milliseconds: 80));
  //     _scrollController.animateTo(
  //       0,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //
  //     debugPrint("✅ Comment added successfully");
  //
  //     final recipientFcm = widget.event.organizerFcmToken ?? '';
  //     final organizerId = widget.postOwnerId;
  //
  //     debugPrint("📦 Organizer ID: $organizerId");
  //     debugPrint("📦 Organizer FCM Token: $recipientFcm");
  //
  //     await _sendCommentNotification(
  //       recipientFcmToken: recipientFcm,
  //       organizerId: organizerId,
  //       commentContent: text,
  //     );
  //   } catch (e, stackTrace) {
  //     debugPrint("❌ Error submitting comment: $e");
  //     debugPrint("🔍 Stack trace:\n$stackTrace");
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("❌ Failed to add comment: $e")),
  //     );
  //   }
  // }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userProvider = Provider.of<FetchEditUserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login required to comment.")),
      );
      return;
    }

    try {
      final commentJson = await Provider.of<HomeProvider>(context, listen: false)
          .addCommentToPost(
        postId: widget.postId,
        userId: userId,
        content: text,
      );

      final newComment = CommentModel.fromJson(commentJson);

      setState(() {
        _comments.insert(0, newComment);
        _comments.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // ⬅️ newest first
        _controller.clear();
      });

      widget.onCommentCountChange(_comments.length);

      await Future.delayed(const Duration(milliseconds: 80));
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // 🔔 Send comment notification
      const fallbackFcm = 'egxd4BvUTEy2_VBTiT6g6t:APA91bFhC7TQVRWSKan7-gKlyAjy6yn2HoOceBUANxZBefnqILQxVdUydd36M4s-U3IO0hAeugb-nJMuqEjwcEUwibhcTeFCNUNKHFf6vaoZzX2VfuQCq_U';

      await _sendCommentNotification(
        recipientFcmToken: fallbackFcm, // replace with actual token if available
        organizerId: widget.postOwnerId,
        commentContent: text,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add comment: $e")),
      );
    }
  }
  // Future<void> _sendCommentNotification({
  //   required String recipientFcmToken,
  //   required String organizerId,
  //   required String commentContent,
  // }) async {
  //   final profile = Provider.of<FetchEditUserProvider>(context, listen: false);
  //   final userId = profile.userId;
  //
  //   if (userId == null || recipientFcmToken.isEmpty) {
  //     debugPrint("🚫 Skipping notification: missing user ID or FCM token");
  //     return;
  //   }
  //
  //   debugPrint("📤 Sending notification...");
  //   debugPrint("📤 FCM Token: $recipientFcmToken");
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://srv861272.hstgr.cloud:8000/api/send-notification'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "fcmToken": recipientFcmToken,
  //         "title": "💬 New Comment",
  //         "body": "${profile.name ?? "Someone"} commented: \"$commentContent\"",
  //         "data": {
  //           "userId": userId,
  //           "userName": profile.name ?? "",
  //           "userAvatar": profile.userData['profile'] ?? "",
  //           "vendorId": widget.postId,
  //           "vendorName": widget.event.organizer,
  //         }
  //       }),
  //     );
  //
  //     debugPrint("📨 Notification status: ${response.statusCode}");
  //     debugPrint("📨 Notification response: ${response.body}");
  //
  //     final logRes = await http.post(
  //       Uri.parse('http://srv861272.hstgr.cloud:8000/api/notification'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         "user": organizerId,
  //         "message": "${profile.name ?? "Someone"} commented on your post"
  //       }),
  //     );
  //
  //     debugPrint("📝 Notification log saved: ${logRes.statusCode}");
  //   } catch (e, st) {
  //     debugPrint("❌ Notification error: $e");
  //     debugPrint("📌 Stack Trace:\n$st");
  //   }
  // }

  Future<void> _sendCommentNotification({
    required String? recipientFcmToken,
    required String organizerId,
    required String commentContent,
  }) async {
    final profile = Provider.of<FetchEditUserProvider>(context, listen: false);
    final userId = profile.userId;
    if (userId == null) return;

    // Static fallback for testing
    const staticToken = 'egxd4BvUTEy2_VBTiT6g6t:APA91bFhC7TQVRWSKan7-gKlyAjy6yn2HoOceBUANxZBefnqILQxVdUydd36M4s-U3IO0hAeugb-nJMuqEjwcEUwibhcTeFCNUNKHFf6vaoZzX2VfuQCq_U';
    final fcmToken = (recipientFcmToken != null && recipientFcmToken.isNotEmpty)
        ? recipientFcmToken
        : staticToken;
    // final fcmToken = (widget.recipientFcmToken?.isNotEmpty ?? false)
    //     ? widget.recipientFcmToken
    //     : staticToken;

    try {
      final response = await http.post(
        Uri.parse('http://srv861272.hstgr.cloud:8000/api/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fcmToken": fcmToken,
          "title": "💬 New Comment",
          "body": "${profile.name ?? "Someone"} commented: \"$commentContent\"",
          "data": {
            "userId": userId,
            "userName": profile.name ?? "",
            "userAvatar": profile.userData['profile'] ?? "",
            "vendorId": widget.postId,
            "vendorName": "", // optional
          }
        }),
      );

      debugPrint("📨 Comment Notification Response: ${response.statusCode}");
      debugPrint("📨 Body: ${response.body}");

      // Save to backend logs
      await http.post(
        Uri.parse('http://srv861272.hstgr.cloud:8000/api/notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user": organizerId,
          "message": "${profile.name ?? "Someone"} commented on your post"
        }),
      );
    } catch (e) {
      debugPrint('❌ Failed to send comment notification: $e');
    }
  }

  Future<void> _deleteComment(CommentModel c) async {
    try {
      await Provider.of<HomeProvider>(context, listen: false).deleteCommentFromPost(
        postId: widget.postId,
        commentId: c.id,
      );

      setState(() => _comments.removeWhere((cc) => cc.id == c.id));
      widget.onCommentCountChange(_comments.length);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comment deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete comment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loggedInUserId = Provider.of<FetchEditUserProvider>(context, listen: false).userId;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollSheetController) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text("Comments",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: _comments.length,
                    reverse: false,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.white),
                    itemBuilder: (_, index) {
                      final c = _comments[index];
                      final canDelete = loggedInUserId == c.userId ||
                          loggedInUserId == widget.postOwnerId;

                      Widget tile = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child:                  GestureDetector(
                          onTap: () {
                            if (c.userId != loggedInUserId) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SingleUserProfileScreen(userId: c.userId),
                                ),
                              );
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  radius: 18,
                                  backgroundImage: c.userProfile.isNotEmpty
                                      ? NetworkImage(c.userProfile)
                                      : const AssetImage('images/onbording/unkown.jpg') as ImageProvider,
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // First row: Username + time
                                    Row(
                                      children: [
                                        Text(
                                          c.userName,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          timeAgo(c.createdAt),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Second row: Comment content
                                    Text(
                                      c.content,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (!canDelete) return tile;

                      return GestureDetector(
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Delete Comment"),
                              content: const Text("Are you sure you want to delete this comment?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) _deleteComment(c);
                        },
                        child: tile,
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _submit,
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
