// lib/models/event_model.dart
import 'package:flutter/material.dart'; // Import for debugPrint

class Event {
  final String id;
  final String title;
  final String content;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isFree;
  final double price;
  final List<String> likes;
  final List<String> comments;
  final String image;
  final List<String> media;
  final String organizer;
  final String organizerProfile;
  final DateTime createdAt;
  final String type; // NEW: To distinguish between 'post' and 'event'

  Event({
    required this.id,

    required this.title,
    required this.content,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isFree,
    required this.price,
    required this.likes,
    required this.comments,
    required this.image,
    this.media = const [],
    this.organizer = '',
    this.organizerProfile = '',
    required this.createdAt,
    required this.type, // NEW
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventDetails = json['eventDetails'] ?? {};
    final user = json['user'] ?? {};

    // Determine the type explicitly from the JSON
    final String parsedType = json['type'] ?? 'post'; // Default to 'post' if not specified

    // Build the full profile URL
    const String baseUrl = 'http://srv861272.hstgr.cloud:8000';
    String userProfilePath = user['profile'] ?? '';
    String fullOrganizerProfileUrl;

    if (userProfilePath.isNotEmpty) {
      if (userProfilePath.startsWith('http')) {
        fullOrganizerProfileUrl = userProfilePath;
      } else {
        fullOrganizerProfileUrl = '$baseUrl/$userProfilePath';
      }
    } else {
      fullOrganizerProfileUrl = 'https://randomuser.me/api/portraits/men/75.jpg'; // Default fallback
    }

    // Parse media, handling both string and map structures
    List<String> parsedMedia = [];
    if (json['media'] is List) {
      parsedMedia = (json['media'] as List<dynamic>)
          .map((e) {
        if (e is String) return e;
        if (e is Map && e['url'] is String) return e['url'] as String;
        return '';
      })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      location: eventDetails['location'] ?? '',
      startTime: DateTime.tryParse(eventDetails['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(eventDetails['endTime'] ?? '') ?? DateTime.now(),
      isFree: eventDetails['isFree'] ?? true,
      price: (eventDetails['price'] ?? 0).toDouble(),
      likes: (json['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      image: json['image'] ?? '', // Primary image field
      media: parsedMedia, // All media items
      organizer: user['name'] ?? 'Unknown User',
      organizerProfile: fullOrganizerProfileUrl,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      type: parsedType, // Assign the parsed type
    );
  }

  // Getter to explicitly check if it's an event
  bool get isEvent => type == 'event';
  // Getter to explicitly check if it's a post
  bool get isPost => type == 'post';
}