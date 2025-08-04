import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String? profileImageUrl;
  final String title;
  final String subtitle;
  final String? trailingImageUrl;

  const NotificationItem({
    super.key,
    this.profileImageUrl,
    required this.title,
    required this.subtitle,
    this.trailingImageUrl,
  });
  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) {
      return path; // Already a full URL
    }
    return "http://82.29.167.118:8000/$path";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? NetworkImage(getFullImageUrl(profileImageUrl))
            : const AssetImage("assets/default-user.png") as ImageProvider,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: trailingImageUrl != null && trailingImageUrl!.isNotEmpty
          ? GestureDetector(
        onTap: () {
          // Open post or event detail directly
          // You can pass callback from Notificationscreen
        },
        child: SizedBox(
          width: 50,
          height: 50,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              getFullImageUrl(trailingImageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset("assets/default-image.png", fit: BoxFit.cover),
            ),
          ),
        ),
      )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
