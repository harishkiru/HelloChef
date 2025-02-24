import 'package:flutter/material.dart';

class SignUpButton extends StatelessWidget {
  // Declare a final variable for the onTap function
  final Function()? onTap;

  // Constructor for SignUpButton, requiring the onTap function
  const SignUpButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Build the widget tree
    return Padding(
      // Add padding to the bottom of the widget
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: SizedBox(
        // Create a column with text and a gesture detector
        child: Column(
          children: [
            // Display a text prompting the user to sign up
            const Text("Don't have an account?"),
            // Create a gesture detector for the sign-up action
            GestureDetector(
              // Trigger the onTap function when tapped
              // Display the sign-up text with a blue color
              child: const Text(
                'Sign up >>',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}