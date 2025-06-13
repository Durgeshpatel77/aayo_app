import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'google_signin_provider.dart'; // Adjust this import path based on your project

class LogoutProvider with ChangeNotifier {
  final GoogleSignInProvider googleProvider;

  LogoutProvider(this.googleProvider);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<bool> performLogout() async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('backendUserId');

      if (userId == null || userId.isEmpty) {
        debugPrint('User ID not found in SharedPreferences');
        _isProcessing = false;
        notifyListeners();
        return false;
      }

      // Step 1: Sign out
      await googleProvider.signOutGoogle();

      // Step 2: Delete user from backend
      final response = await http.delete(
        Uri.parse('http://srv861272.hstgr.cloud:8000/api/user/$userId'),
      );

      if (response.statusCode == 200) {
        await prefs.clear(); // Step 3: Clear SharedPreferences
        _isProcessing = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to delete user. Status: ${response.statusCode}');
        _isProcessing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
}
