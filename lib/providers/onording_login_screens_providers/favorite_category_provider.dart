import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCategoryProvider with ChangeNotifier {
  final List<String> _selectedCategories = [];
  bool _isSubmitting = false;

  List<String> get selectedCategories => _selectedCategories;
  bool get hasSelection => _selectedCategories.isNotEmpty;
  bool get isSubmitting => _isSubmitting;

  bool isSelected(String category) => _selectedCategories.contains(category);

  void toggleCategory(BuildContext context, String category) {
    if (isSelected(category)) {
      _selectedCategories.remove(category);
    } else {
      if (_selectedCategories.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You can only select up to 3 categories."),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  Future<bool> submitInterests(BuildContext context) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('backendUserId');

      // Try to fetch from backend if missing
      if (userId == null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final response = await http.get(Uri.parse('http://srv861272.hstgr.cloud:8000/api/user/${user.uid}'));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body)['data'];
            userId = data['_id'];
            await prefs.setString('backendUserId', userId!);
          } else {
            _isSubmitting = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User not found on server")),
            );
            return false;
          }
        }
      }

      final url = Uri.parse('http://82.29.167.118:8000/api/user/$userId');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'interests': selectedCategories.join(','), // as string
        }),
      );

      _isSubmitting = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('❌ Failed: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update interests")),
        );
        return false;
      }
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      debugPrint('Error submitting interests: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
      return false;
    }
  }
}
