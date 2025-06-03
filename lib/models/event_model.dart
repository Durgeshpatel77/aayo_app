// lib/models/event_model.dart
import 'dart:io';
import 'package:flutter/material.dart'; // Import for TimeOfDay

class Event {
  final String id; // Unique ID for each event
  final String name;
  final String caption;
  final String location;
  final String category;
  final String organizer;
  final double price;
  final DateTime date; // Still keeping date and time separate for form logic
  final TimeOfDay time;
  final File? image; // Now nullable
  final String imageUrl; // For a network image URL if you implement it later
  final DateTime
      eventDateTime; // Combined date and time for easier sorting/display

  Event({
    required this.id,
    required this.name,
    required this.caption,
    required this.location,
    required this.category,
    required this.organizer,
    required this.price,
    required this.date,
    required this.time,
    this.image, // Now nullable
    this.imageUrl = '', // Provide a default empty string or make it nullable
    required this.eventDateTime, // This should be a combined DateTime
  });

  // You already have a getter, but the constructor now takes eventDateTime directly.
  // You can still keep this for convenience if you want to access the combined date/time
  // from the separate date and time fields.
  DateTime get fullDateTimeFromSeparateFields {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
