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
  late Future<List<LessonItem>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _refreshLessons();
  }

  // refresh lessons data
  void _refreshLessons() {
    setState(() {
      _lessonsFuture = getAllLessonsFromSection(widget.section.id);
    });
  }

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
            quizId: lesson['quizId'],
            isCompleted: lesson['isCompleted'] == 1,
          );
        }).toList();

    return lessonItems;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final Color subtitleBgColor = isDarkMode ? Color(0xFF1A3020) : Colors.green.shade50;
    
    final Color subtitleTextColor = isDarkMode ? Colors.green.shade300 : Colors.green.shade800;
        
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              color: subtitleBgColor,
              child: Text(
                widget.section.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15, 
                  color: subtitleTextColor
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _lessonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading lessons',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No lessons available',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  } else {
                    List<LessonItem> lessons = snapshot.data!;
                    return ListView.builder(
                      itemCount: lessons.length,
                      padding: EdgeInsets.fromLTRB(
                        10,
                        20,
                        10,
                        20 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemBuilder: (context, index) {
                        return LessonItemCard(
                          lessonItem: lessons[index],
                          onCompleted: _refreshLessons,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
