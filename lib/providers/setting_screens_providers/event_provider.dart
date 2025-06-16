import 'dart:convert';
import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart'; // For location suggestions
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/create_event_model.dart'; // Ensure this path is correct

class EventCreationProvider with ChangeNotifier {
  final List<EventModel> _createdEvents = [];
  Map<String, dynamic>? _lastApiResponse;
  String? _errorMessage;
  bool _isLoading = false;

  List<EventModel> get createdEvents => _createdEvents;
  Map<String, dynamic>? get lastApiResponse => _lastApiResponse;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method to handle API call for creating an event with media upload
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
    File? pickedImage, // This will now be used for upload
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

      // Combine Date and Time
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

      // Use MultipartRequest for file upload
      final uri = Uri.parse('http://srv861272.hstgr.cloud:8000/api/post/event'); // Your API endpoint
      final request = http.MultipartRequest('POST', uri);

      // Add text fields
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

      // Add image file if available
      if (pickedImage != null) {
        final image = await http.MultipartFile.fromPath(
          'media', // This must match the backend's expected field name for the file
          pickedImage.path,
        );
        request.files.add(image);
      } else {
        debugPrint("No event image picked.");
      }

      debugPrint("📤 Sending fields: ${request.fields}");
      debugPrint("📸 File count: ${request.files.length}");

      final streamedResponse = await request.send();
      final respStr = await streamedResponse.stream.bytesToString();

      debugPrint("📥 Status Code: ${streamedResponse.statusCode}");
      debugPrint("📥 Raw Response Body: $respStr");

      if (respStr.isNotEmpty) {
        final decoded = json.decode(respStr);
        debugPrint("📦 Decoded Response JSON: $decoded");

        if (streamedResponse.statusCode == 201) {
          _lastApiResponse = decoded;
          addEvent(EventModel(
            name: eventName,
            startDate: startDate,
            startTime: startTime,
            endDate: endDate,
            endTime: endTime,
            location: location,
            description: description,
            ticketType: ticketType,
            ticketPrice: ticketPrice?.toString(),
            image: pickedImage,
          ));
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
      _errorMessage = 'Network error: $e';
      print('Network Error: $_errorMessage');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Method to add event to local list (called after successful API creation)
  void addEvent(EventModel event) {
    _createdEvents.add(event);
    notifyListeners();
  }

  // Moved location suggestion fetching here
  Future<List<Map<String, dynamic>>> fetchLocationSuggestions(String query) async {
    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');

    final response = await http.get(uri, headers: {
      'User-Agent': 'Flutter App', // Required for Nominatim
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