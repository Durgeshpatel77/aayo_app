class NotificationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? profileImage;
  final String? type;
  final String? dataTitle;
  final String? postId;
  final String? dataImage; // ✅ Added for post/event image

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.profileImage,
    this.type,
    this.dataTitle,
    this.postId,
    this.dataImage,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      senderId: json['sender'] is Map ? (json['sender']['_id'] ?? '') : '',
      senderName: json['sender'] is Map ? (json['sender']['name'] ?? 'Unknown') : 'Unknown',
      receiverId: json['receiver'] is Map ? (json['receiver']['_id'] ?? '') : '',
      message: json['body'] ?? json['message'] ?? 'No message',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      profileImage: json['sender'] is Map ? json['sender']['profile'] : null,
      type: json['data']?['type'] ?? json['title']?.toLowerCase(),
      dataTitle: json['data']?['title'] ?? '',
      postId: json['data']?['postId'],
      dataImage: json['data']?['image'], // ✅ Capture post/event image
    );
  }
}
