import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Notification Model
class NotificationModel {
  final String id;
  final String user;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.user,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      user: json['user'] is Map<String, dynamic> ? (json['user']['name'] ?? 'Unknown') : (json['user'] ?? 'Unknown'),
      message: json['message'] ?? json['text'] ?? 'No message',
      isRead: json['isRead'] ?? json['read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

