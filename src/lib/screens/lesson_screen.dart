import 'package:flutter/material.dart';
import 'package:src/screens/home_screen.dart';
import 'package:src/components/main_navbar.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
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
      body: const Center(child: Text('Lesson Screen')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}