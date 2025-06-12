import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String peerUserId;
  final String peerName;
  final String chatId;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.peerUserId,
    required this.peerName,
    required this.chatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': widget.currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }
  Widget _buildMessage(Map<String, dynamic> msg) {
    bool isMe = msg['senderId'] == widget.currentUserId;

    Timestamp? timestamp = msg['timestamp'];
    String timeString = '';
    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      timeString = DateFormat.jm().format(dateTime); // Formats like "12:30 PM"
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.green[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(msg['text'] ?? '', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading messages"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    Timestamp? currentTimestamp = data['timestamp'];
                    DateTime? currentDate = currentTimestamp?.toDate();

                    DateTime? previousDate;
                    if (index + 1 < messages.length) {
                      final prevData = messages[index + 1].data() as Map<String, dynamic>;
                      Timestamp? prevTimestamp = prevData['timestamp'];
                      previousDate = prevTimestamp?.toDate();
                    }

                    bool showDateSeparator = false;
                    String dateString = '';
                    if (currentDate != null) {
                      if (previousDate == null ||
                          currentDate.year != previousDate.year ||
                          currentDate.month != previousDate.month ||
                          currentDate.day != previousDate.day) {
                        // Date changed or first message in the list
                        showDateSeparator = true;
                        dateString = DateFormat.yMMMMd().format(currentDate); // Example: May 29, 2025
                      }
                    }

                    return Column(
                      children: [
                        if (showDateSeparator)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dateString,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        _buildMessage(data),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child:
                  TextField(
                    controller: _controller,
                    minLines: 1, // Start with one line
                    maxLines: 6, // Expand up to 30 lines
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(width: 1.5, color: Colors.pink.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(width: 2.0, color: Colors.pink.shade700),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(width: 1.5, color: Colors.pink.shade400),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,  // send on double tap
                  child: CircleAvatar(
                    backgroundColor: Colors.green[700],
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
