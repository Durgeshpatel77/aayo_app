// lib/screens/post_detail_screens/post_details.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/event_model.dart';
import '../other_for_use/utils.dart'; // Reusing Event model for post data

class PostDetailScreen extends StatelessWidget {
  final Event post; // Using Event model for simplicity, acts as a Post here

  const PostDetailScreen({required this.post, super.key});

  String getFullImageUrl(String relativePath) {
    const baseUrl = 'http://srv861272.hstgr.cloud:8000';
    if (relativePath.startsWith('http')) return relativePath;
    if (!relativePath.startsWith('/')) relativePath = '/$relativePath';
    return '$baseUrl$relativePath';
  }

  @override
  Widget build(BuildContext context) {
    final String postImageUrl = post.media.isNotEmpty
        ? getFullImageUrl(post.media.first)
        : (post.image.isNotEmpty ? getFullImageUrl(post.image) : ''); // Check 'image' too

    final String profileUrl = post.organizerProfile.isNotEmpty
        ? getFullImageUrl(post.organizerProfile)
        : 'https://randomuser.me/api/portraits/men/75.jpg'; // Fallback for profile

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title.isNotEmpty ? post.title : 'Post Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Author Info
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profileUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading profile image: $exception');
                },
              ),
              title: Text(
                post.organizer,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(timeAgo(post.createdAt)),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Post Title
            if (post.title.isNotEmpty)
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),

            // Post Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),

            // Post Image/Media
            if (postImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: postImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.grey.shade300,
                    child: const Center(child: CircularProgressIndicator(color: Colors.pink)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 250,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Likes and Comments Section (simplified)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 5),
                    Text('${post.likes.length} Likes'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.comment_outlined, color: Colors.blueAccent, size: 20),
                    const SizedBox(width: 5),
                    Text('${post.comments.length} Comments'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // You can add a comment input field here similar to EventCard's CommentSheet
          ],
        ),
      ),
    );
  }
}