import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSummary {
  final String chatId;
  final List<String> users;
  final String peerName;
  final String lastMessage;
  final DateTime lastTimestamp;

  ChatSummary({
    required this.chatId,
    required this.users,
    required this.peerName,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      chatId: json['chatId'],
      users: List<String>.from(json['users']),
      peerName: json['peerName'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastTimestamp: (json['lastTimestamp'] as Timestamp).toDate(),
    );
  }
}
