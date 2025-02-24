import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_level_card.dart';
import 'package:src/screens/test_screen.dart';
import 'package:src/components/user_profile.dart';

class LessonScreen extends StatelessWidget {
  LessonScreen({super.key});

  final List<Level> levels = [
    Level(
      level: 0,
      title: "Level 0",
      subtitle: "Kitchen Foundations",
      imagePath: "assets/images/level_images/level_0.png",
      sections: List.empty(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lessons',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: const [
          UserProfileIcon(),
        ],
      ),
      endDrawer: const UserProfileDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                return LessonLevelCard(
                  level: levels[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TestScreen()),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}