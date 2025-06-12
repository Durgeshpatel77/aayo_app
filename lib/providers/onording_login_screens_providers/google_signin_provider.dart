import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn here
  bool _isSigningIn = false;

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    isSigningIn = true;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn(); // Use the initialized _googleSignIn
      if (googleUser == null) {
        isSigningIn = false;
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      isSigningIn = false;
      return userCredential.user;
    } catch (e) {
      isSigningIn = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: $e")),
      );
      return null;
    }
  }

  // --- NEW signOutGoogle method ---
  Future<void> signOutGoogle() async {
    isSigningIn = true; // Indicate that a sign-out process is ongoing
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut(); // Sign out from Firebase Auth
      print('User signed out successfully.');
    } catch (e) {
      print('Error during Google sign-out: $e');
      // You might want to show a SnackBar here for sign-out errors as well
    } finally {
      isSigningIn = false; // Reset signing in status
    }
  }
}