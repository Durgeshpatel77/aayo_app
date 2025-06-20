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
  final ScrollController _scrollController = ScrollController();
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

      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add comment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            "Comments",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _comments.length,
              separatorBuilder: (context, _) => Divider(color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final c = _comments[_comments.length - 1 - index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundImage: c.userProfile.isNotEmpty
                        ? NetworkImage(c.userProfile)
                        : const AssetImage('images/onbording/unkown.jpg')
                    as ImageProvider,
                  ),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${c.userName} ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: c.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    timeAgo(c.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    hintText: "Add a comment...",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _submit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

