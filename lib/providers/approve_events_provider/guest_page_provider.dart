import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../../models/event_registration_model.dart';

class GuestProvider with ChangeNotifier {
  final String baseUrl = 'http://srv861272.hstgr.cloud:8000';

  List<Map<String, String>> _hosts = [];
  List<Map<String, String>> get hosts => _hosts;

  String? _eventId;
  String? get eventId => _eventId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<EventRegistration> _registrations = [];
  List<EventRegistration> get registrations => _registrations;


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
      // ✅ Corrected fetch event (to get creator)
      final eventUrl = Uri.parse('$baseUrl/api/post/$eventId');
      final eventRes = await http.get(eventUrl);
      if (eventRes.statusCode != 200) {
        debugPrint('❌ Failed to fetch event: ${eventRes.body}');
        return;
      }

      final eventData = jsonDecode(eventRes.body)['data'];
      final creator = eventData['user'];
      final creatorMap = {
        'id': (creator['_id'] ?? '').toString(),
        'name': (creator['name'] ?? 'Creator').toString(),
        'email': (creator['email'] ?? '').toString(),
        'profile': (creator['profile'] ?? '').toString(),
      };

      // Fetch existing hosts
      final hostUrl = Uri.parse('$baseUrl/api/event/hosts/$eventId');
      final hostRes = await http.get(hostUrl);

      List<Map<String, String>> loadedHosts = [];
      if (hostRes.statusCode == 200) {
        final List<dynamic> hostData = jsonDecode(hostRes.body)['data'];
        loadedHosts = hostData.map<Map<String, String>>((host) {
          return {
            'id': (host['_id'] ?? '').toString(),
            'name': (host['name'] ?? 'No Name').toString(),
            'email': (host['email'] ?? 'No Email').toString(),
            'profile': (host['profile'] ?? '').toString(),
          };
        }).toList();
      }

      // Add creator if not already present
      final alreadyAdded = loadedHosts.any((host) => host['id'] == creatorMap['id']);
      if (!alreadyAdded) {
        loadedHosts.insert(0, creatorMap);
      }

      _hosts = loadedHosts;
      debugPrint("✅ Fetched ${_hosts.length} hosts (including creator)");
    } catch (e) {
      debugPrint('🔥 Error fetching host names: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEventRegistrations(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = 'http://srv861272.hstgr.cloud:8000/api/event/dashboard/$eventId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final registrationsJson = body['data']['registrations'] ?? [];

        _registrations = registrationsJson
            .map<EventRegistration>((e) => EventRegistration.fromJson(e))
            .toList();

        // (Optional) You can also store counts if needed:
        final counts = body['data']['counts'];
        debugPrint('🧮 Registration counts: $counts');

      } else {
        _registrations = [];
        debugPrint('❌ Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _registrations = [];
      debugPrint('❌ Exception during fetchEventRegistrations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

}
