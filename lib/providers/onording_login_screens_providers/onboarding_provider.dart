import 'dart:io';

import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;
  void updatePage(int index) {
    _currentPage = index;
    notifyListeners();
  }
}

class ImageSelectionProvider extends ChangeNotifier {
  File? _selectedImage; // This will hold your picked image file

  File? get selectedImage => _selectedImage;

  void setImage(File? image) {
    _selectedImage = image;
    notifyListeners(); // Important: Notifies all widgets listening to this provider
  }

  // You might want a method to clear the image
  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }
}
