class Event {
  final String id;
  final String title;
  final String content;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final bool isFree;
  final double price;
  final List<String> likes;
  final List<String> comments;
  final String image;
  final List<String> media; // ✅ Add this line

  Event({
    required this.id,
    required this.title,
    required this.content,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.isFree,
    required this.price,
    required this.likes,
    required this.comments,
    required this.image,
    this.media = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventDetails = json['eventDetails'] ?? {};

    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      location: eventDetails['location'] ?? '',
      startTime: DateTime.tryParse(eventDetails['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(eventDetails['endTime'] ?? '') ?? DateTime.now(),
      isFree: eventDetails['isFree'] ?? true,
      price: (eventDetails['price'] ?? 0).toDouble(),
      likes: (json['likes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      image: json['image'] ?? '',
      media: (json['media'] as List<dynamic>?)
          ?.map((e) {
        if (e is String) return e;
        if (e is Map && e['url'] != null) return e['url'].toString();
        return '';
      })
          .where((url) => url.isNotEmpty)
          .toList() ?? [],
    );
  }
}
