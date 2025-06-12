import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final List<Map<String, String>> _chats = [
    {
      'name': 'Alice',
      'lastMessage': 'Hey! How are you?',
      'time': '10:30 AM',
      'imageUrl': 'https://randomuser.me/api/portraits/women/1.jpg',
    },
    {
      'name': 'Bob',
      'lastMessage': 'Got it, thanks!',
      'time': '9:45 AM',
      'imageUrl': 'https://randomuser.me/api/portraits/men/2.jpg',
    },
    {
      'name': 'Charlie',
      'lastMessage': 'Let\'s meet tomorrow.',
      'time': '8:15 AM',
      'imageUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Diana',
      'lastMessage': 'Sure! I\'ll be there.',
      'time': 'Yesterday',
      'imageUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Ethan',
      'lastMessage': 'Can you call me?',
      'time': 'Yesterday',
      'imageUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
    {
      'name': 'Fiona',
      'lastMessage': 'Thanks for the help!',
      'time': 'Mon',
      'imageUrl': 'https://randomuser.me/api/portraits/women/6.jpg',
    },
    {
      'name': 'George',
      'lastMessage': 'Let me check and get back.',
      'time': 'Sun',
      'imageUrl': 'https://randomuser.me/api/portraits/men/7.jpg',
    },
    {
      'name': 'Hannah',
      'lastMessage': 'Good night 🌙',
      'time': 'Sat',
      'imageUrl': 'https://randomuser.me/api/portraits/women/8.jpg',
    },
    {
      'name': 'Ivan',
      'lastMessage': 'Check your inbox.',
      'time': 'Fri',
      'imageUrl': 'https://randomuser.me/api/portraits/men/9.jpg',
    },
    {
      'name': 'Julia',
      'lastMessage': 'Awesome! 😊',
      'time': 'Thu',
      'imageUrl': 'https://randomuser.me/api/portraits/women/10.jpg',
    },
  ];

  String _searchQuery = '';

  List<Map<String, String>> get chats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats
        .where((chat) =>
        chat['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
