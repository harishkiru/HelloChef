import 'package:flutter/material.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/components/main_navbar.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: const Center(child: Text('Practice Screen')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}