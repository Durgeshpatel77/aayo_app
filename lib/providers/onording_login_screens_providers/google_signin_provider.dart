import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isSigningIn = false;

  // Used to show loading indicator during sign-in
  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners(); // Notify listeners when signing state changes
  }

  // 🔗 Your backend API base URL
  final String _apiBaseUrl = 'http://srv861272.hstgr.cloud:8000';

  // 🔐 Google Sign-In Logic
  Future<User?> signInWithGoogle(BuildContext context) async {
    isSigningIn = true;

    try {
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        isSigningIn = false;
        return null;
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;

      // Create a Firebase credential from Google token
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Debug print user info
        print("User Name: ${user.displayName}");
        print("User email: ${user.email}");
        print("User phone number: ${user.phoneNumber}");
        print("User uid: ${user.uid}");
        print("User photo: ${user.photoURL}");

        // 👇 Register the user in your backend
        await _registerUserInBackend(user, context);
      }

      isSigningIn = false;
      return user;
    } catch (e) {
      isSigningIn = false;

      // Show error in UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: $e")),
      );
      return null;
    }
  }

  // 📝 Register the user in your backend and store details locally
  Future<void> _registerUserInBackend(User user, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🗂️ Save basic user info locally using SharedPreferences
      await prefs.setString('userId', user.uid); // Firebase UID
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userName', user.displayName ?? 'Anonymous');

      // 🔗 Call your Node.js/MongoDB backend API to register the user
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          "userId": user.uid,                         // Firebase UID
          "name": user.displayName ?? 'Anonymous User',
          "mobile": "1133567891",                     // Static mobile for demo
          "email": user.email,
          "image": user.photoURL,                     // Profile photo URL
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        // 💾 Save backend MongoDB _id (required for delete later)
        await prefs.setString('backendUserId', responseBody['data']['_id']);

        print('✅ Backend registration successful: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully registered with backend!")),
        );
      } else {
        // ⚠️ Handle backend failure
        print('❌ Backend error: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backend registration failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      // ⚠️ Network or parsing error
      print('❌ Error during backend API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error during backend registration: $e")),
      );
    }
  }

  // 🔓 Sign out from Firebase and Google
  Future<void> signOutGoogle() async {
    isSigningIn = true;
    try {
      // Sign out from Google and Firebase
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('🚪 User signed out successfully.');
    } catch (e) {
      print('⚠️ Error during Google sign-out: $e');
    } finally {
      isSigningIn = false;
    }
  }
}
