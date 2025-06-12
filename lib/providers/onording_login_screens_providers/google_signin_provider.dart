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

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }

  // Define your API endpoint
  final String _apiBaseUrl = 'http://srv861272.hstgr.cloud:8000'; // Your API base URL

  Future<User?> signInWithGoogle(BuildContext context) async {
    isSigningIn = true;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isSigningIn = false;
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print("User Name: ${user.displayName}");
        print("User email: ${user.email}");
        print("User phone number: ${user.phoneNumber}"); // This can be null
        print("User uid: ${user.uid}");

        // --- Make API call to register/login user in your backend ---
        await _registerUserInBackend(user, context);
      }

      isSigningIn = false;
      return user;
    } catch (e) {
      isSigningIn = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: $e")),
      );
      return null;
    }
  }

  // --- Method to register user in your backend API ---
  Future<void> _registerUserInBackend(User user, BuildContext context) async {
    try {
      // Save user data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.uid); // Store User ID
      await prefs.setString('userEmail', user.email ?? '');
      await prefs.setString('userName', user.displayName ?? 'Anonymous');

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String?>{
          "userId": user.uid,
          "name": user.displayName ?? 'Anonymous User',
          "mobile": "1234567891",
          "email": user.email,
        }),
      );

      if (response.statusCode == 201) {
        print('Backend registration successful: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully registered with backend!")),
        );
      } else {
        print('Failed to register user in backend. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Backend registration failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('Error making API call to register user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error during backend registration: $e")),
      );
    }
  }

  // --- signOutGoogle method ---
  Future<void> signOutGoogle() async {
    isSigningIn = true;
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Error during Google sign-out: $e');
    } finally {
      isSigningIn = false;
    }
  }
}