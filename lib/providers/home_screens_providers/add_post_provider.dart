import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostProvider with ChangeNotifier {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  static const String _apiBaseUrl = 'http://srv861272.hstgr.cloud:8000';

  TextEditingController get postController => _postController;
  TextEditingController get titleController => _titleController;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;

  bool get isPostEnabled =>
      (_postController.text.trim().isNotEmpty ||
          _titleController.text.trim().isNotEmpty ||
          _selectedImage != null) &&
          !_isLoading;

  /// ✅ 1. PICK & CROP IMAGE
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            hideBottomControls: true,
            showCropGrid: true, // ✅ Show grid
            cropGridStrokeWidth: 2, // ✅ Make lines thicker
            cropFrameStrokeWidth: 2,
          ),
          IOSUiSettings(
            title: 'Edit & Crop',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      _selectedImage = File(croppedFile.path);
      notifyListeners();
    } catch (e) {
      debugPrint('🛑 Error in pickImage: $e');
      // Optional: UI feedback
    }
  }

  /// ✅ 2. CLEAR SELECTED IMAGE
  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  /// ✅ 3. CLEAR POST INPUTS
  void clearPost() {
    _postController.clear();
    _titleController.clear();
    _selectedImage = null;
    notifyListeners();
  }

  /// ✅ 4. CREATE POST
  Future<String?> createPost() async {
    if (!isPostEnabled) {
      return "Please add a title or content, or select an image to post.";
    }

    _isLoading = true;
    notifyListeners();

    String? errorMessage;

    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString('backendUserId');

      if (backendUserId == null || backendUserId.isEmpty) {
        return 'User not logged in. Cannot create post.';
      }

      const String apiUrl = '$_apiBaseUrl/api/post';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['user'] = backendUserId;
      request.fields['title'] = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'New Post';
      request.fields['content'] = _postController.text.trim();

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        ));
      }

      var response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        clearPost();
        errorMessage = null;
      } else {
        final error = json.decode(responseBody.body);
        errorMessage =
        'Failed to share post: ${error['message'] ?? response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return errorMessage;
  }

  /// ✅ 5. FETCH POSTS FOR LOGGED-IN USER
  Future<List<String>> fetchMyPostImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');

      if (userId == null) throw Exception('User not logged in');

      final url = Uri.parse('$_apiBaseUrl/api/post?type=post');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        final posts = jsonBody['data']['posts'] as List<dynamic>;

        return posts
            .where((post) => post['user']?['_id'] == userId)
            .map<String>((post) {
          final media = post['media'];
          if (media is List && media.isNotEmpty) {
            return '$_apiBaseUrl/${media[0]}';
          }
          return '';
        })
            .where((url) => url.isNotEmpty)
            .toList();
      } else {
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching post images: $e');
      rethrow;
    }
  }

  /// ✅ 6. FETCH POSTS FOR SPECIFIC USER
  Future<List<String>> fetchUserPostImages(String userId) async {
    try {
      final url = '$_apiBaseUrl/api/post?type=post&user=$userId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> posts = jsonResponse['data']['posts'];

        return posts
            .map<String>((post) {
          final media = post['media'];
          if (media is List && media.isNotEmpty) {
            return '$_apiBaseUrl/${media[0]}';
          }
          return '';
        })
            .where((url) => url.isNotEmpty)
            .toList();
      } else {
        throw Exception('❌ Failed to fetch user posts: ${response.body}');
      }
    } catch (e, stack) {
      debugPrint('🛑 fetchUserPostImages error: $e');
      debugPrint('📍 Stack trace:\n$stack');
      rethrow;
    }
  }

  /// ✅ CLEAN UP
  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
