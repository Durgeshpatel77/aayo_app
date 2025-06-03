import 'package:aayo/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChooseFavoriteScreen extends StatefulWidget {
  const ChooseFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<ChooseFavoriteScreen> createState() => _ChooseFavoriteScreenState();
}

class _ChooseFavoriteScreenState extends State<ChooseFavoriteScreen> {
  final List<Map<String, String>> categories = [
    {'icon': '💼', 'title': 'Business'},
    {'icon': '🙌', 'title': 'Community'},
    {'icon': '🎵', 'title': 'Music & Entertainment'},
    {'icon': '🩹', 'title': 'Health'},
    {'icon': '🍟', 'title': 'Food & drink'},
    {'icon': '👨‍👩‍👧‍👦', 'title': 'Family & Education'},
    {'icon': '⚽', 'title': 'Sport'},
    {'icon': '👠', 'title': 'Fashion'},
    {'icon': '🎬', 'title': 'Film & Media'},
    {'icon': '🏠', 'title': 'Home & Lifestyle'},
    {'icon': '🎨', 'title': 'Design'},
    {'icon': '🎮', 'title': 'Gaming'},
    {'icon': '🧪', 'title': 'Science & Tech'},
    {'icon': '🏫', 'title': 'School & Education'},
    {'icon': '🏖️', 'title': 'Holiday'},
    {'icon': '✈️', 'title': 'Travel'},
  ];

  final Set<String> selectedCategories = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              Text(
                "Choose your favorite event",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Get personalized event recommendation.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 25),

              // Scrollable list with dynamic layout
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: categories.map((cat) {
                      final title = cat['title']!;
                      final icon = cat['icon']!;
                      final isSelected = selectedCategories.contains(title);
                      return _buildCategoryItem(icon, title, isSelected);
                    }).toList(),
                  ),
                ),
              ),

              // Finish Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: selectedCategories.isNotEmpty
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: selectedCategories.isNotEmpty
                          ? Colors.pink
                          : Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Finish",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildCategoryItem(String icon, String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedCategories.remove(title);
          } else {
            selectedCategories.add(title);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
