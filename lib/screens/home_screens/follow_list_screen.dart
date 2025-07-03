import 'package:aayo/screens/home_screens/single_user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';

  class FollowListScreen extends StatefulWidget {
  final String title;
  final List<dynamic> users;

  const FollowListScreen({
    super.key,
    required this.title,
    required this.users,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  String? backendUserId;
  Map<String, bool> followStatusMap = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    backendUserId = prefs.getString('backendUserId');

    final provider = Provider.of<FetchEditUserProvider>(context, listen: false);
    final data = await provider.fetchUserById(backendUserId!);
    final followingList = data['following'] as List<dynamic>? ?? [];

    final followingSet = followingList.map((f) => f['_id'].toString()).toSet();

    final map = <String, bool>{};
    for (var user in widget.users) {
      final id = user['_id'];
      map[id] = followingSet.contains(id);
    }

    setState(() {
      followStatusMap = map;
    });
  }

  Future<void> _toggleFollow(String userId) async {
    final provider = Provider.of<FetchEditUserProvider>(context, listen: false);
    final isCurrentlyFollowing = followStatusMap[userId] ?? false;

    // Get backendUserId and Name for notification
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('backendUserId');
    final currentUserName = provider.name ?? prefs.getString('backendUserName') ?? 'Someone';

    // Show unfollow confirmation if needed
    if (isCurrentlyFollowing) {
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.remove_circle_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              const Text("Remove Follower?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("They won't be notified and will no longer follow you.",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel", style: TextStyle(color: Colors.pink)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Remove", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (confirmed != true) return;
    }

    // Optimistic update
    setState(() {
      followStatusMap[userId] = !isCurrentlyFollowing;
    });

    final result = await provider.toggleFollow(userId);
    if (!mounted) return;

    if (!result['success']) {
      setState(() {
        followStatusMap[userId] = isCurrentlyFollowing;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update follow')),
      );
      return;
    }

    // 🔔 Send follow notification if just followed
    if (!isCurrentlyFollowing) {
      final followedUserIndex = widget.users.indexWhere((u) => u['_id'] == userId);
      Map<String, dynamic> followedUser = {};

      if (followedUserIndex != -1) {
        final rawUser = widget.users[followedUserIndex];
        followedUser = Map<String, dynamic>.from(rawUser); // ✅ safe cast
      }

      String? toFcmToken = followedUser['fcmToken'];

      // Fallback: try getting from result if missing
      if (toFcmToken == null || toFcmToken.trim().isEmpty) {
        final apiUserData = result['data'];
        if (apiUserData != null && apiUserData is Map) {
          final castedUser = Map<String, dynamic>.from(apiUserData);
          toFcmToken = castedUser['fcmToken'];

          // Update local user list
          if (toFcmToken != null && followedUserIndex != -1) {
            widget.users[followedUserIndex] = {
              ...Map<String, dynamic>.from(widget.users[followedUserIndex]),
              'fcmToken': toFcmToken,
            };
          }
        }
      }

      // 🔔 Send notification if valid token
      if (toFcmToken != null && toFcmToken.trim().isNotEmpty) {
        provider.sendFollowNotification(
          toUserFcmToken: toFcmToken,
          fromUserName: currentUserName,
        );
      } else {
        debugPrint('⚠️ No FCM token available for user $userId — skipping notification');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
        elevation: 1,
      ),
      body: backendUserId == null
          ? const Center(child: CircularProgressIndicator(color: Colors.pink,))
          : widget.users.isEmpty
          ? const Center(child: Text("No users found."))
          : ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (_, index) {
          final user = widget.users[index];
          final userId = user['_id'];
          final name = user['name'] ?? 'Unknown';
          final profile = user['profile'] ?? '';
          final imageUrl = profile.isNotEmpty
              ? 'http://srv861272.hstgr.cloud:8000/$profile'
              : null;

          final isSelf = backendUserId == userId;
          final isFollowing = followStatusMap[userId] ?? false;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: imageUrl != null
                  ? NetworkImage(imageUrl)
                  : const AssetImage('images/default_avatar.png') as ImageProvider,
            ),
            title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            trailing: isSelf
                ? null
                : GestureDetector(
              onTap: () => _toggleFollow(userId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isFollowing ? Colors.grey[300] : Colors.pink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFollowing ? Colors.grey : Colors.pink,
                  ),
                ),
                child: Text(
                  isFollowing ? "Following" : "Follow",
                  style: TextStyle(
                    color: isFollowing ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onTap: () {
              if (!isSelf) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleUserProfileScreen(userId: userId),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
