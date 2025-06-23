class CommentModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userName;
  final String userProfile;
  final String userId; // 👈 Add this line

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userName,
    required this.userProfile,
    required this.userId, // 👈 Add this
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return CommentModel(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      userName: user['name'] ?? 'Unknown',
      userProfile: user['profile'] != null
          ? 'http://srv861272.hstgr.cloud:8000/${user['profile']}'
          : '',
      userId: user['_id'] ?? '', // 👈 Parse userId
    );
  }
}
