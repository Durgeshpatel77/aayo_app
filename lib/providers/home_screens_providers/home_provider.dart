// lib/providers/home_screens_providers/home_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/comment_model.dart';
import '../../models/event_model.dart';

class HomeProvider extends ChangeNotifier {
  static const _base = 'http://srv861272.hstgr.cloud:8000/api/post';
  bool _loading = false;
  List<Event> _allEvents = [];
  int _selectedIndex = 0;

  bool get isLoading => _loading;

  List<Event> get allEvents => _allEvents;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int i) {
    _selectedIndex = i;
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

    _allEvents = combined
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // ⬅️ Newest first
    _loading = false;
    notifyListeners();
  }

  Future<List<Event>> _fetchByType(String type) async {
    final url = Uri.parse("$_base?type=$type");

    final response = await http.get(url);
    debugPrint("API RESPONSE ($type): ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'];

      if (data != null && data['posts'] is List) {
        final List<dynamic> posts = data['posts'];
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
          image: event.image,
          media: event.media,
          organizer: event.organizer,
          organizerProfile: event.organizerProfile,
          createdAt: event.createdAt,
          type: event.type,
          comments: event.comments,
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

}
