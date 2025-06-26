import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
