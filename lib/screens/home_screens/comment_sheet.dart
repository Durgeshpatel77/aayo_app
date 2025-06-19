import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/comment_model.dart';
import '../../providers/home_screens_providers/home_provider.dart';
import '../../providers/onording_login_screens_providers/user_profile_provider.dart';
import '../other_for_use/utils.dart';

class CommentSheet extends StatefulWidget {
  final List<CommentModel> initialComments;
  final void Function(String) onAddComment;
  final String postId;

  const CommentSheet({
    required this.initialComments,
    required this.onAddComment,
    required this.postId,
    super.key,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userProvider =
    Provider.of<FetchEditUserProvider>(context, listen: false);
    final userId = userProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login required to comment.")),
      );
      return;
    }

    try {
      final commentJson =
      await Provider.of<HomeProvider>(context, listen: false)
          .addCommentToPost(
        postId: widget.postId,
        userId: userId,
        content: text,
      );

      final newComment = CommentModel.fromJson(commentJson);

      setState(() {
        _comments.add(newComment);
        _controller.clear();
      });

      widget.onAddComment(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add comment: $e")),
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
            height: 300,
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final c = _comments[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: c.userProfile.isNotEmpty
                        ? NetworkImage(c.userProfile)
                        : const AssetImage('images/onbording/unkown.jpg')
                    as ImageProvider,
                  ),
                  title: Text(c.userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.content),
                      Text(
                        timeAgo(c.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
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
