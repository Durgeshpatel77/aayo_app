import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Needed for accessing GoogleSignInProvider

import '../../providers/onording_login_screens_providers/google_signin_provider.dart';
import 'login_and_register.dart';
import 'onboarding_screen.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final googleProvider = Provider.of<GoogleSignInProvider>(context, listen: false); // listen: false as we only need to call signOut

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Logout'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hide back button for a clean logout flow
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.exit_to_app,
                size: 80,
                color: Colors.pinkAccent,
              ),
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
              Text(
                "Thank you for using our app. We hope to see you again soon!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent, // A clear "logout" color
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    await googleProvider.signOutGoogle(); // Perform the logout
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                          (Route<dynamic> route) => false, // Remove all previous routes
                    );
                  },
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
  }
}