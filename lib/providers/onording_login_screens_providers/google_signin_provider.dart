import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String _apiBaseUrl = 'http://82.29.167.118:8000';

  bool _isSigningIn = false;
  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }

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

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _registerOrFetchUserInBackend(user, context);
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

  Future<void> _registerOrFetchUserInBackend(User user, BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = user.uid;

      // Step 1: Try to fetch existing user by userId
      final getResponse = await http.get(Uri.parse('$_apiBaseUrl/api/user?userId=$uid'));

      if (getResponse.statusCode == 200) {
        final json = jsonDecode(getResponse.body);
        final dataList = json['data'];

        if (dataList != null && dataList is List && dataList.isNotEmpty) {
          final matchedUser = dataList.firstWhere(
                (item) => item['userId'] == uid,
            orElse: () => null,
          );

          if (matchedUser != null) {
            print('✅ Existing user found (matched by userId)');

            await prefs.setString('backendUserId', matchedUser['_id'] ?? '');
            await prefs.setString('userId', matchedUser['userId'] ?? uid);
            await prefs.setString('userEmail', matchedUser['email'] ?? '');
            await prefs.setString('userName', matchedUser['name'] ?? 'Anonymous');
            await prefs.setString('userMobile', matchedUser['mobile'] ?? '');
            await prefs.setString('userProfileImage', matchedUser['profile'] ?? '');
            return;
          } else {
            print('❌ User ID not found in fetched list');
          }
        } else {
          print('❌ No user data returned');
        }
      }

      print('! User not found, registering...');

      // Step 2: Register new user
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/api/user'),
      );

      request.fields['userId'] = uid;
      request.fields['name'] = user.displayName ?? 'Anonymous';
      request.fields['mobile'] = "1234567891";
      request.fields['email'] = user.email ?? '';
      request.fields['profile'] = user.photoURL ?? '';

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody.body)['data'];

        print('✅ User registered');
        await prefs.setString('backendUserId', data['_id'] ?? '');
        await prefs.setString('userId', data['userId'] ?? uid);
        await prefs.setString('userEmail', data['email'] ?? '');
        await prefs.setString('userName', data['name'] ?? 'Anonymous');
        await prefs.setString('userMobile', data['mobile'] ?? '');
        await prefs.setString('userProfileImage', data['profile'] ?? '');
      } else {
        print('❌ Backend registration failed: ${response.statusCode}');
        print('Response body: ${responseBody.body}');
      }
    } catch (e) {
      print('🔥 Error in _registerOrFetchUserInBackend: $e');
    }
  }

  Future<void> signOutGoogle() async {
    isSigningIn = true;
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign-out error: $e');
    } finally {
      isSigningIn = false;
    }
  }
}
