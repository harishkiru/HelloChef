import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;

  // widget to display inside the button
  final Widget child;

  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 25,
        left: 25,
        right: 25,
      ),
      child: GestureDetector(
        // detect tap events and call onTap function
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          width: 100,
          height: 40,
          // style the button with a blue background and rounded corners
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: child,
          ),
        ),
      ),
    );
  }
}