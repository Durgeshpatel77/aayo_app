// lib/models/event_registration_model.dart
class EventRegistration {
  final String id; // joinedBy id
  final String name; // joinedBy name
  final String registrationId;
  final String eventId;
  String status;

  EventRegistration({
    required this.id,
    required this.name,
    required this.registrationId,
    required this.eventId,
    required this.status,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    final user = json['joinedBy'] ?? {};
    final event = json['event'] ?? {};

    return EventRegistration(
      id: user['_id'] ?? '',
      name: user['name'] ?? 'Unknown',
      registrationId: json['_id'] ?? '',
      eventId: event['_id'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

}