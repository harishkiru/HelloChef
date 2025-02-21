import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_level_card.dart';
import 'package:src/screens/test_screen.dart';

class LessonScreen extends StatelessWidget {
  List<Level> levels = [
    Level(
      level: 0,
      title: "Level 0",
      subtitle: "Kitchen Foundations",
      imagePath: "assets/images/level_images/level_0.png",
      sections: List.empty(),
    ),
  ];

  LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
