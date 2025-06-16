// lib/models/event_model.dart
import 'dart:io';
import 'package:flutter/material.dart'; // Needed for TimeOfDay

class EventModel {
  final String name;
  final DateTime? startDate;
  final TimeOfDay? startTime;
  final DateTime? endDate;
  final TimeOfDay? endTime;
  final String? location;
  final String? description;
  final String ticketType;
  final String? ticketPrice;
  final File? image;

  EventModel({
    required this.name,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.location,
    this.description,
    required this.ticketType,
    this.ticketPrice,
    this.image,
  });
}