import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../providers/onording_login_screens_providers/google_signin_provider.dart';
import '../../providers/onording_login_screens_providers/logout_provider.dart';
import 'onboarding_screen.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final googleProvider = Provider.of<GoogleSignInProvider>(context, listen: false);
    final logoutProvider = LogoutProvider(googleProvider);

    try {
      // ✅ Delete FCM token from device
      final messaging = FirebaseMessaging.instance;
      final fcmToken = await messaging.getToken();

      // ✅ Send request to backend to remove token from DB
      await http.put(
        Uri.parse('http://82.29.167.118:8000/api/user/remove-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      // ✅ Delete it locally
      await messaging.deleteToken();
      debugPrint('🧹 Deleted FCM token: $fcmToken');
    } catch (e) {
      debugPrint('⚠️ Error deleting FCM token: $e');
    }

    final success = await logoutProvider.performLogout();

    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogoutProvider>(
      create: (context) =>
          LogoutProvider(Provider.of<GoogleSignInProvider>(context, listen: false)),
      builder: (context, child) {
        final logoutProvider = Provider.of<LogoutProvider>(context);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Logout'),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: logoutProvider.isProcessing
                  ? const CircularProgressIndicator(color: Colors.pinkAccent)
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.exit_to_app, size: 80, color: Colors.pinkAccent),
                  const SizedBox(height: 30),
                  const Text(
                    "You have been logged out.",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Thank you for using our app. We hope to see you again soon!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => _handleLogout(context),
                      child: const Text(
                        'Return to Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
