import 'package:flutter/material.dart';

class FavoriteCategoryProvider extends ChangeNotifier {
  final Set<String> _selectedCategories = {};

  Set<String> get selectedCategories => _selectedCategories;

  void toggleCategory(String title) {
    if (_selectedCategories.contains(title)) {
      _selectedCategories.remove(title);
    } else {
      _selectedCategories.add(title);
    }
    notifyListeners();
  }

  bool isSelected(String title) {
    return _selectedCategories.contains(title);
  }

  bool get hasSelection => _selectedCategories.isNotEmpty;
}
