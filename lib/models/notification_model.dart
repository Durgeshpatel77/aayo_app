class NotificationModel {
  final String id;
  final String user;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? profileImage;
  final String? type;
  final String? userName;
  final String? postTitle;

  NotificationModel({
    required this.id,
    required this.user,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.profileImage,
    this.type,
    this.userName,
    this.postTitle,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      user: json['user'] is Map
          ? json['user']['name'] ?? 'Unknown'
          : (json['user'] ?? 'Unknown'),
      receiverId: json['receiver'] ?? '',
      message: json['message'] ?? json['body'] ?? 'No message',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      profileImage: json['user'] is Map ? json['user']['profile'] : null,
      type: json['data']?['type'] ?? null,
      userName: json['data']?['userName'] ?? null,
      postTitle: json['data']?['postTitle'] ?? null,
    );
  }
}
