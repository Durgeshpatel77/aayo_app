// lib/providers/setting_screens_providers/event_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/create_event_model.dart';

class EventCreationProvider with ChangeNotifier {
  final List<EventModel> _allEvents = [];
  Map<String, dynamic>? _lastApiResponse;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isFetchingEvents = false;

  List<EventModel> get allEvents => _allEvents;
  Map<String, dynamic>? get lastApiResponse => _lastApiResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isFetchingEvents => _isFetchingEvents;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingEvents(bool value) {
    _isFetchingEvents = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> createEvent({
    required String eventName,
    required DateTime startDate,
    required TimeOfDay startTime,
    required DateTime endDate,
    required TimeOfDay endTime,
    required String location,
    required String city,
    required double latitude,
    required double longitude,
    required String description,
    required String ticketType,
    required double? ticketPrice,
    File? pickedImage,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString("backendUserId");

      if (backendUserId == null || backendUserId.isEmpty) {
        _errorMessage = "User not logged in or backend user ID is missing.";
        return false;
      }

      final DateTime startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startTime.hour,
        startTime.minute,
      );
      final DateTime endDateTime = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        endTime.hour,
        endTime.minute,
      );

      final bool isFreeEvent = (ticketType == 'Free');
      final double? priceToSend = isFreeEvent ? 0.0 : ticketPrice;

      final uri = Uri.parse('http://srv861272.hstgr.cloud:8000/api/post/event');
      final request = http.MultipartRequest('POST', uri);

      request.fields['type'] = "event";
      request.fields['user'] = backendUserId;
      request.fields['title'] = eventName;
      request.fields['content'] = description;
      request.fields['startTime'] = startDateTime.toIso8601String();
      request.fields['endTime'] = endDateTime.toIso8601String();
      request.fields['location'] = location;
      request.fields['city'] = city;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      request.fields['description'] = description;
      request.fields['isFree'] = isFreeEvent.toString();
      request.fields['price'] = priceToSend.toString();

      if (pickedImage != null) {
        final image = await http.MultipartFile.fromPath(
          'media',
          pickedImage.path,
        );
        request.files.add(image);
      } else {
        debugPrint("No event image picked for creation.");
      }

      debugPrint("📤 Sending fields for event creation: ${request.fields}");
      debugPrint("📸 File count: ${request.files.length}");

      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();

      debugPrint("📥 Status Code: ${streamedResponse.statusCode}");
      debugPrint("📥 Raw Response Body: $respStr");

      if (respStr.isNotEmpty) {
        final decoded = json.decode(respStr);

        if (streamedResponse.statusCode == 201) {
          _lastApiResponse = decoded;
          await fetchUserPostsFromPrefs();
          return true;
        } else {
          _errorMessage = 'Server error: ${decoded['message'] ?? 'Unknown error'} - Status Code: ${streamedResponse.statusCode}';
          return false;
        }
      } else {
        _errorMessage = 'Empty response from server. Status Code: ${streamedResponse.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error during event creation: $e';
      print('Network Error: $_errorMessage');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserPostsFromPrefs({String? type}) async {
    _clearError();
    _setFetchingEvents(true);
    _allEvents.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("backendUserId");

      if (userId == null || userId.isEmpty) {
        _errorMessage = "User ID not found in SharedPreferences.";
        return;
      }

      String url = 'http://srv861272.hstgr.cloud:8000/api/post?user=$userId';
      if (type != null && type.isNotEmpty) {
        url += '&type=$type';
      }

      debugPrint("Fetching user posts: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint("Fetched User Posts Status Code: ${response.statusCode}");
      debugPrint("Fetched User Posts Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true &&
            decoded['data'] != null &&
            decoded['data']['posts'] != null) {
          final List<dynamic> postsJson = decoded['data']['posts'];
          _allEvents.addAll(postsJson.map((json) => EventModel.fromJson(json)).toList());
        } else {
          _errorMessage = "Failed to parse posts: ${decoded['message']}";
        }
      } else {
        _errorMessage = 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      _errorMessage = 'Network error during user post fetch: $e';
    } finally {
      _setFetchingEvents(false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocationSuggestions(String query) async {
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');

    final response = await http.get(uri, headers: {
      'User-Agent': 'Flutter App',
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      _errorMessage = 'Failed to fetch location suggestions: ${response.statusCode}';
      print('Failed to fetch location suggestions: ${response.statusCode}');
      return [];
    }
  }
}