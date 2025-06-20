import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event_model.dart';
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart';
import 'comment_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _commentCount = widget.post.comments.length;
    _likeCount = widget.post.likes.length;
    _isLiked = widget.post.likes.contains('user123'); // Replace with actual user ID
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likeCount--;
        widget.post.likes.remove('user123'); // Replace with actual user ID
      } else {
        _likeCount++;
        widget.post.likes.add('user123'); // Replace with actual user ID
      }
      _isLiked = !_isLiked;
    });

    // TODO: Optionally send API request to update like status on backend
  }

  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  void _handleDoubleTap() {
    setState(() {
      if (_zoomed) {
        _transformationController.value = Matrix4.identity();
      } else {
        _transformationController.value = Matrix4.identity()..scale(2.5);
      }
      _zoomed = !_zoomed;
    });
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
          // Zoomable + Double Tap Image
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 550,
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
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
                    errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                  )
                      : const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // Bottom content (User info, caption, likes)
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

          // Right action icons (like, comment, share)
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
                  onTap: () {
                    showModalBottomSheet(
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
                          onAddComment: (newText) {
                            setState(() {
                              _commentCount += 1;
                            });
                          },
                        );
                      },
                    );
                  },
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
