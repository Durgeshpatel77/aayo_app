// models/event_model.dart (or create_event_model.dart)
import 'dart:io';
import 'package:flutter/material.dart';

class UserInfo {
  final String id;
  final String name;
  final String? profile; // Profile image URL

  UserInfo({required this.id, required this.name, this.profile});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] as String,
      name: json['name'] as String,
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
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      isFree: json['isFree'] as bool,
      price: (json['price'] as num).toDouble(),
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
  // Fields for created events (from your previous EventCreationProvider)
  final String name;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? location;
  final String? description;
  final String? ticketType;
  final String? ticketPrice;
  final File? image; // For local image file before upload

  // Fields from API response (for fetched events)
  final EventDetails? eventDetails;
  final VenueDetails? venueDetails;
  final String id;
  final String type;
  final UserInfo user;
  final String title;
  final String content;
  final List<String> media; // List of image URLs from server
  final List<dynamic> likes;
  final List<dynamic> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    // Fields for creation (optional if only parsing from API)
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

    // Fields from API
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
    // Determine if it's an event or venue post based on 'type'
    EventDetails? eventDetails;
    VenueDetails? venueDetails;

    if (json['type'] == 'event') {
      eventDetails = EventDetails.fromJson(json['eventDetails']);
    } else if (json['type'] == 'venue') {
      venueDetails = VenueDetails.fromJson(json['venueDetails']);
    }

    return EventModel(
      // Fields from API
      eventDetails: eventDetails,
      venueDetails: venueDetails,
      id: json['_id'] as String,
      type: json['type'] as String,
      user: UserInfo.fromJson(json['user']),
      title: json['title'] as String,
      content: json['content'] as String,
      media: List<String>.from(json['media'] ?? []),
      likes: List<dynamic>.from(json['likes'] ?? []),
      comments: List<dynamic>.from(json['comments'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),

      // Dummy values for the old creation fields, or you can make them nullable
      // if this model is primarily for fetched data.
      name: json['title'] as String, // Use title from API as name
      startDate: (json['type'] == 'event' && json['eventDetails'] != null)
          ? DateTime.parse(json['eventDetails']['startTime'] as String)
          : null,
      startTime: (json['type'] == 'event' && json['eventDetails'] != null)
          ? TimeOfDay.fromDateTime(DateTime.parse(json['eventDetails']['startTime'] as String))
          : null,
      endDate: (json['type'] == 'event' && json['eventDetails'] != null)
          ? DateTime.parse(json['eventDetails']['endTime'] as String)
          : null,
      endTime: (json['type'] == 'event' && json['eventDetails'] != null)
          ? TimeOfDay.fromDateTime(DateTime.parse(json['eventDetails']['endTime'] as String))
          : null,
      location: (json['type'] == 'event' && json['eventDetails'] != null)
          ? json['eventDetails']['location'] as String
          : (json['type'] == 'venue' && json['venueDetails'] != null)
          ? json['venueDetails']['location'] as String
          : null,
      description: json['content'] as String,
      ticketType: (json['type'] == 'event' && json['eventDetails'] != null)
          ? (json['eventDetails']['isFree'] ? 'Free' : 'Paid')
          : null,
      ticketPrice: (json['type'] == 'event' && json['eventDetails'] != null)
          ? (json['eventDetails']['price'] as num).toString()
          : null,
      image: null, // Fetched image is handled by 'media' URLs
    );
  }
}