import 'package:flutter/material.dart';

import '../../providers/home_screens_providers/add_post_provider.dart';

class CategorySelector extends StatefulWidget {
  final AddPostProvider addPostProvider;

  const CategorySelector({required this.addPostProvider, super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<Map<String, String>> categories = [
    {'title': 'Food', 'icon': '🍔'},
    {'title': 'Travel', 'icon': '✈️'},
    {'title': 'Fashion', 'icon': '👗'},
    {'title': 'Tech', 'icon': '💻'},
    {'title': 'Fitness', 'icon': '🏋️‍♂️'},
    {'title': 'Music', 'icon': '🎵'},
    {'title': 'News', 'icon': '📰'},
    {'title': 'Sports', 'icon': '⚽'},
  ];

  List<String> selectedCategories = [];

  void toggleCategory(String categoryTitle) {
    setState(() {
      if (selectedCategories.contains(categoryTitle)) {
        selectedCategories.remove(categoryTitle);
      } else {
        if (selectedCategories.length < 2) {
          selectedCategories.add(categoryTitle);
        } else {
          // Optional: show message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 2 categories only.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      widget.addPostProvider.setSelectedCategories(selectedCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: categories.map((category) {
        final title = category['title']!;
        final isSelected = selectedCategories.contains(title);

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category['icon']!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(title),
            ],
          ),
          selected: isSelected,
          selectedColor: Colors.pinkAccent,
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          ),
          onSelected: (_) => toggleCategory(title),
        );
      }).toList(),
    );
  }
}
