import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 🚀 GoogleSignInProvider: Manages Google authentication and user registration with your backend.
class GoogleSignInProvider extends ChangeNotifier {
  // 🔑 FirebaseAuth instance: For Firebase authentication operations.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 🌐 GoogleSignIn instance: For initiating Google Sign-In flow.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔄 _isSigningIn: A boolean to track the signing-in state, used for UI feedback.
  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn; // Getter for the signing-in state.

  // Setter for _isSigningIn: Notifies listeners (UI) when the state changes.
  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }

  // 🔗 _apiBaseUrl: The base URL for your backend API.
  final String _apiBaseUrl = 'http://srv861272.hstgr.cloud:8000';

  // 🚀 signInWithGoogle: Initiates the Google Sign-In process.
  // Returns the authenticated Firebase User object on success, null otherwise.
  Future<User?> signInWithGoogle(BuildContext context) async {
    isSigningIn = true; // Set signing-in state to true to show loading indicator.

    try {
      // 🤝 Step 1: Start the Google Sign-In flow to get the user's Google account.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {

        // User cancelled the sign-in process.
        isSigningIn = false;
        return null;
      }

      // 🔐 Step 2: Get Google authentication credentials (accessToken and idToken).
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔗 Step 3: Sign in to Firebase using the Google credentials.
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? user = userCredential.user; // Get the Firebase User object.

      if (user != null) {
        // ✅ User successfully signed in to Firebase. Log user details.

        // 📝 Step 4: Register or update the user's information in your custom backend.
        await _registerUserInBackend(user, context);
      }

      isSigningIn = false; // Set signing-in state to false.
      return user; // Return the authenticated Firebase user.
    } catch (e) {
      // ❌ Handle any errors during the sign-in process.
      isSigningIn = false; // Set signing-in state to false.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: $e")), // Show error message to user.
      );
      return null;
    }
  }

  // 📝 _registerUserInBackend: Sends user data to your custom backend for registration/update.
  Future<void> _registerUserInBackend(User user, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/api/user'),
      );

      // Add fields
      request.fields['userId'] = user.uid;
      request.fields['name'] = user.displayName ?? 'Anonymous User';
      request.fields['mobile'] = "1234567891";
      request.fields['email'] = user.email ?? '';
      request.fields['profile'] = user.photoURL ?? '';

      // Send the request
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody.body)['data'];

        final profile = data['profile']?.isNotEmpty == true
            ? data['profile']
            : user.photoURL ?? '';

        await prefs.setString('backendUserId', data['_id']);
        await prefs.setString('userId', data['userId'] ?? user.uid);
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('userName', data['name'] ?? 'Anonymous');
        await prefs.setString('userMobile', data['mobile'] ?? '');
        await prefs.setString('userProfileImage', profile);

      } else {
        print('Backend registration failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error making API call: $e');
    }
  }

  // 🚪 signOutGoogle: Signs out the user from Google and Firebase.
  Future<void> signOutGoogle() async {
    isSigningIn = true; // Set signing-out state to true.
    try {
      await _googleSignIn.signOut(); // Sign out from Google.
      await _auth.signOut(); // Sign out from Firebase.
    } catch (e) {
      print('Sign-out error: $e'); // Log any sign-out errors.
    } finally {
      isSigningIn = false; // Always set signing-out state to false, even on error.
    }
  }
}