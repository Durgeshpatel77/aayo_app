// lib/providers/user_profile_provider.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  String? _userId;
  final String baseUrl = 'http://srv861272.hstgr.cloud:8000/api'; // Your base API URL

  String? get userId => _userId;

  // Loads user ID from SharedPreferences when the app starts
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('backendUserId');
    debugPrint('UserProfileProvider: Loaded User ID: $_userId'); // Debugging print
    notifyListeners(); // Notify listeners (e.g., HomeScreen) that userId might have changed
  }

  // Sets user ID and immediately saves it to SharedPreferences
  void setUserId(String id) {
    _userId = id;
    debugPrint('UserProfileProvider: Set User ID: $_userId'); // Debugging print
    notifyListeners();
    _saveUserId(id); // Save the ID to persistent storage
  }

  // Private method to save user ID to SharedPreferences
  Future<void> _saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backendUserId', id);
    debugPrint('UserProfileProvider: Saved User ID to SharedPreferences: $id'); // Debugging print
  }

  // Clears user ID from SharedPreferences (e.g., on logout)
  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backendUserId');
    _userId = null;
    debugPrint('UserProfileProvider: Cleared User ID'); // Debugging print
    notifyListeners();
  }

  // This function sends a POST request to toggle the like status.
  // It requires both postId and userId as parameters, matching your backend.
  Future<Map<String, dynamic>> toggleLike({
    required String postId,
    required String userId, // This parameter is required based on your provided code
  }) async {
    final String url = '$baseUrl/post/like/$postId';
    debugPrint('UserProfileProvider: Toggling like for Post ID: $postId by User ID: $userId');
    debugPrint('UserProfileProvider: Request URL: $url');
    debugPrint('UserProfileProvider: Request Body: {"user": "$userId"}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user': userId,
        }),
      );

      debugPrint('UserProfileProvider: Response Status: ${response.statusCode}');
      debugPrint('UserProfileProvider: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<String> updatedLikes = List<String>.from(responseData['data']['likes'] ?? []);
          return {
            'success': true,
            'message': responseData['message'],
            'likes': updatedLikes, // Return the new list of likes
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to toggle like.',
          };
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('UserProfileProvider: Error toggling like: $e');
      return {
        'success': false,
        'message': 'Network error: Unable to connect to server.',
      };
    }
  }
}