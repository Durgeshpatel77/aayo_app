import 'package:flutter/material.dart';

class TextfieldEditprofiile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool readOnly;
  final int? maxLines;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged; // Add this line

  const TextfieldEditprofiile({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade500, width: 1),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged, // Pass the onChanged callback to the TextField
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.pink.shade500),
          border: InputBorder.none, // Removes the default underline border
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
      ),
    );
  }
}