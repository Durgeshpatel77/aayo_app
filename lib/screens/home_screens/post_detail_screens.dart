import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event_model.dart';
import '../other_for_use/expandable_text.dart';
import '../other_for_use/utils.dart';

class PostDetailScreen extends StatefulWidget {
  final Event post;

  const PostDetailScreen({required this.post, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TransformationController _transformationController = TransformationController();
  bool _zoomed = false;

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
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  )
                      : const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // Bottom content
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
                  '${widget.post.likes.length} likes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Right actions
          Positioned(
            bottom: 130,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.favorite_border, color: Colors.white, size: 30),
                SizedBox(height: 30),
                Icon(Icons.comment_outlined, color: Colors.white, size: 30),
                SizedBox(height: 30),
                Icon(Icons.send_outlined, color: Colors.white, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
