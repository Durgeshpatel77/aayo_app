import 'dart:io';
import 'package:flutter/material.dart';

class UserInfo {
  final String id;
  final String name;
  final String? profile; // Profile image URL

  UserInfo({required this.id, required this.name, this.profile});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profile: json['profile'] as String?,
    );
  }
}

class EventDetails {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String city;
  final double latitude;
  final double longitude;
  final String description;
  final bool isFree;
  final double price;
  final String? venueName;     // ✅ new
  final String? venueAddress;  // ✅ new (used for landmark)

  EventDetails({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.isFree,
    required this.price,
    this.venueName,
    this.venueAddress,

  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      title: json['title'] as String? ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      location: json['location'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      isFree: json['isFree'] as bool? ?? true,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      venueName: json['venueName'] as String?,       // ✅
      venueAddress: json['venueAddress'] as String?, // ✅

    );
  }
}

class VenueDetails {
  final String? location;
  final String? city;
  final double? latitude;
  final double? longitude;
  final List<String> facilities;

  VenueDetails({
    this.location,
    this.city,
    this.latitude,
    this.longitude,
    this.facilities = const [],
  });

  factory VenueDetails.fromJson(Map<String, dynamic> json) {
    return VenueDetails(
      location: json['location'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      facilities: List<String>.from(json['facilities'] ?? []),
    );
  }
}

class EventModel {
  final String name;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? location;
  final String? description;
  final String? ticketType;
  final String? ticketPrice;
  final File? image;

  final EventDetails? eventDetails;
  final VenueDetails? venueDetails;
  final String id;
  final String type;
  final UserInfo user;
  final String title;
  final String content;
  final List<String> media;
  final List<dynamic> likes;
  final List<dynamic> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    this.name = '',
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.location,
    this.description,
    this.ticketType,
    this.ticketPrice,
    this.image,
    this.eventDetails,
    this.venueDetails,
    required this.id,
    required this.type,
    required this.user,
    required this.title,
    required this.content,
    this.media = const [],
    this.likes = const [],
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final eventDetailsJson = json['eventDetails'] as Map<String, dynamic>?;
    final venueDetailsJson = json['venueDetails'] as Map<String, dynamic>?;

    EventDetails? eventDetails;
    VenueDetails? venueDetails;

    if (type == 'event' && eventDetailsJson != null) {
      eventDetails = EventDetails.fromJson(eventDetailsJson);
    } else if (type == 'venue' && venueDetailsJson != null) {
      venueDetails = VenueDetails.fromJson(venueDetailsJson);
    }

    final start = type == 'event' && eventDetailsJson != null
        ? DateTime.tryParse(eventDetailsJson['startTime'] ?? '')
        : null;
    final end = type == 'event' && eventDetailsJson != null
        ? DateTime.tryParse(eventDetailsJson['endTime'] ?? '')
        : null;

    return EventModel(
      eventDetails: eventDetails,
      venueDetails: venueDetails,
      id: json['_id'] as String? ?? '',
      type: type,
      user: UserInfo.fromJson(json['user'] ?? {}),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      media: List<String>.from(json['media'] ?? []),
      likes: List<dynamic>.from(json['likes'] ?? []),
      comments: List<dynamic>.from(json['comments'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),

      // creation-only fields
      name: json['title'] as String? ?? '',
      startDate: start,
      startTime: start != null ? TimeOfDay.fromDateTime(start) : null,
      endDate: end,
      endTime: end != null ? TimeOfDay.fromDateTime(end) : null,
      location: type == 'event' && eventDetailsJson != null
          ? eventDetailsJson['location'] as String? ?? ''
          : (type == 'venue' && venueDetailsJson != null
          ? venueDetailsJson['location'] as String? ?? ''
          : null),
      description: json['content'] as String? ?? '',
      ticketType: (type == 'event' && eventDetailsJson != null)
          ? ((eventDetailsJson['isFree'] as bool? ?? true) ? 'Free' : 'Paid')
          : null,
      ticketPrice: (type == 'event' && eventDetailsJson != null)
          ? (eventDetailsJson['price']?.toString() ?? '0')
          : null,
      image: null,
    );
  }
}