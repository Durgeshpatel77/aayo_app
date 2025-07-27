import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/event_model.dart';
import '../../models/comment_model.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart';
import 'comment_sheet.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';


class PostDetailScreen extends StatefulWidget {
  final Event post;

  const PostDetailScreen({required this.post, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _zoomed = false;
  late int _commentCount;
  late bool _isLiked;
  late int _likeCount;
  bool _showHeart = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/sounds/like.mp3').then((_) {
      debugPrint('✅ like.mp3 loaded successfully');
    }).catchError((e) {
      debugPrint('❌ like.mp3 failed to load: $e');
    });

    final userId = Provider.of<FetchEditUserProvider>(context, listen: false).userId;

    _commentCount = widget.post.comments.length;
    _likeCount = widget.post.likes.length;
    _isLiked = userId != null && widget.post.likes.contains(userId);
  }

  Future<void> _playLikeSound() async {
    try {
      debugPrint('🔊 Attempting to play sound...');
      await _audioPlayer.play(AssetSource('sounds/like.mp3'));
      debugPrint('✅ Sound played!');
    } catch (e) {
      debugPrint('🔇 Failed to play like sound: $e');
    }
  }
  void _toggleLike() async {
    final userProfileProvider = Provider.of<FetchEditUserProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final userId = userProfileProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to like this.")),
      );
      return;
    }

    final wasLiked = _isLiked;

    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      if (_isLiked) {
        widget.post.likes.add(userId);
      } else {
        widget.post.likes.remove(userId);
      }
    });

    if (!wasLiked) {
      await _playLikeSound();
      HapticFeedback.mediumImpact();
    }

    try {
      final response = await userProfileProvider.toggleLike(
        postId: widget.post.id,
        userId: userId,
      );

      if (response['success'] == true) {
        final updatedLikes = List<String>.from(response['likes'] ?? []);
        homeProvider.updateEventLikes(widget.post.id, updatedLikes);

        if (_isLiked && widget.post.organizerId != userId) {
          final fcmToken = widget.post.organizerFcmToken;

          // ✅ Get full post image URL
          final postImageUrl = widget.post.image.startsWith('http')
              ? widget.post.image
              : 'http://82.29.167.118:8000/${widget.post.image}';

          debugPrint("📦 Post Like FCM Target: ${widget.post.organizerId}");
          debugPrint("📦 Post Like FCM Token: $fcmToken");
          debugPrint("🖼️ Post Image sent: $postImageUrl");

          final res = await http.post(
            Uri.parse('http://82.29.167.118:8000/api/send-notification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "fcmToken": fcmToken,
              "title": "❤️ New Like",
              "body": "${userProfileProvider.name ?? 'Someone'} liked your post",
              "postImage": postImageUrl,  // ✅ THIS must match the key used in NotificationService
              "data": {
                "userId": userId,
                "userName": userProfileProvider.name ?? "",
                "vendorId": widget.post.id,
                "vendorName": widget.post.organizer,
                "type": "post"
              }
            }),
          );

          debugPrint('📨 Like Notif Sent: ${res.statusCode}');
          debugPrint('📨 Body: ${res.body}');

          await http.post(
            Uri.parse('http://82.29.167.118:8000/api/notification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "user": widget.post.organizerId,
              "message": "${userProfileProvider.name ?? "Someone"} liked your post"
            }),
          );
        } else {
          debugPrint("⚠️ Notification skipped (own post or unliked)");
        }
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      setState(() {
        _isLiked = wasLiked;
        _likeCount += _isLiked ? 1 : -1;
        if (_isLiked) {
          widget.post.likes.add(userId);
        } else {
          widget.post.likes.remove(userId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update like: $e')),
      );
    }
  }

  Future<void> _sharePost() async {
    final post = widget.post;

    // ✅ Construct shareable link
    final String shareLink = 'https://aayo.page.link/post/${post.id}';

    final String text = '${post.title}\n\n'
        '${post.content}\n\n'
        'Check this post out on Aayo App 👇\n$shareLink';

    final String imageUrl = post.media.isNotEmpty
        ? getFullImageUrl(post.media.first)
        : (post.image.isNotEmpty ? getFullImageUrl(post.image) : '');

    try {
      if (imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/shared_post.jpg');
          await file.writeAsBytes(bytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: text,
          );
          debugPrint('✅ Post shared with image + link');
        } else {
          debugPrint('⚠️ Failed to download image. Status: ${response.statusCode}');
          await Share.share(text); // fallback to text only
        }
      } else {
        await Share.share(text); // no image fallback
      }
    } catch (e) {
      debugPrint('❌ Failed to share post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to share the post")),
      );
    }
  }
  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://82.29.167.118:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  void _handleDoubleTap() async {
    final userProfileProvider = Provider.of<FetchEditUserProvider>(context, listen: false);
    final userId = userProfileProvider.userId;

    if (userId == null || _isLiked) {
      debugPrint('⚠️ Already liked or no user ID');
      return;
    }

    debugPrint('❤️ Double-tap like triggered by user: $userId');
    _playLikeSound();
    HapticFeedback.mediumImpact(); // 🔊 + 🔋

    setState(() {
      _isLiked = true;
      _likeCount++;
      widget.post.likes.add(userId);
      _showHeart = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showHeart = false);
    });

    try {
      final response = await userProfileProvider.toggleLike(
        postId: widget.post.id,
        userId: userId,
      );

      debugPrint('📡 Like API response: $response');

      if (response['success'] == true) {
        final updatedLikes = List<String>.from(response['likes'] ?? []);
        Provider.of<HomeProvider>(context, listen: false)
            .updateEventLikes(widget.post.id, updatedLikes);
        debugPrint('✅ Provider updated with new likes: ${updatedLikes.length}');
      }
    } catch (e) {
      debugPrint('❌ API call failed: $e');
      setState(() {
        _isLiked = false;
        _likeCount--;
        widget.post.likes.remove(userId);
      });
    }
  }
  Future<void> _openCommentSheet() async {
    final updatedComments = await showModalBottomSheet<List<CommentModel>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return CommentSheet(
          initialComments: widget.post.comments,
          postId: widget.post.id,
          postOwnerId: widget.post.organizerId,
          recipientFcmToken: widget.post.organizerFcmToken, // ✅ pass this dynamically
          event: widget.post,
          onCommentCountChange: (int newCount) {
            setState(() => _commentCount = newCount);
          },

        );
      },
    );

    if (updatedComments != null) {
      setState(() {
        widget.post.comments
          ..clear()
          ..addAll(updatedComments);
        _commentCount = updatedComments.length;
      });

      // 👇 Update in provider so HomeScreen gets refreshed
      Provider.of<HomeProvider>(context, listen: false)
          .updateEventComments(widget.post.id, updatedComments);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String postImageUrl = widget.post.media.isNotEmpty
        ? getFullImageUrl(widget.post.media.first)
        : (widget.post.image.isNotEmpty ? getFullImageUrl(widget.post.image) : '');

    final String profileUrl = widget.post.organizerProfile.isNotEmpty
        ? getFullImageUrl(widget.post.organizerProfile)
        : 'https://randomuser.me/api/portraits/men/75.jpg';

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Stack(
        children: [
          // Zoomable image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.92, // Or 1.0 for full
              color: Color(0xFF121212),
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 4.0,
                      panEnabled: true,
                      child: postImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: postImageUrl,
                        fit: BoxFit.contain, // keep aspect ratio
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white),
                        ),
                      )
                          : const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.white),
                      ),
                    ),
                    if (_showHeart)
                      AnimatedOpacity(
                        opacity: _showHeart ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.favorite,
                          size: 100,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Post info
          Positioned(
            bottom: 30,
            left: 16,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(profileUrl),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.post.organizer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${timeAgo(widget.post.createdAt)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ExpandableText(
                  content: widget.post.content,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  '$_likeCount likes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

            ),

          ),
          Positioned(
            bottom: 60,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Like
                GestureDetector(
                  onTap: _toggleLike,
                  child: Column(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white,
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_likeCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Comment
                // Comment
                GestureDetector(
                  onTap: _openCommentSheet,
                  child: Column(
                    children: [
                      Image.asset(
                        'images/chat_icon.png',
                        width: 28,
                        height: 28,
                        color: Colors.white, // optional: remove if image is full-color
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_commentCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Share
                GestureDetector(
                  onTap: _sharePost,
                  child: Column(
                    children: [
                      Image.asset(
                          'images/share_icon.png',
                          width: 26,
                          height: 26,
                          color: Colors.white
                      ),
                      const SizedBox(height: 4),
                      const Text('Share', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],

      ),

    );
  }
}