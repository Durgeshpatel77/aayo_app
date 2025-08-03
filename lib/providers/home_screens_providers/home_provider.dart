// lib/providers/home_screens_providers/home_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/comment_model.dart';
import '../../models/event_model.dart';

class HomeProvider extends ChangeNotifier {
  static const _base = 'http://82.29.167.118:8000/api/post';
  bool _loading = false;
  List<Event> _allEvents = [];
  int _selectedIndex = 0;

  bool get isLoading => _loading;
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;

  List<Event> get allEvents => _allEvents;

  int get selectedIndex => _selectedIndex;
  bool _hasNewPosts = false;

  bool get hasNewPosts => _hasNewPosts;
  Future<List<Event>> fetchLatestEventsForCheck() async {
    final url = Uri.parse('$_base?page=1'); // Fetch page 1 only

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];

        if (data != null && data['posts'] is List) {
          final posts = data['posts'] as List;
          return posts.map((e) => Event.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching latest posts for check: $e");
    }
    return [];
  }

  void setHasNewPosts(bool value) {
    _hasNewPosts = value;
    notifyListeners();
  }
  void checkForNewPosts(List<Event> latestEvents) {
    if (_allEvents.isEmpty || latestEvents.isEmpty) return;

    if (latestEvents.first.id != _allEvents.first.id) {
      setHasNewPosts(true); // Public method to show button
    }
  }


  String? getFcmTokenByUserId(String userId) {
    try {
      final matchingEvent = _allEvents.firstWhere(
            (event) => event.organizerId == userId,
      );
      return matchingEvent.organizerFcmToken;
    } catch (e) {
      debugPrint("⚠️ FCM token not found for userId: $userId");
      return null;
    }
  }

  void setSelectedIndex(int i) {
    _selectedIndex = i;
    notifyListeners();
  }

