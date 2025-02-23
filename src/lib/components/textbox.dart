import 'package:flutter/material.dart';

// A custom TextFormField widget that can be reused across the app
class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final Widget label;
  final bool obscureText;

  // Constructor for initializing the custom text field
  const MyTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    // Remove dynamic horizontal padding to allow more width
    return Padding(
      // Adjusted padding: keep same vertical spacing, reduced horizontal padding for more width
      padding: const EdgeInsets.only(
        top: 25,
        bottom: 5,
        left: 25,
        right: 25,
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          label: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }
}