// providers/user_profile_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';

class UserProfileProvider with ChangeNotifier {
  String _name = "Tanya Hill"; // Default initial name
  String _about =
      "We have a team but still missing a couple of people. Let's play together! We have a team but still missing a couple of people. We have a team but still missing a couple of people"; // Default initial about
  String _profileImageUrl =
      'https://images.unsplash.com/photo-1520813795554-e0b4a4413661?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'; // Default network image
  File? _profileImageFile; // For locally picked image

  String get name => _name;
  String get about => _about;
  String get profileImageUrl => _profileImageUrl;
  File? get profileImageFile => _profileImageFile;

  // Method to update name and about
  void updateProfileText({required String newName, required String newAbout}) {
    _name = newName;
    _about = newAbout;
    notifyListeners(); // Notify widgets listening to this provider
  }

  // Method to update profile image (either from network or local file)
  void updateProfileImage({String? imageUrl, File? imageFile}) {
    if (imageUrl != null) {
      _profileImageUrl = imageUrl;
      _profileImageFile = null; // Clear local file if setting network image
    } else if (imageFile != null) {
      _profileImageFile = imageFile;
      _profileImageUrl = ''; // Clear network URL if setting local file
    }
    notifyListeners(); // Notify widgets listening to this provider
  }
}
