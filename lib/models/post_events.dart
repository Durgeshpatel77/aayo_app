// lib/models/event_model.dart
import 'dart:io';

import 'package:flutter/material.dart';

class PostEvents {
  final String id; // Unique ID for each event
  final String name;
  final String caption;
  final String location;
  final String category;
  final String organizer;
  final double price;
  final DateTime date;
  final TimeOfDay time;
  final File? image;

  PostEvents({
    required this.id,
    required this.name,
    required this.caption,
    required this.location,
    required this.category,
    required this.organizer,
    required this.price,
    required this.date,
    required this.time,
    this.image,
  });

  // Helper for combining date and time for full DateTime object if needed
  DateTime get fullDateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
