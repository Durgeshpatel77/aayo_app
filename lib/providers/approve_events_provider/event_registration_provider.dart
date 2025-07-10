// lib/providers/event_registration_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/event_registration_model.dart';

class EventRegistrationProvider extends ChangeNotifier {
  final String _baseUrl = 'http://82.29.167.118:8000/api/event';
  List<EventRegistration> _registrations = [];
  bool _isLoading = false;

  List<EventRegistration> get registrations => _registrations;
  bool get isLoading => _isLoading;

  Future<void> fetchRegistrations(String eventId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = Uri.parse('$_baseUrl/dashboard/$eventId');
      final response = await http.get(url);
      final data = jsonDecode(response.body)['data'];

      _registrations = (data['registrations'] as List)
          .map((e) => EventRegistration.fromJson(e))
          .toList();
    } catch (e) {
      _registrations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus({
    required String eventId,
    required String joinedBy,
    required String registrationId,
    required String newStatus,
  }) async {
    final url = Uri.parse('$_baseUrl/update-status/$eventId');
    final body = {
      'joinedBy': joinedBy,
      'eventRegId': registrationId,
      'status': newStatus,
    };

    try {
      final res = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📡 Status update response: ${res.statusCode}');
      debugPrint('🔁 Response body: ${res.body}');

      if (res.statusCode == 200) {
        await fetchRegistrations(eventId);
        return true;
      }
    } catch (e, st) {
      debugPrint('❌ Update failed: $e');
      debugPrint('📍 Stack trace: $st');
    }

    return false;
  }
}