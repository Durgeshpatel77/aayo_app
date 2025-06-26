import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../event_detail_screens/chat_page.dart';
import '../utils/chat_helper.dart'; // 🔄 Make sure this has generateChatId()

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController searchController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _filteredChats = [];
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    listenToChatSummaries();
  }

  void listenToChatSummaries() {
    _chatSubscription = FirebaseFirestore.instance
        .collection('chat_summaries')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      final chats = snapshot.docs.map((doc) {
        final data = doc.data();
        final users = List<String>.from(data['users']);
        final peerId = users.firstWhere((id) => id != currentUserId, orElse: () => 'unknown');

        final userDetails = data['userDetails'] ?? {};
        final peerName = userDetails[peerId]?['name'] ?? 'User $peerId';

        return {
          'chatId': data['chatId'],
          'peerId': peerId,
          'name': peerName,
          'imageUrl': 'https://api.dicebear.com/7.x/initials/svg?seed=$peerId',
          'lastMessage': data['lastMessage'] ?? '',
          'lastTimestamp': (data['lastTimestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();

      setState(() {
        _chats = chats;
        _filteredChats = chats;
      });
    });
  }

  void _filterChats(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredChats = _chats.where((chat) {
        return chat['name'].toString().toLowerCase().contains(lower);
      }).toList();
    });
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return DateFormat.jm().format(time);
    } else {
      return DateFormat.MMMd().format(time);
    }
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink.shade400,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink.shade400),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredChats.isEmpty
                ? const Center(child: Text("No chats found"))
                : ListView.builder(
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                final chat = _filteredChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(chat['imageUrl']),
                    radius: 26,
                  ),
                  title: Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    chat['lastMessage'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTime(chat['lastTimestamp']),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserId: currentUserId,
                          peerUserId: chat['peerId'],
                          peerName: chat['name'],
                          chatId: chat['chatId'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
