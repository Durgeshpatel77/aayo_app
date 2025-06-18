import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

    try {
      final events = await _fetchByType('event');
      final posts = await _fetchByType('post');

      _allEvents = [...events, ...posts,]..shuffle();
    } catch (e, s) {
      debugPrint('HomeProvider fetch error: $e\n$s');
    }

    _loading = false;
    notifyListeners();
  }

  Future<List<Event>> _fetchByType(String type) async {
    final url = Uri.parse("http://srv861272.hstgr.cloud:8000/api/post?type=$type");

    final response = await http.get(url);
    debugPrint("API RESPONSE ($type): ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final data = json['data'];

      if (data != null && data['posts'] is List) {
        final List<dynamic> posts = data['posts'];
        return posts.map((item) => Event.fromJson(item)).toList();
      } else {
        throw Exception("Unexpected response format for type '$type' — 'posts' not found");
      }
    } else {
      throw Exception("HTTP error ${response.statusCode} while fetching '$type'");
    }
  }
}

