import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FetchEditUserProvider with ChangeNotifier {
  String? _userId;
  Map<String, dynamic> _userData = {};
  final String _baseUrl = 'http://srv861272.hstgr.cloud:8000';

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
}
