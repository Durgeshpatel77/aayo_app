import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'google_signin_provider.dart'; // Adjust this path if needed

class LogoutProvider with ChangeNotifier {
  final GoogleSignInProvider googleProvider;

  LogoutProvider(this.googleProvider);

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<bool> performLogout() async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Step 1: Sign out from Google
      await googleProvider.signOutGoogle();

      // Step 2: Clear SharedPreferences (session/local storage)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
}