  Future<void> searchPostsAndEvents(String searchText) async {
    _loading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_base?search=$searchText');
      debugPrint('🔍 Searching from: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];

        if (data != null && data['posts'] is List) {
          _allEvents = (data['posts'] as List)
              .map((item) => Event.fromJson(item))
              .toList();
        } else {
          _allEvents = [];
          debugPrint('⚠️ No posts found in data.');
        }
      } else {
        debugPrint('❌ Search failed: ${response.statusCode}');
        _allEvents = [];
      }
    } catch (e) {
      debugPrint('❌ Exception during search: $e');
      _allEvents = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchAll() async {
    _loading = true;
    notifyListeners();

    List<Event> combined = [];

    try {
      final events = await _fetchByType('event');
      combined.addAll(events);
    } catch (e) {
      debugPrint('❌ Failed to fetch events: $e');
    }

    try {
      final posts = await _fetchByType('post');
      combined.addAll(posts);
    } catch (e) {
      debugPrint('❌ Failed to fetch posts: $e');
    }

    combined.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first

    checkForNewPosts(combined); // 🆕 Check for updates

    _allEvents = combined;
    _loading = false;
    notifyListeners();
  }

  Future<List<Event>> _fetchByType(String type) async {
    final url = Uri.parse("$_base?type=$type");

    final response = await http.get(url);
    //debugPrint("API RESPONSE HOME PAGE($type): ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'];

      if (data != null && data['posts'] is List) {
        final List<dynamic> posts = data['posts'];
        //debugPrint("🔢 ${posts.length} $type(s) fetched");
        return posts.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception(
            "Unexpected response format for type '$type' — 'posts' not found");
      }
    } else {
      throw Exception(
          "HTTP error ${response.statusCode} while fetching '$type'");
    }
  }
  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasNextPage) return; // Prevent multiple loads or if no more pages

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++; // Increment page for the next fetch
      final url = Uri.parse('$_base?page=$_currentPage');
      final response = await http.get(url);
      debugPrint("📡 loadMoreEvents response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint("📦 loadMoreEvents JSON: $json");

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          final newPosts = (data['posts'] as List)
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList();
          _allEvents.addAll(newPosts); // Add new posts to the existing list
          _currentPage = data['currentPage'];
          _hasNextPage = data['hasNextPage'];
        } else {
          throw Exception(json['message'] ?? 'Failed to load more posts');
        }
      } else {
        throw Exception('Failed to load more posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error loading more events: $e");
      // Handle error (e.g., show a snackbar)
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  Future<void> fetchInitialEvents() async {
    if (_loading) return; // Prevent multiple initial fetches

    _loading = true;
    _currentPage = 1; // Reset to first page for initial fetch
    _hasNextPage = true; // Assume there are more pages initially
    notifyListeners();

    try {
      final url = Uri.parse('$_base?page=$_currentPage');
      final response = await http.get(url);
      debugPrint("📡 fetchInitialEvents response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint("📦 fetchInitialEvents JSON: $json");

        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          _allEvents = (data['posts'] as List)
              .map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList();
          _currentPage = data['currentPage'];
          _hasNextPage = data['hasNextPage'];
        } else {
          throw Exception(json['message'] ?? 'Failed to fetch initial posts');
        }
      } else {
        throw Exception('Failed to load initial posts: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Error fetching initial events: $e");
      // Handle error (e.g., show a snackbar)
    } finally {
      _loading = false;
      notifyListeners();
    }
  }



  /// ✅ Update the likes for a specific post/event
  void updateEventLikes(String eventId, List<String> newLikes) {
    _allEvents = _allEvents.map((event) {
      if (event.id == eventId) {
        return Event(
          id: event.id,
          title: event.title,
          content: event.content,
          location: event.location,
          startTime: event.startTime,
          endTime: event.endTime,
          isFree: event.isFree,
          organizerId: event.organizerId,
          price: event.price,
          likes: newLikes,
          comments: event.comments,
          image: event.image,
          media: event.media,
          organizer: event.organizer,
          organizerProfile: event.organizerProfile,
          createdAt: event.createdAt,
          type: event.type,
          latitude: event.latitude,
          longitude: event.longitude,

          // ✅ ADD THESE TWO MISSING FIELDS
          organizerFcmToken: event.organizerFcmToken,
          organizerMobile: event.organizerMobile,
        );
      }
      return event;
    }).toList();

    notifyListeners();
  }

  /// ✅ NEW: Add a comment to a post or event by its ID
  Future<Map<String, dynamic>> addCommentToPost({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final url = Uri.parse('$_base/comment/$postId');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': userId,
        'content': content,
      }),
    );

    final json = jsonDecode(response.body);
    if (response.statusCode != 201 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Failed to comment');
    }

    // ✅ Return the newly added comment
    return json['data']['comments'].last;
  }

  /// ✅ DELETE: DELETE a comment to a post or event.

  Future<void> deleteCommentFromPost({
    required String postId,
    required String commentId,
  }) async {
    final url = Uri.parse('$_base/comment/$postId');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'commentId': commentId}),
    );

    final json = jsonDecode(response.body);
    if (response.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Failed to delete comment');
    }
  }
  void updateEventComments(String postId, List<CommentModel> comments) {
    final index = _allEvents.indexWhere((event) => event.id == postId);
    if (index != -1) {
      _allEvents[index].comments
        ..clear()
        ..addAll(comments);
      notifyListeners(); // this updates HomeTabContent
    }
  }
  Future<Event?> fetchEventById(String id) async {
    final url = Uri.parse("$_base/$id");

    try {
      final response = await http.get(url);
      debugPrint("📡 fetchEventById response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint("📦 fetchEventById JSON: $json");

        final data = json['data'];
        if (data != null && data is Map<String, dynamic>) {
          return Event.fromJson(data); // ✅ Use data directly
        } else {
          debugPrint("❌ 'data' missing or invalid.");
        }
      }
    } catch (e) {
      debugPrint("❌ Exception in fetchEventById: $e");
    }

    return null;
  }
}
