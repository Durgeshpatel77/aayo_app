// lib/models/event_model.dart

import 'package:flutter/material.dart';

import 'comment_model.dart'; // Import for debugPrint

class Event {
  final String id;
  final String title;
  final String content;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isFree;
  final String organizerId;
  final double price;
  final List<String> likes;
  final List<CommentModel> comments;
  final String image;
  final List<String> media;
  final String organizer;
  final String organizerProfile;
  final DateTime createdAt;
  final String type;

  Event({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isFree,
    required this.organizerId,
    required this.price,
    required this.likes,
    required this.comments, // <-- Add this line
    required this.image,
    this.media = const [],
    this.organizer = '',
    this.organizerProfile = '',
    required this.createdAt,
    required this.type,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventDetails = json['eventDetails'] ?? {};
    final user = json['user'] ?? {};

    final String parsedType = json['type'] ?? 'post';

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
      fullOrganizerProfileUrl = 'https://randomuser.me/api/portraits/men/75.jpg';
    }

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

    final commentsJson = json['comments'] as List<dynamic>? ?? [];

    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      location: eventDetails['location'] ?? '',
      startTime: DateTime.tryParse(eventDetails['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(eventDetails['endTime'] ?? '') ?? DateTime.now(),
      isFree: eventDetails['isFree'] ?? true,
      organizerId: user['_id'] as String? ?? '',
      price: (eventDetails['price'] ?? 0).toDouble(),
      likes: (json['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      comments: commentsJson.map((c) => CommentModel.fromJson(c)).toList(),
      image: json['image'] ?? '',
      media: parsedMedia,
      organizer: user['name'] ?? 'Unknown User',
      organizerProfile: fullOrganizerProfileUrl,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      type: parsedType,
    );
  }

  bool get isEvent => type == 'event';
  bool get isPost => type == 'post';
}