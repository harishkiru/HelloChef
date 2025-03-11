import 'package:flutter/material.dart';
import 'package:src/classes/lesson_item.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/screens/level_section_screen.dart';
import 'package:src/classes/level.dart';
import 'package:src/components/lesson_level_card.dart';
import 'package:src/screens/test_screen.dart';
import 'package:src/components/user_profile.dart';
import 'package:src/classes/quiz.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  // Temporary data used for testing purposes
  List<Level> levels = [
    Level(
      id: 0,
      level: 0,
      title: "Level 0",
      subtitle: "Kitchen Foundations",
      imagePath: "assets/images/level_images/level_0.png",
      isCompleted: true,
      sections: [
        LevelSection(
          id: 0,
          title: "Before You Start",
          subtitle: "Learn common tools, equipment, and ingredients.",
          imagePath: "assets/images/level_section_images/level_0_section_0.png",
          lessons: [
            LessonItem(
              id: 0,
              title: "Common Kitchen Tools",
              type: 0,
              imagePath:
                  "assets/images/lesson_images/level_0_section_0_lesson_0.png",
              isCompleted: true,
              content:
                  "# Heading 1\n![Photo](assets/images/level_images/level_1.jpg)\nThis is **bold** text and this is *italic* text.\n\n- Item 1\n- Item 2\n- Item 3\n\n[Click here](https://flutter.dev) to visit Flutter's website.",
            ),
            LessonItem(
              id: 1,
              title: "Common Kitchen Equipment",
              type: 1,
              imagePath:
                  "assets/images/lesson_images/level_0_section_0_lesson_1.png",
              videoPath: "assets/videos/test.mp4",
              isCompleted: false,
            ),
            LessonItem(
              id: 2,
              title: "Common Ingredients",
              type: 0,
              imagePath:
                  "assets/images/lesson_images/level_0_section_0_lesson_2.png",
              isCompleted: false,
            ),
            LessonItem(
              id: 3,
              title: "Common Quiz",
              type: 2,
              imagePath: "assets/images/lesson_images/level_0_section_0_lesson_2.png",
              isCompleted: false,
              quiz: Quiz(
                title: "Kitchen Basics Quiz",
                description: "Test your knowledge of kitchen basics!",
                questions: [
                  QuizQuestion(
                    question: "Which of the following is NOT a common kitchen tool?",
                    options: ["Spatula", "Whisk", "Blender", "Power drill"],
                    correctAnswerIndex: 3,
                  ),
                  QuizQuestion(
                    question: "What is the primary use of a colander?",
                    options: ["Mixing ingredients", "Draining liquids", "Measuring ingredients", "Cutting vegetables"],
                    correctAnswerIndex: 1,
                  ),
                  QuizQuestion(
                    question: "Which knife is best for chopping vegetables?",
                    imagePath: "assets/images/quiz/chef_knife.png",
                    options: ["Paring knife", "Chef's knife", "Bread knife", "Butter knife"],
                    correctAnswerIndex: 1,
                  ),
                  QuizQuestion(
                    question: "What is the main purpose of a food processor?",
                    options: ["Brewing coffee", "Blending smoothies", "Chopping and mixing ingredients", "Toasting bread"],
                    correctAnswerIndex: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        LevelSection(
          id: 1,
          title: "Kitchen Safety",
          subtitle: "Learn how to safely use kitchen tools and equipment.",
          imagePath: "assets/images/level_section_images/level_0_section_1.png",
          lessons: List.empty(),
        ),
        LevelSection(
          id: 2,
          title: "Knowledge Section",
          subtitle: "Test what you've learned.",
          imagePath: "assets/images/level_section_images/level_0_section_2.png",
          lessons: List.empty(),
        ),
      ],
    ),
    Level(
      id: 1,
      level: 1,
      title: "Level 1",
      subtitle: "Kitchen Something",
      imagePath: "assets/images/level_images/level_1.jpg",
      isCompleted: false,
      sections: List.empty(),
    ),
    Level(
      id: 2,
      level: 2,
      title: "Level 2",
      subtitle: "Kitchen Learning Plus",
      imagePath: "assets/images/level_images/level_2.jpg",
      isCompleted: false,
      sections: List.empty(),
    ),
    Level(
      id: 3,
      level: 3,
      title: "Level 3",
      subtitle: "Kitchen Foundations Plus Plus",
      imagePath: "assets/images/level_images/level_3.jpg",
      isCompleted: false,
      sections: List.empty(),
    ),
    Level(
      id: 4,
      level: 4,
      title: "Level 4",
      subtitle: "Kitchen Foundations",
      imagePath: "assets/images/level_images/level_0.png",
      isCompleted: false,
      sections: List.empty(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: const [UserProfileIcon()],
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
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                LevelSectionScreen(level: levels[index]),
                      ),
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
