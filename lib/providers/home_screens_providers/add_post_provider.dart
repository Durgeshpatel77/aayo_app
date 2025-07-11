import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/event_model.dart';

class AddPostProvider with ChangeNotifier {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  List<String> _selectedCategories = [];
  List<String> get selectedCategories => _selectedCategories;
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;


  void selectCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      if (_selectedCategories.length < 3) {
        _selectedCategories.add(category);
      }
    }
    notifyListeners();
  }
  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  static const String _apiBaseUrl = 'http://82.29.167.118:8000';

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
        compressQuality: 70,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            hideBottomControls: true,
            showCropGrid: true,
            cropGridStrokeWidth: 2,
            cropFrameStrokeWidth: 2,
          ),
          IOSUiSettings(
            title: 'Edit & Crop',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
          ),
        ],
      );

      if (croppedFile == null) return;

      // ✅ Log original size
      final originalSize = File(croppedFile.path).lengthSync();
      debugPrint('📸 Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');

      // ✅ Compress the image using flutter_image_compress
      final compressedImage = await FlutterImageCompress.compressAndGetFile(
        croppedFile.path,
        '${croppedFile.path}_compressed.jpg',
        quality: 50, // Adjust for size vs. quality
      );

      if (compressedImage == null) return;

      // ✅ Log compressed size
      final compressedSize = File(compressedImage.path).lengthSync();
      debugPrint('🗜️ Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');

      _selectedImage = File(compressedImage.path);
      notifyListeners();
    } catch (e) {
      debugPrint('🛑 Error in pickImage: $e');
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
    _selectedCategories.clear(); // <-- clear selected tags here
    _selectedImage = null;
    notifyListeners();
  }

  /// ✅ 4. CREATE POST
  Future<String?> createPost(BuildContext context) async {
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
      request.fields['tags'] = _selectedCategories.join(','); // ✅ Add this line

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
        final responseData = json.decode(responseBody.body);
        final mediaList = responseData['data']['media'] as List?;
        final title = responseData['data']['title'] ?? 'New Post';

        if (mediaList != null && mediaList.isNotEmpty) {
          final imageUrl = '$_apiBaseUrl/${mediaList[0]}';

          final prefs = await SharedPreferences.getInstance();
          final senderName =
              prefs.getString('backendUserName') ?? 'Someone';

          await sendPostNotificationToFollowers(
            context: context,
            postImageUrl: imageUrl,
            postTitle: title,
            senderName: senderName,
          );

        }

        clearPost();
        errorMessage = null;
      }
      else {
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
  Future<List<Event>> fetchMyPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');

      if (userId == null) throw Exception('User not logged in');

      final url = Uri.parse('$_apiBaseUrl/api/post?type=post');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = data['data']['posts'] as List;

        return posts
            .where((post) => post['user']?['_id'] == userId)
            .map((postJson) => Event.fromJson(postJson))
            .toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      debugPrint('❌ fetchMyPosts error: $e');
      return [];
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
  /// ✅ 7. FETCH POSTS FOR A SPECIFIC USER (with full Event objects)
  Future<List<Event>> fetchUserPostsById(String userId, {String? type}) async {
    try {
      String url = '$_apiBaseUrl/api/post?user=$userId';
      if (type != null && type.isNotEmpty) {
        url += '&type=$type';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = data['data']['posts'] as List;

        return posts.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts for user');
      }
    } catch (e) {
      debugPrint('❌ fetchUserPostsById error: $e');
      return [];
    }
  }
  /// ✅ 8 sendPostNotificationToFollowers
  Future<void> sendPostNotificationToFollowers({
    required BuildContext context,
    required String postImageUrl,
    required String postTitle,
    required String senderName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backendUserId = prefs.getString('backendUserId');
      final userMobile = prefs.getString('backendUserMobile') ?? '';
      final rawUserAvatar = prefs.getString('backendUserProfile') ?? '';

      final String userAvatar = rawUserAvatar.startsWith('http')
          ? rawUserAvatar
          : 'http://82.29.167.118:8000$rawUserAvatar';

      if (backendUserId == null || backendUserId.isEmpty) {
        debugPrint('❌ backendUserId missing — cannot send notification');
        return;
      }

      // 🔁 Fetch followers
      final followersUrl = Uri.parse('http://82.29.167.118:8000/api/user/$backendUserId');
      final followersResponse = await http.get(followersUrl);

      if (followersResponse.statusCode != 200) {
        debugPrint('❌ Failed to fetch followers');
        return;
      }

      final followersData = jsonDecode(followersResponse.body);
      final followersList = followersData['data']['followers'] as List;

      for (var follower in followersList) {
        final followerId = follower['_id'];

        // 🔍 Fetch follower FCM token
        final followerDetailUrl = Uri.parse('http://82.29.167.118:8000/api/user/$followerId');
        final detailResponse = await http.get(followerDetailUrl);

        if (detailResponse.statusCode != 200) {
          debugPrint('❌ Failed to fetch follower $followerId');
          continue;
        }

        final followerData = jsonDecode(detailResponse.body);
        final fcmToken = followerData['data']['fcmToken'];

        if (fcmToken == null || fcmToken.toString().isEmpty) {
          debugPrint('⚠️ Skipping follower $followerId — no FCM token');
          continue;
        }

        // 📤 Send notification
        final notificationUrl = Uri.parse('http://82.29.167.118:8000/api/send-notification');

        final body = jsonEncode({
          "fcmToken": fcmToken,
          "title": "$senderName posted something new!",
          "body": postTitle.isNotEmpty ? postTitle : 'Check out the latest post!',
          "imageUrl": postImageUrl, // 🖼️ show post in big picture
          "data": {
            "userId": backendUserId,
            "userName": senderName,
            "userMobile": userMobile,
            "userAvatar": userAvatar, // 👤 Avatar passed to client
            "postImage": postImageUrl,
            "type": "post"
          }
        });

        final response = await http.post(
          notificationUrl,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          debugPrint('✅ Notification sent to $followerId');
        } else {
          debugPrint('❌ Failed to send to $followerId');
          debugPrint('📥 ${response.body}');
        }
      }

      // ✅ Show toast once all done
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📣 Notifications sent to followers!')),
        );
      }
    } catch (e, stack) {
      debugPrint('❌ Exception while sending post notification: $e');
      debugPrint('🧱 Stacktrace:\n$stack');
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

