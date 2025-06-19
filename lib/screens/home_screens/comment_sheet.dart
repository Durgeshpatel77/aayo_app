import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';

class CommentSheet extends StatefulWidget {
  final List<String> initialComments;
  final void Function(String) onAddComment;
  final String postId; // ✅ ADD THIS

  const CommentSheet({
    required this.initialComments,
    required this.onAddComment,
    required this.postId, // ✅ AND THIS
    super.key,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final userId =
        Provider.of<FetchEditUserProvider>(context, listen: false).userId;

    if (text.isEmpty || userId == null) return;

    try {
      await Provider.of<HomeProvider>(context, listen: false).addCommentToPost(
        postId: widget.postId,
        userId: userId,
        content: text,
      );

      setState(() {
        _comments.add(text);
        _controller.clear();
      });

      widget.onAddComment(text);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(_comments[index]),
                );
              },
            ),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              suffixIcon: IconButton(
                  icon: const Icon(Icons.send_outlined), onPressed: _submit),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
