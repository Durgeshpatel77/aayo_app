import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/comment_model.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart';
import 'comment_sheet.dart';
import 'package:flutter/services.dart';



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

    // 🔁 Optimistic update
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      if (_isLiked) {
        widget.post.likes.add(userId);
      } else {
        widget.post.likes.remove(userId);
      }
    });

    // 🔊 Play sound only if user just liked (not on unlike)
    if (!wasLiked) {
      await _playLikeSound(); // ✅ Reuse your existing method
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
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      // Revert on failure
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
  Future<void> _playLikeSound() async {
    try {
      debugPrint('🔊 Attempting to play sound...');
      await _audioPlayer.play(AssetSource('sounds/like.mp3'));
      debugPrint('✅ Sound played!');
    } catch (e) {
      debugPrint('🔇 Failed to play like sound: $e');
    }
  }


  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable image
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75, // ✅ 75% of screen
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
                        fit: BoxFit.cover,
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
            bottom: 100,
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

          // Action icons
          Positioned(
            bottom: 130,
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
                GestureDetector(
                  onTap: _openCommentSheet,
                  child: Column(
                    children: [
                      const Icon(Icons.comment_outlined, color: Colors.white, size: 30),
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
                const Icon(Icons.send_outlined, color: Colors.white, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
