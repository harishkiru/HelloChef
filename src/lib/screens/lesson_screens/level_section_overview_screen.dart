import 'package:flutter/material.dart';
import 'package:src/classes/level_section.dart';
import 'package:src/components/lesson_components/lesson_item_card.dart';
import 'package:src/services/db_helper.dart';
import 'package:src/classes/lesson_item.dart';

class LevelSectionOverviewScreen extends StatefulWidget {
  final LevelSection section;

  const LevelSectionOverviewScreen({super.key, required this.section});

  @override
  State<LevelSectionOverviewScreen> createState() =>
      _LevelSectionOverviewScreenState();
}

class _LevelSectionOverviewScreenState
    extends State<LevelSectionOverviewScreen> {
  final dbHelper = DBHelper.instance();

  Future<List<LessonItem>> getAllLessonsFromSection(int sectionId) async {
    List<Map<String, dynamic>> lessons = await dbHelper
        .getAllLessonsFromSection(sectionId);
    List<LessonItem> lessonItems =
        lessons.map((lesson) {
          return LessonItem(
            id: lesson['id'],
            title: lesson['title'],
            type: lesson['type'],
            content: lesson['content'],
            videoPath: lesson['videoPath'],
            imagePath: lesson['imagePath'],
            isCompleted: lesson['isCompleted'] == 1,
          );
        }).toList();

    return lessonItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.section.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          Expanded(
            child: FutureBuilder(
              future: getAllLessonsFromSection(widget.section.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading lessons'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No lessons available'));
                } else {
                  List<LessonItem> lessons = snapshot.data!;
                  return ListView.builder(
                    itemCount: lessons.length,
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    itemBuilder: (context, index) {
                      return LessonItemCard(lessonItem: lessons[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
