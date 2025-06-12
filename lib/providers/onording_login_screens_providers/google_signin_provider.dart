import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSigningIn = false;

  bool get isSigningIn => _isSigningIn;

  set isSigningIn(bool value) {
    _isSigningIn = value;
    notifyListeners();
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    isSigningIn = true;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
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
}
