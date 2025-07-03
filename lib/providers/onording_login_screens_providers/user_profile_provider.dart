import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FetchEditUserProvider with ChangeNotifier {
  String? _userId;
  Map<String, dynamic> _userData = {};
  final String _baseUrl = 'http://srv861272.hstgr.cloud:8000';
  List<dynamic> _currentUserFollowing = [];
  List<dynamic> get currentUserFollowing => _currentUserFollowing;

  // -------------------- Getters --------------------
  String? get userId => _userId;
  Map<String, dynamic> get userData => _userData;

  String? get name => _userData['name'];
  String? get email => _userData['email'];
  String? get userName => _userData['name'];

  String? get profileImageUrl {
    final path = _userData['profile'] ?? '';
    if (path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$_baseUrl/$path';
  }

  String? get profileImage {
    final path = _userData['profile'] ?? '';
    if (path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '$_baseUrl/$path';
  }

  // -------------------- User ID Storage --------------------
  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('backendUserName', _userData['name'] ?? '');
    _userId = prefs.getString('backendUserId');
    debugPrint('📦 Loaded User ID: $_userId');
    notifyListeners();
  }

  void setUserId(String id) {
    _userId = id;
    _saveUserId(id);
    notifyListeners();
  }

  Future<void> _saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backendUserId', id);
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backendUserId');

    // ❌ Do NOT delete FCM token here
    // await FirebaseMessaging.instance.deleteToken(); ❌ Remove this

    _userId = null;
    _userData = {};
    notifyListeners();
  }

  // -------------------- Fetch Current User --------------------
  Future<void> fetchUser(String firebaseUid) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('backendUserId');
    if (id == null) throw Exception('No backend user ID found');

    final res = await http.get(Uri.parse('$_baseUrl/api/user/$id'));
    if (res.statusCode == 200) {
      final result = json.decode(res.body);
      _userData = result['data'];
      notifyListeners();
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  // -------------------- Fetch User by ID (for profile views) --------------------
  Future<Map<String, dynamic>> fetchUserById(String userId) async {
    final url = Uri.parse('$_baseUrl/api/user/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      return result['data'];
    } else {
      throw Exception('Failed to fetch user by ID');
    }
  }

  // -------------------- Local Update --------------------
  void updateUserLocal({
    String? name,
    String? email,
    String? mobile,
    String? about,
    String? gender,
    String? country,
    String? profileImageUrl,
  }) {
    if (name != null) _userData['name'] = name;
    if (email != null) _userData['email'] = email;
    if (mobile != null) _userData['mobile'] = mobile;
    if (about != null) _userData['about'] = about;
    if (gender != null) _userData['gender'] = gender;
    if (country != null) _userData['country'] = country;
    if (profileImageUrl != null) _userData['profile'] = profileImageUrl;
    notifyListeners();
  }

  // -------------------- Upload Image --------------------
  Future<String?> uploadProfileImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('backendUserId');
    if (userId == null) return null;

    final uri = Uri.parse('$_baseUrl/api/user/$userId');

    final request = http.MultipartRequest('PUT', uri);
    request.files.add(await http.MultipartFile.fromPath(
      'profile',
      imageFile.path,
    ));

    final res = await request.send();

    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      final decoded = jsonDecode(body);
      return decoded['data']['profile'];
    } else {
      return null;
    }
  }

  // -------------------- Push Data to Server --------------------
  Future<void> updateUserOnServer() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('backendUserId');
    if (userId == null) throw Exception('No backend user ID');

    final url = Uri.parse('$_baseUrl/api/user/$userId');

    // Convert interests list to string if needed
    if (_userData.containsKey('interests') && _userData['interests'] is List) {
      _userData['interests'] = (_userData['interests'] as List).join(',');
    }

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(_userData),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      _userData = result['data'];
      notifyListeners();
    } else {
      throw Exception('Failed to update user');
    }
  }

  //-------------------- fetch followers ----------------------
  Future<Map<String, dynamic>> toggleFollow(String targetUserId) async {

    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString('backendUserId');

      if (backendUserId == null) {
        debugPrint('❌ backendUserId not found in SharedPreferences');
        throw Exception('backendUserId not found in SharedPreferences');
      }
      final url = Uri.parse('$_baseUrl/api/user/follow/$backendUserId');
      final body = {'followingId': targetUserId};

      debugPrint('📤 Sending POST to: $url');
      debugPrint('🧾 Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        /// ❗ Backend bug workaround: swap values
        final backendIncorrectFollowers = decoded['data']['followers']; // actually 'following'
        final backendIncorrectFollowing = decoded['data']['following']; // actually 'followers'

        // Save correct values manually
        final correctedFollowers = backendIncorrectFollowing ?? []; // who follows target user
        final correctedFollowing = backendIncorrectFollowers ?? []; // whom current user follows

        _currentUserFollowing = List.from(correctedFollowing); // your updated following list
        notifyListeners();

        return {
          'success': true,
          'message': decoded['message'],
          'targetFollowers': correctedFollowers,
          'currentFollowing': _currentUserFollowing,
        };
      } else {
        debugPrint('❌ Follow request failed: ${decoded['message']}');
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to follow/unfollow',
        };
      }
    } on FormatException catch (e) {
      debugPrint('❌ JSON decode error: $e');
      return {
        'success': false,
        'message': 'Invalid server response format: $e',
      };
    } catch (e) {
      debugPrint('❌ toggleFollow() exception: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // -------------------- Like Toggle --------------------
  Future<Map<String, dynamic>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/post/like/$postId');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': userId}),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return {
          'success': true,
          'likes': List<String>.from(decoded['data']['likes'] ?? []),
          'message': decoded['message'],
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to toggle like',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
  //---------------------------- FCM token update -----------------
  Future<void> updateFcmToken(String newToken) async  {
    debugPrint('🚀 Starting FCM token update...');

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('backendUserId');
    debugPrint('🔍 Loaded backendUserId from SharedPreferences: $userId');

    if (userId == null) {
      debugPrint('❗ No backendUserId found, aborting FCM update.');
      return;
    }

    final savedToken = prefs.getString('savedFcmToken');
    if (savedToken == newToken) {
      debugPrint('⚠️ FCM token unchanged. Skipping update.');
      return;
    }

    final url = Uri.parse('$_baseUrl/api/user/$userId');
    final body = jsonEncode({'fcmToken': newToken});
    debugPrint('📡 Sending PUT request to: $url');
    debugPrint('🧾 Request Body: $body');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      debugPrint('📥 Response Status Code: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        await prefs.setString('savedFcmToken', newToken); // ✅ Save token
        final result = json.decode(response.body);
        _userData = result['data'];
        notifyListeners();
        debugPrint('✅ FCM token updated successfully on server.');
      } else {
        debugPrint('❌ Failed to update FCM token. Server returned error.');
      }
    } catch (e) {
      debugPrint('💥 Exception occurred during FCM token update: $e');
    }
  }

  //----------------------------send follow notification --------------------
  Future<void> sendFollowNotification({
    required String toUserFcmToken,
    required String fromUserName,
  }) async {
    if (toUserFcmToken.trim().isEmpty ||
        !toUserFcmToken.contains(':') ||
        toUserFcmToken.length < 30) {
      debugPrint('❌ Invalid FCM token — skipping notification.');
      return;
    }

    debugPrint('📛 Valid token used: $toUserFcmToken');

    const url = 'http://srv861272.hstgr.cloud:8000/api/send-notification';
    final body = {
      'title': 'New Follower',
      'body': '$fromUserName started following you!',
      'fcmToken': toUserFcmToken,
    };

    try {
      debugPrint('📤 Sending follow notification...');
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('✅ Follow notification response: ${res.statusCode}');
      debugPrint('📥 Response: ${res.body}');
    } catch (e) {
      debugPrint('❌ Error sending follow notification: $e');
    }
  }

}