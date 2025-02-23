import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_level_card.dart';
import 'package:src/screens/test_screen.dart';
import 'package:src/components/main_navbar.dart';
import 'package:src/screens/home_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
        // Always show back button here that navigates to Home.
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
      body: const Center(
        child: Text('Lesson Screen Content'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
