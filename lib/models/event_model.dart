import 'comment_model.dart';

class Event {
  final String id;
  final String title;
  final String content;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isFree;
  final String organizerId;
  final double price;
  final List<String> likes;
  final List<CommentModel> comments;
  final String image;
  final List<String> media;
  final String organizer;
  final String organizerProfile;
  final DateTime createdAt;
  final String type;

  // ✅ NEW
  final double latitude;
  final double longitude;

  Event({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isFree,
    required this.organizerId,
    required this.price,
    required this.likes,
    required this.comments,
    required this.image,
    this.media = const [],
    this.organizer = '',
    this.organizerProfile = '',
    required this.createdAt,
    required this.type,
    required this.latitude, // ✅ NEW
    required this.longitude, // ✅ NEW
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventDetails = json['eventDetails'] ?? {};
    final user = json['user'] ?? {};
    final String parsedType = json['type'] ?? 'post';

    const String baseUrl = 'http://srv861272.hstgr.cloud:8000';

    String formatUrl(String? path) {
      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http')) return path;
      return path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';
    }

    final userProfilePath = user['profile'] ?? '';
    final fullOrganizerProfileUrl = userProfilePath.isNotEmpty
        ? formatUrl(userProfilePath)
        : 'https://randomuser.me/api/portraits/men/75.jpg';

    List<String> parsedMedia = [];
    if (json['media'] is List) {
      parsedMedia = (json['media'] as List<dynamic>)
          .map((e) {
        if (e is String) return formatUrl(e);
        if (e is Map && e['url'] is String) return formatUrl(e['url']);
        return '';
      })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    final commentsJson = json['comments'] as List<dynamic>? ?? [];

    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      location: eventDetails['location'] ?? '',
      startTime: DateTime.tryParse(eventDetails['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(eventDetails['endTime'] ?? '') ?? DateTime.now(),
      isFree: eventDetails['isFree'] ?? true,
      organizerId: user['_id'] as String? ?? '',
      price: (eventDetails['price'] ?? 0).toDouble(),
      likes: (json['likes'] as List<dynamic>?)
          ?.map((e) => e is Map && e['_id'] is String ? e['_id'] as String : null)
          .whereType<String>()
          .toList() ??
          [],
      comments: commentsJson.map((c) => CommentModel.fromJson(c)).toList(),
      image: formatUrl(json['image']),
      media: parsedMedia,
      organizer: user['name'] ?? 'Unknown User',
      organizerProfile: fullOrganizerProfileUrl,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      type: parsedType,
      latitude: (eventDetails['latitude'] ?? 0.0).toDouble(), // ✅
      longitude: (eventDetails['longitude'] ?? 0.0).toDouble(), // ✅
    );
  }

  bool get isEvent => type == 'event';
  bool get isPost => type == 'post';
}
