import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> get chats => _filteredChats;

  List<Map<String, dynamic>> _filteredChats = [];

  String _searchQuery = '';
  String? currentUserId;

  void setCurrentUserId(String uid) {
    currentUserId = uid;
    fetchChats();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filteredChats = _chats
        .where((chat) =>
        chat['name'].toString().toLowerCase().contains(_searchQuery))
        .toList();
    notifyListeners();
  }

  Future<void> fetchChats() async {
    if (currentUserId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('chat_summaries')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .get();

    _chats = snapshot.docs.map((doc) {
      final data = doc.data();
      final peerId = (data['users'] as List)
          .firstWhere((id) => id != currentUserId);

      return {
        'chatId': data['chatId'],
        'peerId': peerId,
        'name': 'User $peerId', // Replace with real name later
        'imageUrl': 'https://i.pravatar.cc/150?u=$peerId', // Fake image
        'lastMessage': data['lastMessage'] ?? '',
        'time': data['lastTimestamp'] != null
            ? _formatTime((data['lastTimestamp'] as Timestamp).toDate())
            : '',
      };
    }).toList();

    _filteredChats = [..._chats];
    notifyListeners();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}
