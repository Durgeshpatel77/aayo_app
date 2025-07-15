class NotificationModel {
  final String id;
  final String user;
  final String receiverId;
  final String message;
  final String? profileImage; // 👈 Add this
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.user,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.profileImage,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final userField = json['user'];
    final receiverField = json['receiver'];

    return NotificationModel(
      id: json['_id'] ?? '',
      user: userField is Map<String, dynamic>
          ? userField['name'] ?? 'Unknown'
          : userField?.toString() ?? 'Unknown',
      receiverId: receiverField is Map<String, dynamic>
          ? receiverField['_id'] ?? ''
          : receiverField?.toString() ?? '',
      profileImage: userField is Map<String, dynamic> ? userField['profile'] : null, // 👈 Extract profile
      message: json['message'] ?? json['body'] ?? 'No message',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
