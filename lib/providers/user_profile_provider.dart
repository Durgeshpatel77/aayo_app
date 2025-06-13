import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// UserProvider manages user data, including fetching from and updating to backend.
/// It also provides local updates to user profile fields using `notifyListeners()`.
class UserProvider with ChangeNotifier {
  // Internal user data stored as a map
  Map<String, dynamic> _userData = {};

  // Public getter to access user data
  Map<String, dynamic> get userData => _userData;

  /// 🔄 Fetch user data from backend using stored MongoDB _id
  Future<void> fetchUser(String s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId'); // MongoDB _id stored earlier

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final url = Uri.parse('http://srv861272.hstgr.cloud:8000/api/user/$userId');
      debugPrint('📥 Fetching user with ID: $userId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _userData = result['data']; // Save fetched user data
        notifyListeners(); // Update UI
      } else {
        debugPrint('❌ Failed to fetch user. Status: ${response.statusCode}');
        throw Exception('Failed to load user');
      }
    } catch (e) {
      debugPrint('⚠️ Exception in fetchUser: $e');
      rethrow;
    }
  }

  /// 📝 Update user data locally before sending to server.
  /// Useful when editing form fields and previewing UI changes.
  void updateUserLocal({
    String? name,
    String? email,
    String? mobile,
    String? about,
    String? gender,
    String? country,
  }) {
    if (name != null) _userData['name'] = name;
    if (email != null) _userData['email'] = email;
    if (mobile != null) _userData['mobile'] = mobile;
    if (about != null) _userData['profile'] = about;
    if (gender != null) _userData['gender'] = gender;
    if (country != null) _userData['country'] = country;
    notifyListeners(); // Trigger UI update
  }

  /// 📤 Push updated user data to the backend server using PUT API
  Future<void> updateUserOnServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId'); // MongoDB _id from login

      if (userId == null || userId.isEmpty) {
        throw Exception('Backend user ID not found in SharedPreferences');
      }

      final url = Uri.parse('http://srv861272.hstgr.cloud:8000/api/user/$userId');
      debugPrint('📤 Updating user with ID: $userId');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_userData), // Send updated user map as JSON
      );

      if (response.statusCode == 200) {
        debugPrint('✅ User successfully updated on server.');
      } else {
        debugPrint('❌ Update failed: ${response.statusCode}, ${response.body}');
        throw Exception('Failed to update user on server');
      }
    } catch (e) {
      debugPrint('⚠️ Exception in updateUserOnServer: $e');
      rethrow;
    }
  }
}
