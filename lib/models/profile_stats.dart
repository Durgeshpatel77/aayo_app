// Reusable widget for a single connection/activity stats
import 'dart:ui';

import 'package:flutter/material.dart';

class StatWidget extends StatelessWidget {
  final List<String> avatarUrls;
  final String count;
  final String label;

  const StatWidget({
    super.key,
    required this.avatarUrls,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center content in the row
          children: [
            // Stacked Avatars
            if (avatarUrls.isNotEmpty)
              SizedBox(
                // Give the Stack a defined size
                width: 24.0 +
                    (avatarUrls.length.clamp(0, 3) - 1) *
                        12.0, // Calculate width based on overlaps
                height: 24.0, // Height of the avatars
                child: Stack(
                  children: List.generate(
                    avatarUrls.length.clamp(0, 3), // Show max 3 avatars
                    (index) => Positioned(
                      left: (index * 12).toDouble(), // Overlap effect
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white, // Border around avatar
                        child: CircleAvatar(
                          radius: 11, // Slightly smaller for the actual image
                          backgroundImage: NetworkImage(avatarUrls[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (avatarUrls.isNotEmpty)
              const SizedBox(width: 8), // Smaller space after stacked avatars
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
