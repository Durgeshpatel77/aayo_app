import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostProvider with ChangeNotifier {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // NEW: Title Controller
  File? _selectedImage;
  bool _isLoading = false;
  static const String _apiBaseUrl = 'http://srv861272.hstgr.cloud:8000'; // Your API base URL

  // Getters for UI to access state
  TextEditingController get postController => _postController;
  TextEditingController get titleController => _titleController; // NEW: Getter for title
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;

  // Derived state to enable/disable post button
  bool get isPostEnabled =>
      (_postController.text.trim().isNotEmpty ||
          _titleController.text.trim().isNotEmpty || // NEW: Check title too
          _selectedImage != null) &&
          !_isLoading;

  // Method to pick image
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
    } else {
      _selectedImage = null; // Clear if no image was picked
    }
    notifyListeners(); // Notify UI to rebuild
  }

  // Method to clear selected image
  void clearImage() {
    _selectedImage = null;
    notifyListeners(); // Notify UI to rebuild
  }

  // Method to clear post content and image after successful post
  void clearPost() {
    _postController.clear();
    _titleController.clear(); // NEW: Clear title as well
    _selectedImage = null;
    notifyListeners();
  }

  // Logic for creating the post API call
  Future<String?> createPost() async {
    if (!isPostEnabled) {
      return "Please add a title or content, or select an image to post."; // Updated message
    }

    _isLoading = true;
    notifyListeners(); // Notify UI to show loading indicator

    String? errorMessage;

    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString('backendUserId');

      if (backendUserId == null || backendUserId.isEmpty) {
        errorMessage = 'User not logged in. Cannot create post.';
        return errorMessage;
      }

      const String apiUrl = '$_apiBaseUrl/api/post';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['user'] = backendUserId;
      // Use the actual title from the controller, fall back if empty
      request.fields['title'] = _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'New Post';
      request.fields['content'] = _postController.text.trim();

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'media', // This MUST match the field name your backend expects for files
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        ));
      }

      debugPrint('Sending post request to: $apiUrl');
      debugPrint('Request fields: ${request.fields}');
      if (_selectedImage != null) {
        debugPrint('Image file attached: ${_selectedImage!.path}');
      }

      var response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      debugPrint('Post API response status: ${responseBody.statusCode}');
      debugPrint('Post API response body: ${responseBody.body}');

      if (response.statusCode == 201) {
        clearPost(); // Clear post data on success
        errorMessage = null; // Indicate success
      } else {
        final error = json.decode(responseBody.body);
        errorMessage = 'Failed to share post: ${error['message'] ?? response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Always notify to update loading state
    }
    return errorMessage; // Return null on success, error message on failure
  }

  @override
  void dispose() {
    _postController.dispose();
    _titleController.dispose(); // NEW: Dispose title controller
    super.dispose();
  }
}