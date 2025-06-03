import 'package:flutter/material.dart';

class TextfieldEditprofiile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final int maxLines;

  const TextfieldEditprofiile({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIcon = Icons.person,
    this.obscureText = false,
    this.maxLines = 1,  // default to 1 line

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pink = Colors.pinkAccent;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pink.shade400, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pink.shade400, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pink.shade400, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: pink.shade400, width: 1),
        ),
      ),
      maxLines: maxLines,
    );
  }
}
