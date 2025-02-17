import 'package:flutter/material.dart';
import 'package:src/components/main_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Chef Home'),
        automaticallyImplyLeading: false, // No back button on home screen
      ),
      body: const Center(child: Text('Home Screen')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}