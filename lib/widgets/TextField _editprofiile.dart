import 'package:flutter/material.dart';

class TextfieldEditprofiile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength; // optional
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const TextfieldEditprofiile({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
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
        maxLength: maxLength,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.pink.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          counterText: '', // ✅ hides character counter
        ),
      ),
    );
  }
}
