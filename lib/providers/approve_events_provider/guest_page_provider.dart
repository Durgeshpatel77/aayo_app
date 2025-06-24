import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GuestProvider with ChangeNotifier {
  final String baseUrl = 'http://srv861272.hstgr.cloud:8000';

  List<Map<String, String>> _hosts = [];
  List<Map<String, String>> get hosts => _hosts;

  String? _eventId;
  String? get eventId => _eventId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Create an event by the current user and set them as host
  Future<void> createEventAndAddHost() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');
      final userName = prefs.getString('userName') ?? 'Anonymous';
      final userEmail = prefs.getString('userEmail') ?? '';

      if (userId == null || userId.isEmpty) {
        debugPrint('❌ backendUserId not found');
        return;
      }

      // --- Step 1: Create Event ---
      final createUrl = Uri.parse('$baseUrl/api/post/event');
      final response = await http.post(
        createUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "eventDetails": {
            "title": "My Event by $userName",
            "description": "Event created by $userName",
            "hostedBy": [userId],
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        _eventId = data['_id'];
        debugPrint('✅ Event created with ID $_eventId');

        // Update host list in UI
        _hosts = [
          {"name": userName, "email": userEmail}
        ];

        notifyListeners();
      } else {
        debugPrint('❌ Failed to create event: ${response.body}');
      }
    } catch (e) {
      debugPrint('🔥 Error in createEventAndAddHost: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add current user as a host to the event
  Future<void> addCurrentUserAsHost() async {
    if (_eventId == null) {
      debugPrint('❗ No event ID available');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');
      final userName = prefs.getString('userName') ?? 'Anonymous';
      final userEmail = prefs.getString('userEmail') ?? '';

      final url = Uri.parse('$baseUrl/api/post/event/$_eventId');
      final getRes = await http.get(url);

      if (getRes.statusCode != 200) {
        debugPrint('❌ Failed to fetch event: ${getRes.body}');
        return;
      }

      final eventData = jsonDecode(getRes.body)['data'];
      List<String> currentHosts = List<String>.from(eventData['eventDetails']['hostedBy']);

      if (!currentHosts.contains(userId)) {
        currentHosts.add(userId!);
        final putRes = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"hostedBy": currentHosts}),
        );

        if (putRes.statusCode == 200) {
          _hosts.add({'name': userName, 'email': userEmail});
          debugPrint('✅ Host added');
          notifyListeners();
        } else {
          debugPrint('❌ Failed to update event: ${putRes.body}');
        }
      } else {
        debugPrint('ℹ️ User already a host');
      }
    } catch (e) {
      debugPrint('🔥 Error in addCurrentUserAsHost: $e');
    }
  }
}
