import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  // Function to be called when the button is tapped
  final Function()? onTap;

  // Widget to display inside the button
  final Widget child;

  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Add padding around the button
      padding: const EdgeInsets.only(
        top: 25,
        left: 25,
        right: 25,
      ),
      child: GestureDetector(
        // Detect tap events and call onTap function
        onTap: onTap,
        child: Container(
          // Center the child widget within the container
          alignment: Alignment.center,
          // Set the size of the button
          width: 100,
          height: 40,
          // Style the button with a blue background and rounded corners
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          // Place the child widget inside the button
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: child,
          ),
        ),
      ),
    );
  }
}