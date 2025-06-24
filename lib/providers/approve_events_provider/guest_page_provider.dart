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

  /// Add current user as a host to an existing event
  Future<void> addCurrentUserAsHost({required String existingEventId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _eventId = existingEventId;

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');
      if (userId == null || userId.isEmpty) {
        debugPrint('❌ backendUserId not found');
        return;
      }

      // Step 1: Fetch event to get current hosts
      final getUrl = Uri.parse('$baseUrl/api/post/event/$existingEventId');
      final getRes = await http.get(getUrl);

      if (getRes.statusCode != 200) {
        debugPrint('❌ Failed to fetch event: ${getRes.body}');
        return;
      }

      final eventData = jsonDecode(getRes.body)['data'];
      List<String> currentHosts = List<String>.from(eventData['eventDetails']['hostedBy']);

      if (!currentHosts.contains(userId)) {
        currentHosts.add(userId);

        // Step 2: Update hostedBy
        final putUrl = Uri.parse('$baseUrl/api/post/event/$existingEventId');
        final putRes = await http.put(
          putUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "eventDetails": {"hostedBy": currentHosts}
          }),
        );

        if (putRes.statusCode == 200) {
          debugPrint('✅ Host added successfully');
        } else {
          debugPrint('❌ Failed to update event: ${putRes.body}');
        }
      } else {
        debugPrint('ℹ️ User is already a host');
      }
    } catch (e) {
      debugPrint('🔥 Error adding host: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch host user info from GET /api/event/hosts/:eventId
  Future<void> fetchHostNames({required String eventId}) async {
    _eventId = eventId;
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/api/event/hosts/$eventId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];

        _hosts = data.map<Map<String, String>>((host) {
          return {
            'name': host['name'] ?? 'No Name',
            'email': host['email'] ?? 'No Email',
            'profile': host['profile'] ?? '',
          };
        }).toList();

        debugPrint("✅ Fetched ${_hosts.length} hosts");
      } else {
        debugPrint('❌ Failed to fetch host names: ${response.body}');
      }
    } catch (e) {
      debugPrint('🔥 Error fetching host names: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
