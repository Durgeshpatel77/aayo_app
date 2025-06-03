import 'package:flutter/material.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final List<Map<String, String>> chats = [
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

  List<Map<String, String>> filteredChats = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredChats = chats;
    searchController.addListener(() {
      _filterChats(searchController.text);
    });
  }

  void _filterChats(String query) {
    final results = chats.where((chat) {
      final name = chat['name']!.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredChats = results;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
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
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink.shade400, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink.shade400, width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink.shade400, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.pink.shade400, width: 1),
                ),
              ),
            ),
            ),
          // Chat List
          Expanded(
            child: ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(chat['imageUrl']!),
                  ),
                  title: Text(
                    chat['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat['lastMessage']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    chat['time']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    // Navigate to ChatDetailPage or show message
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
