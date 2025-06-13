// user_profile_provider.dart
import 'dart:convert';
import 'dart:io'; // For File operations
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// UserProvider manages user data, including fetching from and updating to backend.
/// It also provides local updates to user profile fields using `notifyListeners()`,
/// ensuring UI reflects changes immediately.
class UserProvider with ChangeNotifier {
  // Internal user data stored as a map
  Map<String, dynamic> _userData = {};

  // Public getter to access user data
  Map<String, dynamic> get userData => _userData;

  /// 🔄 Fetch user data from backend using stored MongoDB _id
  /// @param `firebaseUid`: The Firebase user ID (or other identifier) to find the backend ID.
  Future<void> fetchUser(String firebaseUid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // We expect 'backendUserId' (MongoDB _id) to be stored after Google sign-in.
      final userId = prefs.getString('backendUserId');

      if (userId == null || userId.isEmpty) {
        debugPrint('User ID not found in SharedPreferences, attempting to register...');
        // If backendUserId is not found, it means the user might be new or not fully registered.
        // In a real app, you'd likely register them here or ensure registration during GoogleSignIn.
        // For now, we'll throw an error as this provider expects the backend ID to exist.
        throw Exception('Backend user ID not found. Please ensure user is registered in backend.');
      }

      final url = Uri.parse('http://srv861272.hstgr.cloud:8000/api/user/$userId');
      debugPrint('📥 Fetching user with backend ID: $userId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _userData = result['data']; // Save fetched user data
        notifyListeners(); // Update UI
        debugPrint('✅ User fetched successfully: ${_userData['name']}');
      } else {
        debugPrint('❌ Failed to fetch user. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load user: ${response.statusCode}');
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
    String? profileImageUrl, // Add this for local profile image updates
  }) {
    if (name != null) _userData['name'] = name;
    if (email != null) _userData['email'] = email;
    if (mobile != null) _userData['mobile'] = mobile;
    if (about != null) _userData['about'] = about;
    if (gender != null) _userData['gender'] = gender;
    if (country != null) _userData['country'] = country;
    // Update 'profile' field for profile photo, assuming it's the primary field for photo
    if (profileImageUrl != null) _userData['profile'] = profileImageUrl;
    notifyListeners(); // Trigger UI update
    debugPrint('Local user data updated.');
  }

  /// 🖼️ Uploads a profile image to the server and returns its path.
  /// @param `imageFile`: The File object of the image to upload.
  /// @returns The URL/path of the uploaded image on the server, or null if upload fails.
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final uri = Uri.parse('http://srv861272.hstgr.cloud:8000/api/upload/profile');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath(
          'profileImage', // This must match the field name your backend expects (e.g., in Multer)
          imageFile.path,
          filename: imageFile.path.split('/').last));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final decoded = json.decode(responseBody);
        // Assuming your backend returns the new path/URL in 'profile' field
        debugPrint('✅ Image uploaded successfully. Path: ${decoded['profile']}');
        return decoded['profile']; // Adjust key based on your backend response
      } else {
        debugPrint('❌ Image upload failed: ${response.statusCode}, ${await response.stream.bytesToString()}');
        return null;
      }
    } catch (e) {
      debugPrint('⚠️ Error during image upload: $e');
      return null;
    }
  }

  /// 📤 Pushes updated user data to the backend server using PUT API
  /// This method now assumes `_userData` already contains the latest local changes,
  /// including any newly uploaded image path.
  Future<void> updateUserOnServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId'); // MongoDB _id from login

      if (userId == null || userId.isEmpty) {
        throw Exception('Backend user ID not found in SharedPreferences');
      }

      final url = Uri.parse('http://srv861272.hstgr.cloud:8000/api/user/$userId');
      debugPrint('📤 Updating user with backend ID: $userId');

      // Convert interests to comma-separated string if it's a list.
      // This is a common requirement for some backend setups.
      // Ensure 'interests' is handled correctly if it's part of the update data.
      if (_userData.containsKey('interests') && _userData['interests'] is List) {
        _userData['interests'] = (_userData['interests'] as List).join(',');
      }

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_userData), // Send the entire updated _userData map
      );

      if (response.statusCode == 200) {
        debugPrint('✅ User successfully updated on server.');
        final result = json.decode(response.body);
        // Update _userData with the server's response to ensure full sync
        _userData = result['data'];
        notifyListeners(); // Notify listeners to update UI with the new data
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