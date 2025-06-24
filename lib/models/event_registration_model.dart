// lib/models/event_registration_model.dart
class EventRegistration {
  final String id;
  final String name;

  EventRegistration({
    required this.id,
    required this.name,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    final user = json['joinedBy'] ?? {};
    return EventRegistration(
      id: user['_id'] ?? '',
      name: user['name'] ?? 'Unknown',
    );
  }
}
